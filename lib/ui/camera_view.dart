import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:obj_detect/database/model/request_reconstruction.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:obj_detect/database/database.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

/// [CameraView] sends each frame for inference
class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  /// Results to draw bounding boxes
  bool _isLoading = false; // This is initially false where no loading state
  String? _progress = "Sending";
  ArCoreController? arCoreController;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          print(_isLoading);
          _isLoading
              ? showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(
                        semanticsValue: _progress,
                      ),
                    );
                  })
              : null;
          try {
            String imagePath = await arCoreController?.snapshot() ?? "";

            /// Callback to receive each frame [CameraImage] perform inference on it
            onLatestImageAvailable(CameraImage cameraImage) async {
              if (classifier?.interpreter != null &&
                  classifier?.labels != null) {
                // If previous inference has not completed then return
                if (predicting!) {
                  return;
                }

                setState(() {
                  predicting = true;
                });

                var uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;
                List<String> labels;

                labels = classifier?.labels ?? [];

                // Data to be passed to inference isolate
                var isolateData = IsolateData(
                    cameraImage, classifier?.interpreter?.address ?? 0, labels);

                // We could have simply used the compute method as well however
                // it would be as in-efficient as we need to continuously passing data
                // to another isolate.

                /// perform inference in separate isolate
                Map<String, dynamic> inferenceResults =
                    await inference(isolateData);

                var uiThreadInferenceElapsedTime =
                    DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;

                // pass results to HomeView
                widget.resultsCallback(inferenceResults["recognitions"]);

                // pass stats to HomeView
                widget.statsCallback((inferenceResults["stats"] as Stats)
                  ..totalElapsedTime = uiThreadInferenceElapsedTime);

                // set predicting to false to allow new frames
                setState(() {
                  predicting = false;
                });
              }
            }

            /// Runs inference in another isolate
            Future<Map<String, dynamic>> inference(
                IsolateData isolateData) async {
              ReceivePort responsePort = ReceivePort();
              isolateUtils?.sendPort
                  .send(isolateData..responsePort = responsePort.sendPort);
              var results = await responsePort.first;
              return results;
            }

            final String fileName = "${Random().nextInt(10000)}.jpg";
            final File file = File(imagePath);
            var ref = firebase_storage.FirebaseStorage.instance
                .ref('uploads/$fileName');
            await ref.putFile(file);
            String imageUrl = await ref.getDownloadURL();
            Request request = Request(
                state: RequestState.inQueue, imageUri: imageUrl, modelUri: "");
            request.setId(saveRequestReconstruction(request));
            setState(() {
              _progress = "in queue";
            });
            request.id?.onValue.listen((DatabaseEvent event) async {
              var snapshot = event.snapshot;
              dynamic requestJson = snapshot.value;
              //print(requestJson["image_uri"]);
              Request newRequest = Request.fromJson(requestJson);
              if (newRequest.modelUri != "") {
                await addModel(newRequest.modelUri ?? "");
              }
            });
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
  }

  @override
  void dispose() {
    arCoreController?.dispose();

    super.dispose();
  }

  Future<void> addModel(String modelUri) async {
    var node = ArCoreReferenceNode(
      name: "Toucano",
      objectUrl: modelUri,
      position: vector.Vector3(0, 0, -1.5),
      rotation: vector.Vector4(0, 0, 0, 0),
    );
    await arCoreController?.addArCoreNode(node);
  }
}
