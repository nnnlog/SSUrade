import 'package:flutter/material.dart';

customAppBar(String title) => AppBar(
      title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
      backgroundColor: Colors.white,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0),
      iconTheme: const IconThemeData(color: Colors.black),
    );
