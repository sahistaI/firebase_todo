
class TodoModel{
  String? todoId;
  String? title;
  String? desc;
  bool? isCompleted;
  int? priority; // 3- low (blue), 2-medium(orange), 1-high(red)
  String? assignedAt;
  String? completedAt;


   TodoModel({
     this.todoId,
     required this.title,required this.desc,
    this.isCompleted = false,
    this.priority = 1,
     required this.assignedAt,
    this.completedAt = ""});


   factory TodoModel.fromJson(Map<String,dynamic> doc){
     return TodoModel(
         todoId : doc['todoId'],
         completedAt: doc ['completedAt'],
         title: doc['title'],
         desc: doc['desc'],
         assignedAt: doc['assignedAt'],
         isCompleted: doc['isCompleted'],
         priority: doc['priority'],

     );
   }

   Map<String,dynamic> toDoc() => {
     "todoId" : todoId,
     "title" : title,
     "desc" : desc,
     "assignedAt" : assignedAt,
     "completedAt" : completedAt,
     "isCompleted" : isCompleted,
     "priority" : priority,
   };



}