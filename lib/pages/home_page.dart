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

  List<Map<String, String>> messages = [];
  Set<int> expandedIndexes = {};

  void _updateText(String value) {
    setState(() {
      messages.insert(0, {
        'text': value,
        'timestamp': DateFormat('yyyy-MM-dd     kk:mm').format(DateTime.now()),
      });
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
                hintText: 'type your reminders..',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                reverse: false,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return (msg['text'] ?? '').trim().isNotEmpty
                      ? Container(
                        margin: EdgeInsets.only(bottom: 12), // Reduced from 12
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ), // Reduced vertical padding
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.tealAccent),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize:
                                  MainAxisSize.min, // Minimize row height
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  msg['timestamp'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    height: 1.0, // Tight line height
                                  ),
                                ),
                                SizedBox(width: 10),
                                if ((msg['text'] ?? '').length > 60)
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (expandedIndexes.contains(index)) {
                                            expandedIndexes.remove(index);
                                          } else {
                                            expandedIndexes.add(index);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        child: Icon(
                                          expandedIndexes.contains(index)
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                Spacer(),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => SimpleDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              children: [
                                                SimpleDialogOption(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    print("Edit clicked");
                                                  },
                                                  child: Text('Edit'),
                                                ),
                                                SimpleDialogOption(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    print("Delete clicked");
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.more_horiz,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5), // Reduced from 5
                            Text(
                              msg['text'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines:
                                  expandedIndexes.contains(index) ? null : 2,
                              overflow:
                                  expandedIndexes.contains(index)
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                      : SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
