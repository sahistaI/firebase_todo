import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/util_helper.dart';

class OutlineCustomBtn extends StatelessWidget{

  VoidCallback? onPressed;
  String title;
  double mWidth;

  OutlineCustomBtn({required this.onPressed,required this.title,this.mWidth=140});

  @override
  Widget build(BuildContext context) {
    return
      SizedBox(
        width: mWidth,
        child: OutlinedButton(onPressed: onPressed
            , child: Text(title,style: mTextStyleBold14(mColor: Colors.blue),),
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: BorderSide(
                width: 1.0,
                color: Colors.blue
            )
        )),
      );
  }
}