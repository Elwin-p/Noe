import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  String _displayText = '';
  String _timestamp = '';

  void _updateText(String value) {
    setState(() {
      _displayText = value;
      _timestamp = DateFormat('yyyy-MM-dd     kk:mm').format(DateTime.now());
      _controller.clear(); //
    });
  }

  void _showKeyboard() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Noe"),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.keyboard), onPressed: _showKeyboard),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onSubmitted: _updateText,
              focusNode: _focusNode,
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'type what u wanna do..',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 20),
            _displayText.trim().isNotEmpty
                ? Container(
                  alignment: Alignment.bottomLeft,
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.tealAccent),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _timestamp,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _displayText,
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
