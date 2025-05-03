import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ff_firetodo/domain/model/todo_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseRepository{

  static FirebaseFirestore mFireStore = FirebaseFirestore.instance;
  static String collectionToDo = "todos";

  // add todo

static void addTodo(TodoModel todo){

  try{

  String uid = FirebaseAuth.instance.currentUser!.uid;
  Map<String,dynamic> todoData = todo.toDoc();
  todoData['userId'] = uid;
  
    mFireStore.collection(collectionToDo)
        .add(todoData).then((value){

      mFireStore.collection(collectionToDo)
          .doc(value.id)
          .update({"todoId" : value.id});

    }).onError((error,stackTrace){
      print("Error While adding Todo : $error");

    });

  } catch(e){
    print("Error while adding Todo: $e");

  }


}

static Stream<QuerySnapshot<Map<String,dynamic>>> fetchAllTodo(){
  String uid = FirebaseAuth.instance.currentUser!.uid;
  return mFireStore.collection(collectionToDo).
  where("userId",isEqualTo: uid).
  where("completedAt",isEqualTo: null).snapshots();
}

// Update

static void updateTodo(TodoModel updateTodo,bool status) {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  mFireStore.collection(collectionToDo).
  doc(updateTodo.todoId).
  get().
  then((docSnapshot) {
    if (docSnapshot.exists && docSnapshot['userId'] == uid) {
      Map<String, dynamic> updateData = updateTodo.toDoc();
      updateData["userId"] = uid;
      if (status) {
        updateData["completedAt"] = DateTime
            .now()
            .millisecondsSinceEpoch
            .toString();
      } else {
        updateData["completedAt"] = updateTodo.completedAt;
      }
      mFireStore.collection(collectionToDo).
      doc(updateTodo.todoId).
      set(updateData).
      catchError((error){
        print("Error updating todo : $error");
      });
    } else {
      print("Unauthorized: Cannot update this todo");
    }
  }). catchError((error){
    print("Error Fetching todo for update: $error");
  });


}

// Delete

static void deleteTodo(String todoId){

  String uid = FirebaseAuth.instance.currentUser!.uid;
  mFireStore.collection(collectionToDo)
      .doc(todoId).
        get().then((docSnapshot){
          if(docSnapshot.exists && docSnapshot['userId'] == uid){
            mFireStore.collection(collectionToDo)
                .doc(todoId).delete().catchError((error){
                  print("Error deleting todo: $error");
            });
          } else {
            print("Unauthorized: Cannot delete this todo");
          }
  }).catchError((error){
    print("Error fetching todo for delete : $error");
  });

}


}