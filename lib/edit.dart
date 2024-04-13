import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditToDoScreen extends StatefulWidget {
  final String task;

  EditToDoScreen({required this.task});

  @override
  _EditToDoScreenState createState() => _EditToDoScreenState();
}

class _EditToDoScreenState extends State<EditToDoScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task);
    _descriptionController = TextEditingController(); // Initialize _descriptionController
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJsonString = prefs.getString('task_${widget.task}');
    if (taskJsonString != null) {
      final task = jsonDecode(taskJsonString);
      setState(() {
        _descriptionController.text = task['description']; // Set text directly to avoid late initialization
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Edit To-Do'),
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
                child: Text('Save Changes'),
                onPressed: () {
                  _saveEditedTask(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEditedTask(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final editedTask = {
      'title': _titleController.text,
      'description': _descriptionController.text,
    };
    final jsonString = jsonEncode(editedTask); // Convert to JSON string
    await prefs.setString('task_${widget.task}', jsonString);
    Navigator.pop(context, editedTask);
  }
}
