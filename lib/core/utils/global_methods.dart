import 'package:flutter/material.dart';

class GlobalMethods{

  static String calcAge(String date){
   final dateTime =  DateTime.parse(date);

   final age = DateTime.now().year - dateTime.year;

   String ageText;
   if(age <= 10){
     ageText = '${age} سنين';
   }else {
     ageText = '${age} سنة';
    }

    return ageText;
  }
}