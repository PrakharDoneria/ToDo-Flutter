import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateToDoScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _saveNewTask(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final newTaskTitle = _titleController.text;
    final newTaskDescription = _descriptionController.text;
    if (newTaskTitle.isNotEmpty) {
      final newTask = {
        'title': newTaskTitle,
        'description': newTaskDescription,
      };
      final jsonString = jsonEncode(newTask); // Convert to JSON string
      await prefs.setString('task_$newTaskTitle', jsonString);
      Navigator.pop(context, newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('New To-Do'),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'Title',
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.lightBackgroundGray),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 20),
              CupertinoTextField(
                controller: _descriptionController,
                placeholder: 'Description',
                maxLines: null, // Allow multiline
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.lightBackgroundGray),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text('Add To-Do'),
                onPressed: () {
                  _saveNewTask(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
