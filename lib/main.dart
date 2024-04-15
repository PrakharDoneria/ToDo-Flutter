import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'create.dart';
import 'edit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'To-Do List',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: ToDoListScreen(),
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    initializeUnityAds();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<dynamic> tasksList = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks = tasksList.map((task) => jsonDecode(task)).cast<Map<String, dynamic>>().toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksStringList = _tasks.map((task) => jsonEncode(task)).toList();
    await prefs.setStringList('tasks', tasksStringList);
  }

  Future<void> initializeUnityAds() async {
    await UnityAds.init(
      gameId: '5122862',
      onComplete: () => print('Initialization Complete'),
      onFailed: (error, message) => print('Initialization Failed: $error $message'),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> reversedTasks = List.from(_tasks.reversed);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('To-Do List'),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              itemCount: reversedTasks.length,
              itemBuilder: (context, index) {
                final task = reversedTasks[index];
                final title = task['title'];
                final description = task['description'] ?? '';
                final truncatedDescription = description.length > 25 ? '${description.substring(0, 25)}...' : description;
                return GestureDetector(
                  onLongPress: () {
                    _showActions(title!, index);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: CupertinoButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => EditToDoScreen(task: title!),
                          ),
                        ).then((editedTask) {
                          if (editedTask != null && editedTask['title'] != null) {
                            setState(() {
                              _tasks[index] = editedTask;
                              _saveTasks();
                            });
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title!,
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: CupertinoColors.label),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  truncatedDescription,
                                  style: TextStyle(fontSize: 16.0, color: CupertinoColors.secondaryLabel),
                                ),
                              ],
                            ),
                          ),
                          Icon(CupertinoIcons.forward, color: CupertinoColors.systemBlue),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16.0,
              child: CupertinoButton.filled(
                padding: EdgeInsets.all(12.0),
                child: Icon(CupertinoIcons.add, color: CupertinoColors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => CreateToDoScreen(),
                    ),
                  ).then((newTask) {
                    if (newTask != null && newTask['title'] != null) {
                      setState(() {
                        _tasks.add(newTask);
                        _saveTasks();
                      });
                    }
                  });
                },
              ),
            ),
            Positioned(
              bottom: 16.0,
              right: 12.0,
              child: UnityBannerAd(
                placementId: 'Banner_Ad',
                onLoad: (placementId) => print('Banner loaded: $placementId'),
                onClick: (placementId) => print('Banner clicked: $placementId'),
                onShown: (placementId) => print('Banner shown: $placementId'),
                onFailed: (placementId, error, message) => print('Banner Ad $placementId failed: $error $message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(String task, int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _editTask(task, index);
              },
              child: Text('Edit', style: TextStyle(color: CupertinoColors.systemBlue)),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _deleteTask(index);
              },
              child: Text('Delete', style: TextStyle(color: CupertinoColors.systemRed)),
              isDestructiveAction: true,
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: CupertinoColors.systemBlue)),
          ),
        );
      },
    );
  }

  void _editTask(String task, int index) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditToDoScreen(task: task),
      ),
    ).then((editedTask) {
      if (editedTask != null && editedTask['title'] != null) {
        setState(() {
          _tasks[index] = editedTask;
          _saveTasks();
        });
      }
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }
}

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
    _descriptionController = TextEditingController();
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJsonString = prefs.getString('task_${widget.task}');
    if (taskJsonString != null) {
      final task = jsonDecode(taskJsonString);
      setState(() {
        _descriptionController.text = task['description'];
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
                maxLines: null,
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.lightBackgroundGray),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text('Save Changes', style: TextStyle(color: CupertinoColors.white)),
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
    final jsonString = jsonEncode(editedTask);
    await prefs.setString('task_${widget.task}', jsonString);
    Navigator.pop(context, editedTask);
  }
}

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
      final jsonString = jsonEncode(newTask);
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
                maxLines: null,
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.lightBackgroundGray),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text('Add To-Do', style: TextStyle(color: CupertinoColors.white)),
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
