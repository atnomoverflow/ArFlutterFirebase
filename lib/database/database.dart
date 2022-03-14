import 'package:firebase_database/firebase_database.dart';
import 'package:obj_detect/database/model/request_reconstruction.dart';

final databaseRefrence = FirebaseDatabase.instance.ref();

DatabaseReference saveRequestReconstruction(Request request) {
  var id = databaseRefrence.child("requestReconstruction").push();
  id.set(request.toJson());
  return id;
}
