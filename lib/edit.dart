// Import necessary packages
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

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
    initializeUnityAds(); // Initialize Unity Ads
    _titleController = TextEditingController(text: widget.task);
    _descriptionController = TextEditingController();
    _loadDescription();
  }

  Future<void> initializeUnityAds() async {
    await UnityAds.init(
      gameId: '5122862',
      onComplete: () => print('Initialization Complete'),
      onFailed: (error, message) => print('Initialization Failed: $error $message'),
    );
  }

  Future<void> _loadDescription() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJsonString = prefs.getString('task_${widget.task}');
    if (taskJsonString != null) {
      final task = jsonDecode(taskJsonString);
      setState(() {
        _descriptionController.text = task['description'] ?? '';
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
                child: Text('Save Changes'),
                onPressed: () {
                  _saveEditedTask(context);
                },
              ),
              SizedBox(height: 20),
              UnityBannerAd(
                placementId: 'Banner_Ad',
                onLoad: (placementId) => print('Banner loaded: $placementId'),
                onClick: (placementId) => print('Banner clicked: $placementId'),
                onShown: (placementId) => print('Banner shown: $placementId'),
                onFailed: (placementId, error, message) => print('Banner Ad $placementId failed: $error $message'),
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
