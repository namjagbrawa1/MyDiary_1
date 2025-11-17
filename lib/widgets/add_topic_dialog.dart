import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../providers/app_provider.dart';
import '../models/topic.dart';


class AddTopicDialog extends StatefulWidget {
  final Topic? topic; // For editing existing topic

  const AddTopicDialog({super.key, this.topic});

  @override
  State<AddTopicDialog> createState() => _AddTopicDialogState();
}

class _AddTopicDialogState extends State<AddTopicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subtitleController = TextEditingController();
  
  int _selectedType = Topic.typeDiary;
  Color _selectedColor = const Color(0xFF2196F3);
  
  bool get _isEditing => widget.topic != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      _nameController.text = widget.topic!.name;
      _subtitleController.text = widget.topic!.subtitle ?? '';
      _selectedType = widget.topic!.type;
      _selectedColor = Color(widget.topic!.color);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTopic() async {
    if (!_formKey.currentState!.validate()) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      final topic = Topic(
        id: _isEditing ? widget.topic!.id : null,
        name: _nameController.text.trim(),
        type: _selectedType,
        subtitle: _subtitleController.text.trim().isEmpty 
            ? null 
            : _subtitleController.text.trim(),
        color: _selectedColor.value,
        order: _isEditing ? widget.topic!.order : appProvider.topics.length,
      );

      if (_isEditing) {
        await appProvider.updateTopic(topic);
      } else {
        await appProvider.addTopic(topic);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Topic updated successfully!' 
                : 'Topic created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Topic' : 'Add New Topic'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Topic name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Topic Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a topic name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Topic subtitle
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Topic type
              DropdownButtonFormField<int>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Topic Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: Topic.typeDiary,
                    child: Row(
                      children: [
                        Icon(Icons.book),
                        SizedBox(width: 8),
                        Text('Diary'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Topic.typeMemo,
                    child: Row(
                      children: [
                        Icon(Icons.note),
                        SizedBox(width: 8),
                        Text('Memo'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: Topic.typeContacts,
                    child: Row(
                      children: [
                        Icon(Icons.people),
                        SizedBox(width: 8),
                        Text('Contacts'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Color picker
              InkWell(
                onTap: _showColorPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Tap to choose color'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTopic,
          child: Text(_isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}