import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ff_firetodo/domain/model/todo_model.dart';

class FirebaseRepository{

  static FirebaseFirestore mFireStore = FirebaseFirestore.instance;
  static String collectionToDo = "todos";

  // add todo

static void addTodo(TodoModel todo){
    mFireStore.collection(collectionToDo)
        .add(todo.toDoc()).then((value){

          mFireStore.collection(collectionToDo)
              .doc(value.id)
              .update({"todoId" : value.id});

    }).onError((error,stackTrace){
      print("Error While adding Todo : $error");
      
    });
}

static Stream<QuerySnapshot<Map<String,dynamic>>> fetchAllTodo(){
  return mFireStore.collection(collectionToDo).
  snapshots();
}

// Update

static void updateTodo(TodoModel updateTodo,bool status){

  Map<String,dynamic> updateData = updateTodo.toDoc();

  if(status){
    updateData["completedAt"] = DateTime.now().millisecondsSinceEpoch.toString();
  } else{
      updateData["completedAt"] = updateTodo.completedAt;
  }



  mFireStore.collection(collectionToDo).
        doc(updateTodo.todoId).
        set(updateData).
        catchError((error){
      print("Error updating todo : $error");
  });
}

// Delete

static void deleteTodo(String todoId){
  mFireStore.collection(collectionToDo)
      .doc(todoId).delete();

}


}