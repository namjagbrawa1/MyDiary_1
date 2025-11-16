import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';

import '../providers/app_provider.dart';
import '../models/topic.dart';
import '../models/diary_entry.dart';
import '../models/diary_item.dart';
import '../utils/theme_manager.dart';

class DiaryEditScreen extends StatefulWidget {
  final Topic topic;
  final DiaryEntry? entry; // null for new entry

  const DiaryEditScreen({
    super.key,
    required this.topic,
    this.entry,
  });

  @override
  State<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  int _selectedMood = DiaryEntry.moodNeutral;
  int _selectedWeather = DiaryEntry.weatherSunny;
  List<DiaryItem> _diaryItems = [];
  bool _isLoading = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      _titleController.text = widget.entry!.title;
      _locationController.text = widget.entry!.location ?? '';
      _selectedDate = widget.entry!.time;
      _selectedMood = widget.entry!.mood;
      _selectedWeather = widget.entry!.weather;
      _loadDiaryItems();
    } else {
      // Add initial text item for new diary
      _diaryItems.add(DiaryItem(
        type: DiaryItem.typeText,
        position: 0,
        content: '',
        diaryId: 0, // Will be set when saving
      ));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadDiaryItems() async {
    if (!_isEditing) return;
    
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.loadDiaryItems(widget.entry!.id!);
    if (mounted) {
      setState(() {
        _diaryItems = List.from(appProvider.currentDiaryItems);
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      
      if (time != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final location = [
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        
        setState(() {
          _locationController.text = location;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
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

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _diaryItems.add(DiaryItem(
          type: DiaryItem.typePhoto,
          position: _diaryItems.length,
          content: pickedFile.path,
          diaryId: _isEditing ? widget.entry!.id! : 0,
        ));
      });
    }
  }

  void _addTextItem() {
    setState(() {
      _diaryItems.add(DiaryItem(
        type: DiaryItem.typeText,
        position: _diaryItems.length,
        content: '',
        diaryId: _isEditing ? widget.entry!.id! : 0,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _diaryItems.removeAt(index);
      // Update positions
      for (int i = 0; i < _diaryItems.length; i++) {
        _diaryItems[i] = _diaryItems[i].copyWith(position: i);
      }
    });
  }

  void _updateItemContent(int index, String content) {
    setState(() {
      _diaryItems[index] = _diaryItems[index].copyWith(content: content);
    });
  }

  Future<void> _saveDiary() async {
    if (!_formKey.currentState!.validate()) return;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      final entry = DiaryEntry(
        id: _isEditing ? widget.entry!.id : null,
        time: _selectedDate,
        title: _titleController.text.trim(),
        mood: _selectedMood,
        weather: _selectedWeather,
        attachment: null, // Will be handled by diary items
        topicId: widget.topic.id!,
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
      );

      int diaryId;
      if (_isEditing) {
        await appProvider.updateDiaryEntry(entry);
        diaryId = widget.entry!.id!;
      } else {
        // For new entries, we need to get the ID after insertion
        final db = appProvider;
        await db.addDiaryEntry(entry);
        // Get the latest entry (should be the one we just added)
        final entries = await db.searchDiaryEntries(_titleController.text.trim());
        diaryId = entries.first.id!;
      }

      // Save diary items
      for (final item in _diaryItems) {
        if (item.content.trim().isNotEmpty) {
          final updatedItem = item.copyWith(diaryId: diaryId);
          if (item.id == null) {
            await appProvider.addDiaryItem(updatedItem);
          } else {
            await appProvider.updateDiaryItem(updatedItem);
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Diary updated successfully!' 
                : 'Diary saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving diary: $e'),
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
        title: Text(_isEditing ? 'Edit Diary' : 'New Diary'),
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
              onPressed: _saveDiary,
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date, mood, weather row
                  Row(
                    children: [
                      // Date
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Mood
                      DropdownButton<int>(
                        value: _selectedMood,
                        items: [
                          DropdownMenuItem(
                            value: DiaryEntry.moodHappy,
                            child: Icon(ThemeManager.getMoodIcon(DiaryEntry.moodHappy)),
                          ),
                          DropdownMenuItem(
                            value: DiaryEntry.moodNeutral,
                            child: Icon(ThemeManager.getMoodIcon(DiaryEntry.moodNeutral)),
                          ),
                          DropdownMenuItem(
                            value: DiaryEntry.moodSad,
                            child: Icon(ThemeManager.getMoodIcon(DiaryEntry.moodSad)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMood = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Weather
                      DropdownButton<int>(
                        value: _selectedWeather,
                        items: [
                          DropdownMenuItem(
                            value: DiaryEntry.weatherSunny,
                            child: Icon(ThemeManager.getWeatherIcon(DiaryEntry.weatherSunny)),
                          ),
                          DropdownMenuItem(
                            value: DiaryEntry.weatherCloudy,
                            child: Icon(ThemeManager.getWeatherIcon(DiaryEntry.weatherCloudy)),
                          ),
                          DropdownMenuItem(
                            value: DiaryEntry.weatherRainy,
                            child: Icon(ThemeManager.getWeatherIcon(DiaryEntry.weatherRainy)),
                          ),
                          DropdownMenuItem(
                            value: DiaryEntry.weatherSnowy,
                            child: Icon(ThemeManager.getWeatherIcon(DiaryEntry.weatherSnowy)),
                          ),
                          DropdownMenuItem(
                            value: DiaryEntry.weatherFoggy,
                            child: Icon(ThemeManager.getWeatherIcon(DiaryEntry.weatherFoggy)),
                          ),
                          DropdownMenuItem(
                            value: DiaryEntry.weatherWindy,
                            child: Icon(ThemeManager.getWeatherIcon(DiaryEntry.weatherWindy)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedWeather = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content section
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _diaryItems.length,
                itemBuilder: (context, index) {
                  final item = _diaryItems[index];
                  
                  if (item.type == DiaryItem.typeText) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item.content,
                                decoration: const InputDecoration(
                                  hintText: 'Write your thoughts...',
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                                onChanged: (value) => _updateItemContent(index, value),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeItem(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (item.type == DiaryItem.typePhoto) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          if (File(item.content).existsSync())
                            Image.file(
                              File(item.content),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('Image not found'),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => _removeItem(index),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
            
            // Add content buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addTextItem,
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Add Text'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addPhoto,
                    icon: const Icon(Icons.photo),
                    label: const Text('Add Photo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}