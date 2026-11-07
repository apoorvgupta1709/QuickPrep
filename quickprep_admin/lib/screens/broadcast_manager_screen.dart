import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_broadcast_provider.dart';
import '../core/theme.dart';

class BroadcastManagerScreen extends StatefulWidget {
  const BroadcastManagerScreen({super.key});

  @override
  State<BroadcastManagerScreen> createState() => _BroadcastManagerScreenState();
}

class _BroadcastManagerScreenState extends State<BroadcastManagerScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _selectedTag = 'Question of the Day';
  bool _isPinned = false;

  final List<String> _tags = [
    'Question of the Day',
    'Feature Update',
    'Company Pack Release',
    'Special Promo',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _sendBroadcast(AdminBroadcastProvider provider) async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and announcement body.')),
      );
      return;
    }

    await provider.createBroadcast(
      title: title,
      body: body,
      tag: _selectedTag,
      isPinned: _isPinned,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📢 Announcement broadcasted to all QuickPrep users!'),
          backgroundColor: AdminTheme.success,
        ),
      );
      _titleCtrl.clear();
      _bodyCtrl.clear();
      setState(() => _isPinned = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final broadcastProvider = Provider.of<AdminBroadcastProvider>(context);
    final history = broadcastProvider.broadcasts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast & Notifications Manager'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Push "Question of the Day" & Announcements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedTag,
                              decoration: const InputDecoration(
                                labelText: 'Broadcast Type',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: _tags.map((t) {
                                return DropdownMenuItem(value: t, child: Text(t));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedTag = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Row(
                            children: [
                              const Text('Pin on Top:'),
                              Switch(
                                value: _isPinned,
                                activeThumbColor: AdminTheme.primary,
                                onChanged: (val) => setState(() => _isPinned = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notification / Announcement Title',
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'e.g. 🔥 Question of the Day: Consistent Hashing',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _bodyCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Announcement Message Body',
                          border: OutlineInputBorder(),
                          hintText: 'Write announcement text or interview concept summary...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _sendBroadcast(broadcastProvider),
                          icon: const Icon(Icons.send),
                          label: const Text('Send Broadcast to All Users'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Broadcast History (${history.length} Sent)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              ...history.map((b) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: b.isPinned
                          ? Colors.amber.withAlpha(40)
                          : AdminTheme.primary.withAlpha(40),
                      child: Icon(
                        b.isPinned ? Icons.push_pin : Icons.campaign,
                        color: b.isPinned ? Colors.amber : AdminTheme.primaryLight,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      b.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(b.body, style: const TextStyle(fontSize: 12.5)),
                        const SizedBox(height: 4),
                        Text(
                          '${b.tag} • ${b.createdAt.day}/${b.createdAt.month}/${b.createdAt.year}',
                          style: TextStyle(fontSize: 11, color: AdminTheme.darkTextSecondary),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                      onPressed: () => broadcastProvider.deleteBroadcast(b.id),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
