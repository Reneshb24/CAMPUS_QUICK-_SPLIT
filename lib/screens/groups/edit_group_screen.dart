import 'package:flutter/material.dart';

import '../../models/group.dart';

class EditGroupScreen extends StatefulWidget {
  final GroupData group;

  const EditGroupScreen({
    super.key,
    required this.group,
  });

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  final TextEditingController _memberController = TextEditingController();

  late List<String> _members;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.group.name,
    );

    _descriptionController = TextEditingController(
      text: widget.group.description,
    );

    _members = List<String>.from(
      widget.group.members,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _memberController.dispose();

    super.dispose();
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // ADD MEMBER
  // ============================================================

  void _addMember() {
    final member = _memberController.text.trim();

    if (member.isEmpty) {
      _showMessage('Enter a member name');
      return;
    }

    final alreadyExists = _members.any(
      (existingMember) => existingMember.toLowerCase() == member.toLowerCase(),
    );

    if (alreadyExists) {
      _showMessage('This member already exists');
      return;
    }

    setState(() {
      _members.add(member);
      _memberController.clear();
    });
  }

  // ============================================================
  // REMOVE MEMBER
  // ============================================================

  Future<void> _removeMember(String member) async {
    if (_members.length <= 1) {
      _showMessage(
        'A group must have at least one member',
      );
      return;
    }

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Member?',
          ),
          content: Text(
            'Are you sure you want to remove $member from this group?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (shouldRemove != true) {
      return;
    }

    setState(() {
      _members.remove(member);
    });
  }

  // ============================================================
  // SAVE GROUP
  // ============================================================

  void _saveGroup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_members.isEmpty) {
      _showMessage(
        'Add at least one member',
      );
      return;
    }

    final updatedGroup = GroupData(
      id: widget.group.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      members: _members,
      createdAt: widget.group.createdAt,
    );

    Navigator.pop(
      context,
      updatedGroup,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Group',
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
              // =================================================
              // HEADER
              // =================================================

              Text(
                'Edit Group',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Update your group information and members.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 28),

              // =================================================
              // GROUP NAME
              // =================================================

              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  hintText: 'Example: College Friends',
                  prefixIcon: Icon(
                    Icons.group_rounded,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a group name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // =================================================
              // DESCRIPTION
              // =================================================

              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Example: Expenses for our college trip',
                  prefixIcon: Icon(
                    Icons.description_outlined,
                  ),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // =================================================
              // MEMBERS TITLE
              // =================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Members',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${_members.length} members',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Add or remove members from the group.',
              ),

              const SizedBox(height: 16),

              // =================================================
              // ADD MEMBER
              // =================================================

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _memberController,
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) {
                        _addMember();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Member name',
                        hintText: 'Enter name',
                        prefixIcon: Icon(
                          Icons.person_add_alt_rounded,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    width: 56,
                    child: FilledButton(
                      onPressed: _addMember,
                      child: const Icon(
                        Icons.add_rounded,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // MEMBER LIST
              // =================================================

              ..._members.map(
                (member) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Text(
                              member.isNotEmpty ? member[0].toUpperCase() : '?',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              member,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove member',
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                            ),
                            onPressed: () {
                              _removeMember(member);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // =================================================
              // SAVE BUTTON
              // =================================================

              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saveGroup,
                  icon: const Icon(
                    Icons.save_rounded,
                  ),
                  label: const Text(
                    'Save Changes',
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
