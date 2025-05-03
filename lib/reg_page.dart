import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ff_firetodo/domain/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegPage extends StatelessWidget{

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController passController = TextEditingController();


  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Register Page",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
          SizedBox(height: 11,),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter Your Name",
                label: Text("Name"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                focusedBorder:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),

              ),
            ),
          ),
          SizedBox(height: 11,),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Enter Your Email",
                label: Text("Email"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                focusedBorder:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),

              ),
            ),
          ),
          SizedBox(height: 11,),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: genderController,
              decoration: InputDecoration(
                hintText: "Enter Your Gender",
                label: Text("Gender"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                focusedBorder:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),

              ),
            ),
          ),
          SizedBox(height: 11,),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: passController,
              decoration: InputDecoration(
                hintText: "Enter Your Password",
                label: Text("Password"),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                focusedBorder:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),

              ),
            ),
          ),

          SizedBox(height: 11,),

          ElevatedButton(onPressed: ()async{

            String name =nameController.text;
            String email =emailController.text;
            String gender =genderController.text;
            String pass =passController.text;


            FirebaseAuth fireAuth = FirebaseAuth.instance;

            try{

              UserCredential userCred = await fireAuth.createUserWithEmailAndPassword(email: email, password: pass);

              if(userCred !=null){

                FirebaseFirestore ff = FirebaseFirestore.instance;
                ff.collection(AppConstants.Col_User).doc(userCred.user!.uid).set({
                  "name" : name,
                  "email" : email,
                  "gender" : gender,
                  "created_at" : DateTime.now().millisecondsSinceEpoch
                });

                Navigator.pop(context);
              }

            } on FirebaseAuthException catch (e){
              if (e.code == 'weak-password') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("The password provided is too weak.")),
                );
              } else if (e.code == 'email-already-in-use') {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('The account already exists for that email.'))
                );
              }
            }

            catch (e){
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()))
              );
            }




          }, child: Text("Register")),

          SizedBox(height: 15,),

          InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Text("Already have an account, Login now!!",style:TextStyle(fontSize:14,color: Colors.grey),))
        ],
      ),
   );
  }
}