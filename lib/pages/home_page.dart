import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:Noe/database/reminder_message.dart';
import 'package:Noe/database/reminder_service.dart';
import 'package:Noe/noti/noti_service.dart';

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
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Edit Reminder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            content: TextField(
              controller: editController,
              maxLines: null,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Edit your reminder...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black87, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        title: const Text(
          "Noe",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Colors.black87,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            onPressed: _showKeyboard,
            color: Colors.black87,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.schedule_rounded, size: 28),
          onPressed: () async {
            await NotiService().showMidnightCountdownNotification();
          },
          color: Colors.black87,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  // border: Border.all(color: Colors.transparent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      // Update container border when focus changes
                    });
                  },
                  child: Builder(
                    builder: (context) {
                      final hasFocus = Focus.of(context).hasFocus;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                hasFocus ? Colors.black87 : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: TextField(
                          onSubmitted: _updateText,
                          focusNode: _focusNode,
                          controller: _controller,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'What\'s on your mind?',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ), // or use StadiumBorder in container
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            hoverColor: Colors.transparent,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Reminders List
              Expanded(
                child:
                    reminders.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No reminders yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first reminder',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: reminders.length,
                          itemBuilder: (context, index) {
                            final reminder = reminders[index];
                            final timestampStr = DateFormat(
                              'MMM dd, yyyy • HH:mm',
                            ).format(reminder.timestamp);

                            return reminder.text.trim().isNotEmpty
                                ? GestureDetector(
                                  onTap: () async {
                                    final key = reminder.key;
                                    final boxReminder = ReminderService.box.get(
                                      key,
                                    );
                                    if (boxReminder != null) {
                                      boxReminder.isCompleted =
                                          !boxReminder.isCompleted;
                                      await boxReminder.save();
                                      _loadReminders();
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color:
                                            reminder.isCompleted
                                                ? Colors.grey.withOpacity(0.3)
                                                : Colors.transparent,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              timestampStr,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (reminder.text.length > 60)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (expandedIndexes
                                                        .contains(index)) {
                                                      expandedIndexes.remove(
                                                        index,
                                                      );
                                                    } else {
                                                      expandedIndexes.add(
                                                        index,
                                                      );
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    expandedIndexes.contains(
                                                          index,
                                                        )
                                                        ? Icons
                                                            .expand_less_rounded
                                                        : Icons
                                                            .expand_more_rounded,
                                                    size: 20,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => SimpleDialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        children: [
                                                          SimpleDialogOption(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                              _editReminder(
                                                                index,
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Edit',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    Colors
                                                                        .black87,
                                                              ),
                                                            ),
                                                          ),
                                                          SimpleDialogOption(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                              _deleteReminder(
                                                                index,
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.more_horiz_rounded,
                                                  size: 20,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          reminder.text,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                reminder.isCompleted
                                                    ? Colors.grey[500]
                                                    : Colors.black87,
                                            decoration:
                                                reminder.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                            height: 1.4,
                                          ),
                                          maxLines:
                                              expandedIndexes.contains(index)
                                                  ? null
                                                  : 3,
                                          overflow:
                                              expandedIndexes.contains(index)
                                                  ? TextOverflow.visible
                                                  : TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink();
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
