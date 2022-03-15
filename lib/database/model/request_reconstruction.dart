import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

enum RequestState { inQueue, reconstructing, done }

class Request {
  Request({
    this.state,
    this.imageUri,
    this.modelUri,
  });

  DatabaseReference? id;
  RequestState? state;
  String? imageUri;
  String? modelUri;
  setId(DatabaseReference id) => this.id = id;
  factory Request.fromJson(dynamic json) => Request(
        state: RequestState.values.elementAt(json["state"]),
        imageUri: json["image_uri"],
        modelUri: json["model_uri"],
      );

  Map<String, dynamic> toJson() => {
        "state": state?.index,
        "image_uri": imageUri,
        "model_uri": modelUri,
      };
}
