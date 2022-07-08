import 'package:flutter/material.dart';
import 'package:ssurade/globals.dart' as globals;

customAppBar(String title) => AppBar(
      title: Text(title, style: TextStyle(color: globals.isLightMode ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
      backgroundColor: globals.isLightMode ? Colors.white : Colors.black,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0),
      iconTheme: IconThemeData(color: globals.isLightMode ? Colors.black : Colors.white),
    );
