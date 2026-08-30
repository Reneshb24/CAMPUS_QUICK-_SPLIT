import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../models/group.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({
    super.key,
  });

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _memberController = TextEditingController();

  final List<String> members = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _memberController.dispose();

    super.dispose();
  }

  void _addMember() {
    final name = _memberController.text.trim();

    if (name.isEmpty) {
      return;
    }

    final alreadyExists = members.any(
      (member) => member.toLowerCase() == name.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Member already added',
          ),
        ),
      );

      return;
    }

    setState(() {
      members.add(name);
      _memberController.clear();
    });
  }

  void _removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
  }

  void _createGroup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one member',
          ),
        ),
      );

      return;
    }

    final group = GroupData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      members: List.from(members),
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, group);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Group',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              40,
            ),
            children: [
              Text(
                'Start splitting together',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a group and add the people sharing expenses.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Example: Hostel Roommates',
                  prefixIcon: Icon(Icons.group_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a group name';
                  }

                  if (value.trim().length < 2) {
                    return 'Group name is too short';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What is this group for?',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Members',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Add everyone who will share expenses.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _memberController,
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _addMember(),
                      decoration: const InputDecoration(
                        hintText: 'Enter member name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    width: 56,
                    child: IconButton.filled(
                      onPressed: _addMember,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (members.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 34,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No members added yet',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ...members.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final member = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Card(
                      elevation: 0,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.primaryColor.withValues(alpha: 0.12),
                          child: Text(
                            member[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          member,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Remove member',
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                          onPressed: () => _removeMember(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _createGroup,
                  child: const Text(
                    'Create Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

