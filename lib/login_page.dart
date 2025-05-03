import 'package:ff_firetodo/home_page.dart';
import 'package:ff_firetodo/reg_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget{

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Create Account",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
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


          ElevatedButton(onPressed: ()async{

            String email = emailController.text;
            String pass = passController.text;

            FirebaseAuth fireAuth = FirebaseAuth.instance;

            try{

            UserCredential userCred = await  fireAuth.signInWithEmailAndPassword(email: email, password: pass);

            if(userCred != null){

              SharedPreferences prefs = await  SharedPreferences.getInstance();
              
              prefs.setString("UID", userCred.user!.uid);

              Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));

            }

            } on FirebaseAuthException catch (e){
              if (e.code == 'user-not-found') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No user found for that email.")));
              } else if (e.code == 'wrong-password') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong password provided for that user.")));
              }
            }
            catch(e){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }





          }, child: Text("Login")),
          SizedBox(height: 15,),

          InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>RegPage()));
              },
              child: Text("Don't have an account, Register now!!",style:TextStyle(fontSize:14,color: Colors.grey),))
        ],
      ),
    );
  }

}