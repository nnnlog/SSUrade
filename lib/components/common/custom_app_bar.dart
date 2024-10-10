import 'package:flutter/material.dart';

customAppBar(String title, {PreferredSize? bottom}) => AppBar(
      title: Text(title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
      backgroundColor: Colors.white,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0),
      iconTheme: IconThemeData(color: Colors.black),
      bottom: bottom,
    );
