import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../models/group.dart';

class EditExpenseScreen extends StatefulWidget {
  final GroupData group;
  final ExpenseData expense;

  const EditExpenseScreen({
    super.key,
    required this.group,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;

  late DateTime _expenseDate;
  late String _category;
  String? _paidBy;

  final Set<String> _participants = {};

  late String _splitType;

  final Map<String, TextEditingController> _customSplitControllers = {};

  final Map<String, TextEditingController> _percentageSplitControllers = {};

  final Map<String, TextEditingController> _ratioSplitControllers = {};

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food',
      'icon': Icons.restaurant_rounded,
    },
    {
      'name': 'Travel',
      'icon': Icons.directions_car_rounded,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
    },
    {
      'name': 'Rent',
      'icon': Icons.home_rounded,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.expense.title,
    );

    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );

    _expenseDate = widget.expense.expenseDate;

    _category = widget.expense.category;

    if (widget.group.members.contains(widget.expense.paidBy)) {
      _paidBy = widget.expense.paidBy;
    } else if (widget.group.members.isNotEmpty) {
      _paidBy = widget.group.members.first;
    }

    for (final member in widget.expense.participants) {
      if (widget.group.members.contains(member)) {
        _participants.add(member);
      }
    }

    if (_participants.isEmpty) {
      _participants.addAll(widget.group.members);
    }

    _splitType = _normalizeSplitType(
      widget.expense.splitType,
    );

