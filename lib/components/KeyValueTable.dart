import 'package:flutter/material.dart';

class KeyValueTable extends StatefulWidget {
  final Map<String, String> map;

  const KeyValueTable({super.key, required this.map});

  @override
  State<StatefulWidget> createState() => _KeyValueTableSate();
}

class _KeyValueTableSate extends State<KeyValueTable> {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: const Color.fromRGBO(0, 0, 0, .5),
      ),
      children: widget.map.keys
          .map((e) => TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: SelectableText(
                        e,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: SelectableText(
                        widget.map[e]!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }
}
