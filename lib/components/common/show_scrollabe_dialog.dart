import 'package:flutter/material.dart';

void showScrollableDialog(BuildContext context, List<Widget> widgets) => showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setStateDialog) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 20, 15),
              child: ListView(
                shrinkWrap: true,
                children: widgets,
              ),
            ),
          );
        });
      },
    );
