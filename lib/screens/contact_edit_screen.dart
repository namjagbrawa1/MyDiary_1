import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/app_provider.dart';
import '../models/topic.dart';
import '../models/contact.dart';

class ContactEditScreen extends StatefulWidget {
  final Topic topic;
  final Contact? contact; // null for new contact

  const ContactEditScreen({
    super.key,
    required this.topic,
    this.contact,
  });

  @override
  State<ContactEditScreen> createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends State<ContactEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _photoPath;
  bool _isLoading = false;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phoneNumber ?? '';
      _photoPath = widget.contact!.photo;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photoPath = pickedFile.path;
      });
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      final contact = Contact(
        id: _isEditing ? widget.contact!.id : null,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        photo: _photoPath,
        topicId: widget.topic.id!,
      );

      if (_isEditing) {
        await appProvider.updateContact(contact);
      } else {
        await appProvider.addContact(contact);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Contact updated successfully!' 
                : 'Contact saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Contact' : 'New Contact'),
        backgroundColor: Color(widget.topic.color),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _saveContact,
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo section
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(widget.topic.color),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _photoPath != null && File(_photoPath!).existsSync()
                        ? Image.file(
                            File(_photoPath!),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Color(widget.topic.color).withOpacity(0.1),
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Color(widget.topic.color),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Center(
              child: Text(
                'Tap to add photo',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Phone field
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 32),
            
            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(widget.topic.color),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isLoading 
                    ? 'Saving...' 
                    : (_isEditing ? 'Update Contact' : 'Save Contact'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}