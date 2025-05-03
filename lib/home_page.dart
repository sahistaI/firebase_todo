import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ff_firetodo/app_widget/outline_custom_btn.dart';
import 'package:ff_firetodo/firebase_repo/firebase_repository.dart';
import 'package:ff_firetodo/login_page.dart';
import 'package:ff_firetodo/utils/util_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/model/todo_model.dart';

class Homepage extends StatefulWidget{


  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUID();
  }

  void getUID()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString("UID");
    setState(() {

    });
  }

  var titleController = TextEditingController();

  var descController = TextEditingController();

  String selectedPriority = "High";

  List<TodoModel> listTodo = [];

  List<String> listPriority = ["High", "Medium", "Low" ];

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title:
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               RichText(
                 textAlign: TextAlign.start,
                 text: TextSpan(
                   text:"ToDO ",style: mTextStyleBold18(),
                   children: [
                     TextSpan(text: "Manager",style: mTextStyleBold18(mColor: Colors.blue))
                   ]
                 ),
               ),
               InkWell(
                   onTap: ()async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.remove("UID");

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                   },

                   child: Icon(Icons.logout_outlined,size: 30,)),
             ],
           ),

     ),
     body: Padding(
       padding: const EdgeInsets.all(8.0),
       child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
         stream: FirebaseRepository.fetchAllTodo(),
         builder: (_,snapshot){
           if(snapshot.connectionState == ConnectionState.waiting){
             return Center(child: CircularProgressIndicator(),);
           }

           listTodo.clear();

           for(QueryDocumentSnapshot<Map<String,dynamic>> eachDoc in snapshot.data!.docs){
             listTodo.add(TodoModel.fromJson(eachDoc.data()));
           }

           //First: sort by isCompleted, then by priority (H,M,L)
        /*   listTodo.sort((a,b){
             if(a.isCompleted != b.isCompleted){
               return b.priority!.compareTo(a.priority!);
             }
             return (a.isCompleted! ? 1 :0).compareTo(b.isCompleted! ? 1 :0);

           });*/
           listTodo.sort((a, b) {
             // First, sort by completion status: completed todos should be at the end
             if (a.isCompleted != b.isCompleted) {
               return a.isCompleted! ? 1 : -1;  // Completed todos go to the end of the list
             }

             // Then, sort by priority in ascending order: Low -> Medium -> High
             return b.priority!.compareTo(a.priority!);  // Ascending priority order
           });



           return
             listTodo.isNotEmpty ? ListView.builder(
               itemCount: listTodo.length,                      
               itemBuilder: (_,index){

                var myFormat = DateFormat.yMMMMEEEEd();

                var assignTime = myFormat.format(DateTime.fromMillisecondsSinceEpoch(int.parse(listTodo[index].assignedAt!)));
                var completedTime = listTodo[index].completedAt != "" ? myFormat.format(DateTime.fromMillisecondsSinceEpoch(int.parse(listTodo[index].completedAt!))) : "";


                 return KeyedSubtree(
                   key: ValueKey(listTodo[index].todoId),
                   child: Dismissible(
                     key: Key(listTodo[index].todoId ?? index.toString()),
                     direction: DismissDirection.endToStart,
                     background: Container(
                       alignment: Alignment.centerRight,
                       color: Colors.red,
                       padding: EdgeInsets.only(right: 20),
                       child: Icon(Icons.delete,color: Colors.white,),
                     ),
                     confirmDismiss:(direction)async{
                       return await showDialog(context: context, builder: (context)=>
                       AlertDialog(
                         title: Text("Delete Todo"),
                         content: Text("Are you sure you want to delete this todo?"),
                         actions: [
                           TextButton(onPressed: (){
                             Navigator.of(context).pop(false);
                           }, child: Text("Cancel")),
                           TextButton(onPressed: (){
                             Navigator.of(context).pop(true);
                           }, child: Text("Delete")),
                         ],
                       ));
                     },
                     onDismissed: (direction){
                       FirebaseRepository.deleteTodo(listTodo[index].todoId!);
                     },
                     child: Card(
                       elevation: 7,
                       color: getBackGroundColor(listTodo[index].priority!),
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(16)
                       ),
                       child: Stack(
                         children: [
                           Column(
                             children: [
                               CheckboxListTile(
                                 controlAffinity: ListTileControlAffinity.trailing,
                                 side: BorderSide(
                                     color: Colors.white,
                                     width: 2
                                 ),
                                 value: listTodo[index].isCompleted,
                                 onChanged: listTodo[index].isCompleted==true ? null : (value){

                                   if(listTodo[index].todoId !=null){

                                     TodoModel updateTodo = TodoModel(
                                        todoId: listTodo[index].todoId ,
                                         title: listTodo[index].title,
                                         desc: listTodo[index].desc,
                                         assignedAt: listTodo[index].assignedAt,
                                        isCompleted: value ?? false,
                                         completedAt: listTodo[index].completedAt,
                                         priority: listTodo[index].priority
                                          );

                                     FirebaseRepository.updateTodo(updateTodo,value!);
                                   }
                                   setState(() {
                                     listTodo[index].isCompleted = value;
                                   });

                                 },
                                 title: Text(listTodo[index].title!,style: mTextStyle18(mColor: Colors.white).
                                 copyWith(decoration: listTodo[index].isCompleted! ?
                                 TextDecoration.lineThrough : TextDecoration.none)),
                                 subtitle: Text(listTodo[index].desc!,style: mTextStyle16(mColor: Colors.white).copyWith(
                                     decoration: listTodo[index].isCompleted! ?
                                     TextDecoration.lineThrough : TextDecoration.none
                                 ),

                                 ),
                               ),
                               Padding(
                                 padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 11.0),
                                 child: Row(
                                   children: [
                                     RichText(text: TextSpan(
                                       text: "Assigned at: ", style: mTextStyle14(mColor: Colors.white,
                                         mFontweight: FontWeight.bold),
                                       children: [
                                         TextSpan(text: assignTime,style: mTextStyle14(mColor: Colors.white))
                                       ]
                                     ))
                                   ],
                                 ),
                               ),
                             listTodo[index].isCompleted == true && completedTime != "" ?   Padding(
                                 padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 11.0),
                                 child: Row(
                                   children: [
                                     RichText(text: TextSpan(
                                       text: "Completed at: ", style: mTextStyle14(mColor: Colors.white,
                                         mFontweight: FontWeight.bold),
                                       children: [
                                         TextSpan(text: completedTime,style: mTextStyle14(mColor: Colors.white))
                                       ]
                                     ))
                                   ],
                                 ),
                               ): Container()
                             ],
                           ),
                           if(!(listTodo[index].isCompleted ?? false))
                           Positioned(
                               top: 10,
                               right: 5,
                               bottom: 80,
                     
                               child: InkWell(
                                   onTap: (){
                                     showModalBottomSheet(context: context,
                                         isScrollControlled: true,
                                         builder: (_){
                                       return getBottomSheetContent(context,todoUpdate: listTodo[index]);
                                     });
                                   },
                                   child: Icon(Icons.edit,color: Colors.white,)))
                     
                         ],
                       ),
                     ),
                   ),
                 );
               }) :
           Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text("No ToDo's Yet",style: mTextStyle18(mColor: Colors.grey),),
                 SizedBox(height: 7,),

                 OutlineCustomBtn(onPressed: (){
                   showModalBottomSheet(
                       context: context,
                       isScrollControlled: true,
                       builder: (_){
                         return getBottomSheetContent(context);
                       });
                 }, title: "Add Now +")

               ],
             ),
           );
         },

       )


     ),

     floatingActionButton: FloatingActionButton(
       onPressed: (){
         showModalBottomSheet(context: context, builder: (_){
        return getBottomSheetContent(context);
         });
       },
       foregroundColor: Colors.blue,
       backgroundColor: Colors.white,
       splashColor: Colors.blue,
       elevation: 7,
       child: Icon(Icons.add),
     ),
   );
  }

  Widget getBottomSheetContent(BuildContext context, {TodoModel? todoUpdate}){

    if(todoUpdate !=null){
      titleController.text = todoUpdate.title!;
      descController.text = todoUpdate.desc!;
      selectedPriority = todoUpdate.priority == 3 ? "High" : (todoUpdate.priority == 2 ? "Medium" : "Low");
    } else {
      titleController.clear();
      descController.clear();
      selectedPriority = "High";
    }

    return
      AnimatedPadding(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
            left: 11,top: 11,right: 11,bottom: 11+ MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
          height: MediaQuery.of(context).size.height *0.5 + MediaQuery.of(context).viewInsets.bottom,
          child: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios_rounded,color: Colors.blue,size: 18,)),
                  SizedBox(width: 11,),
                  Text(todoUpdate !=null ?"Update Todo" : "Add ToDo",style: mTextStyleBold18(mColor: Colors.blue)),

                ],
              ),
              SizedBox(height: 21,),

              TextField(
                controller: titleController,
                style: mTextStyle16(),
                decoration: InputDecoration(
                  hintText: "Enter title here",
                  label: Text("Title",style: mTextStyle18(mColor:Colors.blue),),
                  hintStyle: mTextStyle18(mColor: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(
                      color: Colors.blue
                    )
                  )
                ),
              ),

              SizedBox(height: 11,),

              TextField(
                controller: descController,
                style: mTextStyle16(),
                decoration: InputDecoration(
                    hintText: "Enter desc here",
                    label: Text("Desc",style: mTextStyle18(mColor:Colors.blue),),
                    hintStyle: mTextStyle18(mColor: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: BorderSide(
                            color: Colors.blue
                        )
                    )
                ),
              ),

              SizedBox(height: 11,),

              DropdownMenu(
                width: MediaQuery.of(context).size.width-22,
                  textStyle: mTextStyle18(),
                  onSelected: (value){
                 setState(() {
                   selectedPriority = value!;
                 });
                  },
                  trailingIcon: Icon(Icons.arrow_drop_down_circle_rounded,color: Colors.blue,),
                  selectedTrailingIcon:Icon(Icons.add,color: Colors.blue,) ,
                  label: Text(selectedPriority.isNotEmpty ? "Priority" : selectedPriority,style: mTextStyle18(),),

                  dropdownMenuEntries: listPriority.map((priority)=>DropdownMenuEntry(
                      label: priority,
                    value:priority,
                  style: ButtonStyle(
                    textStyle: WidgetStateTextStyle.resolveWith((states)=>mTextStyle16())
                  )
                  )).toList(),
              ),

              SizedBox(height: 15,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlineCustomBtn(onPressed: (){
                    var todoModel =   TodoModel(
                      todoId: todoUpdate?.todoId,
                        title: titleController.text.toString(),
                        desc: descController.text.toString(),
                        priority: selectedPriority == "High" ? 3 : (selectedPriority == "Medium" ? 2 : 1 ),
                        assignedAt: todoUpdate?.assignedAt ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                        isCompleted: todoUpdate?.isCompleted ?? false );


                    if(todoUpdate !=null){
                      FirebaseRepository.updateTodo(todoModel, todoModel.isCompleted ?? false);

                    } else {
                      FirebaseRepository.addTodo(todoModel);
                      setState(() {
                        listTodo.add(todoModel); // Add locally
                        listTodo.sort((a, b) {
                          if (a.isCompleted != b.isCompleted) {
                            return a.isCompleted! ? 1 : -1;
                          }
                          return b.priority!.compareTo(a.priority!); // High to Low
                        });
                      });
                    }


                    Navigator.pop(context);

                  } , title: todoUpdate!=null ? "Update" : "Add"),
                  OutlineCustomBtn(onPressed: (){
                    Navigator.pop(context);
                  } , title: "Cancel"),
                ],
              )


            ],
          ),
              ),
        ),
      );
  }

  Color getBackGroundColor(int priority){
    if(priority==3){
      return Colors.blue;
    } else if(priority == 2){
      return Colors.orange;
    } else{
      return Colors.red;
    }
  }




}