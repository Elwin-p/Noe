import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noe/database/reminder_message.dart';
import 'package:noe/database/reminder_service.dart';
import 'package:noe/noti/noti_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  List<ReminderMessage> reminders = [];
  Set<int> expandedIndexes = {};

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      reminders = ReminderService.getAllReminders();
    });
  }

  void _updateText(String value) async {
    if (value.trim().isNotEmpty) {
      await ReminderService.addReminder(value);
      _controller.clear();
      _loadReminders();
    }
  }

  void _showKeyboard() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _editReminder(int index) {
    final reminder = reminders[index];
    final editController = TextEditingController(text: reminder.text);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Reminder'),
            content: TextField(
              controller: editController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Edit your reminder...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (editController.text.trim().isNotEmpty) {
                    await ReminderService.updateReminder(
                      reminder.key,
                      editController.text,
                    );
                    _loadReminders();
                  }
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteReminder(int index) async {
    final reminder = reminders[index];
    final key = reminder.key;
    await ReminderService.box.delete(key);
    _loadReminders();
    setState(() {
      expandedIndexes =
          expandedIndexes.map((i) => i > index ? i - 1 : i).toSet();
      expandedIndexes.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Noe"),
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.add), onPressed: _showKeyboard)],
        leading: IconButton(
          icon: Icon(Icons.schedule),
          onPressed: () async {
            await NotiService().showMidnightCountdownNotification();
          },
        ),
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
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  final timestampStr = DateFormat(
                    'yyyy-MM-dd     kk:mm',
                  ).format(reminder.timestamp);

                  return reminder.text.trim().isNotEmpty
                      ? GestureDetector(
                        onTap: () async {
                          final key = reminder.key;
                          final boxReminder = ReminderService.box.get(key);
                          if (boxReminder != null) {
                            boxReminder.isCompleted = !boxReminder.isCompleted;
                            await boxReminder.save();
                            _loadReminders();
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color:
                                  reminder.isCompleted
                                      ? Colors.grey.withValues(alpha: .5)
                                      : Colors.tealAccent,
                            ),
                            color:
                                reminder.isCompleted
                                    ? Colors.grey.withValues(alpha: .1)
                                    : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // GestureDetector(
                                  //   onTap: () async {
                                  //     final key = reminder.key;
                                  //     final boxReminder = ReminderService.box
                                  //         .get(key);
                                  //     if (boxReminder != null) {
                                  //       boxReminder.isCompleted =
                                  //           !boxReminder.isCompleted;
                                  //       await boxReminder.save();
                                  //       _loadReminders();
                                  //     }
                                  //   },

                                  //   child: Container(
                                  //     width: 16,
                                  //     height: 16,
                                  //     decoration: BoxDecoration(
                                  //       border: Border.all(color: Colors.teal),
                                  //       borderRadius: BorderRadius.circular(3),
                                  //       color:
                                  //           reminder.isCompleted
                                  //               ? Colors.teal
                                  //               : Colors.transparent,
                                  //     ),
                                  //     child:
                                  //         reminder.isCompleted
                                  //             ? Icon(
                                  //               Icons.check,
                                  //               size: 12,
                                  //               color: Colors.white,
                                  //             )
                                  //             : null,
                                  //   ),
                                  // ),
                                  // SizedBox(width: 8),
                                  Text(
                                    timestampStr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      height: 1.0,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  if (reminder.text.length > 60)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (expandedIndexes.contains(
                                              index,
                                            )) {
                                              expandedIndexes.remove(index);
                                            } else {
                                              expandedIndexes.add(index);
                                            }
                                          });
                                        },
                                        customBorder: const CircleBorder(),
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          child: Icon(
                                            expandedIndexes.contains(index)
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            size: 20,
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
                                                      _editReminder(index);
                                                    },
                                                    child: Text('Edit'),
                                                  ),
                                                  SimpleDialogOption(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deleteReminder(index);
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
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                reminder.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  decoration:
                                      reminder.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                  color:
                                      reminder.isCompleted ? Colors.grey : null,
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
