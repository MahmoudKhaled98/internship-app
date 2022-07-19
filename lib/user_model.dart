import 'package:cloud_firestore/cloud_firestore.dart';
class UserData {
  UserData({required this.email, required this.id, required this.name, required this.password});
  String id='1';
  String? email;
  String? password;
  String? name;
  String photo="https://freesvg.org/img/abstract-user-flat-4.png";

  UserData.fromDocument(DocumentSnapshot document){
    id=document.id;
    name=document['name']?? '' ;
    email=document['email']?? '' ;
  }


  DocumentReference get fireStoreRef =>
      FirebaseFirestore.instance.doc('users/$id');
  Future<void> saveInfo() async {
    await fireStoreRef.set(toMap());
  }
  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'email': email,
    };
  }
}