    for (final member in widget.group.members) {
      _customSplitControllers[member] = TextEditingController(
        text: widget.expense.customSplits[member]?.toStringAsFixed(2) ?? '',
      );

      _percentageSplitControllers[member] = TextEditingController(
        text: widget.expense.percentageSplits[member]?.toStringAsFixed(2) ?? '',
      );

      _ratioSplitControllers[member] = TextEditingController(
        text: widget.expense.ratioSplits[member]?.toStringAsFixed(2) ?? '',
      );
    }
  }

  // ============================================================
  // NORMALIZE SPLIT TYPE
  // ============================================================

  String _normalizeSplitType(String splitType) {
    const validTypes = [
      'equal',
      'custom',
      'percentage',
      'ratio',
    ];

    if (validTypes.contains(splitType)) {
      return splitType;
    }

    return 'equal';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();

    for (final controller in _customSplitControllers.values) {
      controller.dispose();
    }

    for (final controller in _percentageSplitControllers.values) {
      controller.dispose();
    }

    for (final controller in _ratioSplitControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // FORMAT MONEY
  // ============================================================

  String _formatMoney(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectExpenseDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (selectedDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _expenseDate = selectedDate;
    });
  }

  // ============================================================
  // ORDERED PARTICIPANTS
  // ============================================================

  List<String> get _orderedParticipants {
    return widget.group.members
        .where(
          (member) => _participants.contains(member),
        )
        .toList();
  }

  // ============================================================
  // ENTERED CUSTOM TOTAL
  // ============================================================

  double get _enteredCustomTotal {
    double total = 0.0;

    for (final member in _participants) {
      final double value = double.tryParse(
            _customSplitControllers[member]?.text.trim() ?? '',
          ) ??
          0.0;

      total += value;
    }

    return total;
  }

  // ============================================================
  // ENTERED PERCENTAGE TOTAL
  // ============================================================

  double get _enteredPercentageTotal {
    double total = 0.0;

    for (final member in _participants) {
      final double value = double.tryParse(
            _percentageSplitControllers[member]?.text.trim() ?? '',
          ) ??
          0.0;

      total += value;
    }

    return total;
  }

  // ============================================================
  // ENTERED RATIO TOTAL
  // ============================================================

  double get _enteredRatioTotal {
    double total = 0.0;

    for (final member in _participants) {
      final double value = double.tryParse(
            _ratioSplitControllers[member]?.text.trim() ?? '',
          ) ??
          0.0;

      total += value;
    }

    return total;
  }

  // ============================================================
  // VALIDATE CUSTOM SPLITS
  // ============================================================

  bool _validateCustomSplits(
    double expenseAmount,
  ) {
    if (_participants.isEmpty) {
      _showMessage(
        'Select at least one participant',
      );
      return false;
    }

    double total = 0.0;

    for (final member in _orderedParticipants) {
      final text = _customSplitControllers[member]?.text.trim() ?? '';

      final amount = double.tryParse(text);

      if (amount == null || amount < 0) {
        _showMessage(
          'Enter a valid amount for $member',
        );
        return false;
      }

      total += amount;
    }

    const double tolerance = 0.01;

    if ((total - expenseAmount).abs() > tolerance) {
      _showMessage(
        'Custom split total must equal '
        '${_formatMoney(expenseAmount)}',
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // VALIDATE PERCENTAGE SPLITS
  // ============================================================

  bool _validatePercentageSplits() {
    if (_participants.isEmpty) {
      _showMessage(
        'Select at least one participant',
      );
      return false;
    }

    double total = 0.0;

    for (final member in _orderedParticipants) {
      final text = _percentageSplitControllers[member]?.text.trim() ?? '';

      final percentage = double.tryParse(text);

      if (percentage == null || percentage < 0 || percentage > 100) {
        _showMessage(
          'Enter a valid percentage for $member',
        );
        return false;
      }

      total += percentage;
    }

    const double tolerance = 0.01;

    if ((total - 100.0).abs() > tolerance) {
      _showMessage(
        'Percentage split total must equal 100%',
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // VALIDATE RATIO SPLITS
  // ============================================================

  bool _validateRatioSplits() {
    if (_participants.isEmpty) {
      _showMessage(
        'Select at least one participant',
      );
      return false;
    }

    double total = 0.0;

    for (final member in _orderedParticipants) {
      final text = _ratioSplitControllers[member]?.text.trim() ?? '';

      final ratio = double.tryParse(text);

      if (ratio == null || ratio < 0) {
        _showMessage(
          'Enter a valid ratio for $member',
        );
        return false;
      }

      total += ratio;
    }

    if (total <= 0.0) {
      _showMessage(
        'Total ratio must be greater than 0',
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // SAVE EXPENSE
  // ============================================================

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_paidBy == null) {
      _showMessage(
        'Please select who paid',
      );
      return;
    }

    if (_participants.isEmpty) {
      _showMessage(
        'Select at least one participant',
      );
      return;
    }

    final double amount = double.parse(
      _amountController.text.trim(),
    );

    if (_splitType == 'custom') {
      if (!_validateCustomSplits(amount)) {
        return;
      }
    }

    if (_splitType == 'percentage') {
      if (!_validatePercentageSplits()) {
        return;
      }
    }

    if (_splitType == 'ratio') {
      if (!_validateRatioSplits()) {
        return;
      }
    }

    final Map<String, double> customSplits = {};

    final Map<String, double> percentageSplits = {};

    final Map<String, double> ratioSplits = {};

    if (_splitType == 'custom') {
      for (final member in _orderedParticipants) {
        customSplits[member] = double.parse(
          _customSplitControllers[member]!.text.trim(),
        );
      }
    }

    if (_splitType == 'percentage') {
      for (final member in _orderedParticipants) {
        percentageSplits[member] = double.parse(
          _percentageSplitControllers[member]!.text.trim(),
        );
      }
    }

    if (_splitType == 'ratio') {
      for (final member in _orderedParticipants) {
        ratioSplits[member] = double.parse(
          _ratioSplitControllers[member]!.text.trim(),
        );
      }
    }

    final updatedExpense = widget.expense.copyWith(
      title: _titleController.text.trim(),
      amount: amount,
      category: _category,
      paidBy: _paidBy,
      participants: _orderedParticipants,
      expenseDate: _expenseDate,
      splitType: _splitType,
      customSplits: customSplits,
      percentageSplits: percentageSplits,
      ratioSplits: ratioSplits,
    );

    Navigator.pop(
      context,
      updatedExpense,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double enteredCustomTotal = _enteredCustomTotal;

    final double enteredPercentageTotal = _enteredPercentageTotal;

    final double enteredRatioTotal = _enteredRatioTotal;

    final double? expenseAmount = double.tryParse(
      _amountController.text.trim(),
    );

    final double? customRemaining =
        expenseAmount == null ? null : expenseAmount - enteredCustomTotal;

    final double percentageRemaining = 100.0 - enteredPercentageTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Expense',
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
                'Edit Expense',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Update expense details',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 28),

              // =================================================
              // TITLE
              // =================================================

              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Expense title',
                  prefixIcon: Icon(
                    Icons.receipt_long_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an expense title';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // =================================================
              // AMOUNT
              // =================================================

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(
                    Icons.currency_rupee_rounded,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an amount';
                  }

                  final amount = double.tryParse(value.trim());

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              // =================================================
              // DATE
              // =================================================

              Text(
                'Expense date',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              InkWell(
                onTap: _selectExpenseDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.calendar_today_rounded,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_expenseDate.day.toString().padLeft(2, '0')}/'
                    '${_expenseDate.month.toString().padLeft(2, '0')}/'
                    '${_expenseDate.year}',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // CATEGORY
              // =================================================

              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map(
                  (category) {
                    final bool isSelected = _category == category['name'];

                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            size: 18,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            category['name'] as String,
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _category = category['name'] as String;
                        });
                      },
                    );
                  },
                ).toList(),
              ),

              const SizedBox(height: 30),

              // =================================================
              // PAID BY
              // =================================================

              Text(
                'Who paid?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _paidBy,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.account_balance_wallet_outlined,
                  ),
                ),
                hint: const Text(
                  'Select who paid',
                ),
                items: widget.group.members.map(
                  (member) {
                    return DropdownMenuItem<String>(
                      value: member,
                      child: Text(member),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _paidBy = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              // =================================================
              // PARTICIPANTS
              // =================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Split between',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${_participants.length} selected',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ...widget.group.members.map(
                (member) {
                  final bool selected = _participants.contains(member);

                  return Card(
                    elevation: 0,
                    child: CheckboxListTile(
                      value: selected,
                      title: Text(member),
                      secondary: CircleAvatar(
                        child: Text(
                          member.isNotEmpty ? member[0].toUpperCase() : '?',
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _participants.add(
                              member,
                            );
                          } else {
                            _participants.remove(
                              member,
                            );
                          }
                        });
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // =================================================
              // SPLIT TYPE
              // =================================================

              Text(
                'Split type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Equal'),
                    selected: _splitType == 'equal',
                    onSelected: (_) {
                      setState(() {
                        _splitType = 'equal';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: _splitType == 'custom',
                    onSelected: (_) {
                      setState(() {
                        _splitType = 'custom';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Percentage'),
                    selected: _splitType == 'percentage',
                    onSelected: (_) {
                      setState(() {
                        _splitType = 'percentage';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Ratio'),
                    selected: _splitType == 'ratio',
                    onSelected: (_) {
                      setState(() {
                        _splitType = 'ratio';
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // EQUAL SPLIT
              // =================================================

              if (_splitType == 'equal' && _participants.isNotEmpty)
                Builder(
                  builder: (context) {
                    final double amount = expenseAmount ?? 0.0;

                    final double split = amount / _participants.length;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Each person pays '
                              '${_formatMoney(split)}',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              // =================================================
              // CUSTOM SPLIT
              // =================================================

              if (_splitType == 'custom') ...[
                if (customRemaining != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Custom split summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Entered: '
                          '${_formatMoney(enteredCustomTotal)}',
                        ),
                        Text(
                          'Remaining: '
                          '${_formatMoney(customRemaining)}',
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                ..._orderedParticipants.map(
                  (member) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: TextFormField(
                        controller: _customSplitControllers[member],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: member,
                          prefixText: '₹ ',
                        ),
                      ),
                    );
                  },
                ),
              ],

              // =================================================
              // PERCENTAGE SPLIT
              // =================================================

              if (_splitType == 'percentage') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Percentage split summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entered: '
                        '${enteredPercentageTotal.toStringAsFixed(2)}%',
                      ),
                      Text(
                        'Remaining: '
                        '${percentageRemaining.toStringAsFixed(2)}%',
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Total percentage must equal 100%.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._orderedParticipants.map(
                  (member) {
                    final double percentage = double.tryParse(
                          _percentageSplitControllers[member]?.text.trim() ??
                              '',
                        ) ??
                        0.0;

                    final double memberAmount = expenseAmount == null
                        ? 0.0
                        : expenseAmount * percentage / 100.0;

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: TextFormField(
                        controller: _percentageSplitControllers[member],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: '$member (%)',
                          suffixText: _formatMoney(memberAmount),
                        ),
                      ),
                    );
                  },
                ),
              ],

              // =================================================
              // RATIO SPLIT
              // =================================================

              if (_splitType == 'ratio') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ratio split',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total ratio: '
                        '${enteredRatioTotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Example: 1, 2, 3 means the expense '
                        'is divided in the ratio 1:2:3.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._orderedParticipants.map(
                  (member) {
                    final double ratio = double.tryParse(
                          _ratioSplitControllers[member]?.text.trim() ?? '',
                        ) ??
                        0.0;

                    // IMPORTANT:
                    // Explicitly declared as double.
                    final double memberAmount =
                        expenseAmount == null || enteredRatioTotal <= 0.0
                            ? 0.0
                            : expenseAmount * ratio / enteredRatioTotal;

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: TextFormField(
                        controller: _ratioSplitControllers[member],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: '$member ratio',
                          prefixText: 'Ratio ',
                          suffixText: _formatMoney(memberAmount),
                        ),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),

              // =================================================
              // UPDATE BUTTON
              // =================================================

              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saveExpense,
                  icon: const Icon(
                    Icons.save_rounded,
                  ),
                  label: const Text(
                    'Update Expense',
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
