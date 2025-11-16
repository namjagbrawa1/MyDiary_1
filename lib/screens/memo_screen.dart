import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/topic.dart';
import '../models/memo.dart';

class MemoScreen extends StatefulWidget {
  final Topic topic;

  const MemoScreen({super.key, required this.topic});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  final TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.loadMemos(widget.topic.id!);
    });
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _addMemo() async {
    if (_memoController.text.trim().isEmpty) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final memo = Memo(
      order: appProvider.memos.length,
      content: _memoController.text.trim(),
      checked: false,
      topicId: widget.topic.id!,
    );

    try {
      await appProvider.addMemo(memo);
      _memoController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding memo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleMemo(Memo memo) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final updatedMemo = memo.copyWith(checked: !memo.checked);

    try {
      await appProvider.updateMemo(updatedMemo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating memo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMemo(Memo memo) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      await appProvider.deleteMemo(memo.id!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting memo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.name),
        backgroundColor: Color(widget.topic.color),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Add memo section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memoController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new memo...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _addMemo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addMemo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(widget.topic.color),
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Memos list
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                final memos = appProvider.memos;

                if (memos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No memos yet.\nAdd your first memo above!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: memos.length,
                  itemBuilder: (context, index) {
                    final memo = memos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: memo.checked,
                          onChanged: (_) => _toggleMemo(memo),
                          activeColor: Color(widget.topic.color),
                        ),
                        title: Text(
                          memo.content,
                          style: TextStyle(
                            decoration: memo.checked
                                ? TextDecoration.lineThrough
                                : null,
                            color: memo.checked
                                ? Colors.grey[600]
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMemo(memo),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}