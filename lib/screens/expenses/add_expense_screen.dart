import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../models/group.dart';

class AddExpenseScreen extends StatefulWidget {
  final GroupData group;

  const AddExpenseScreen({
    super.key,
    required this.group,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _expenseDate = DateTime.now();

  String _category = 'Food';
  String? _paidBy;

  final Set<String> _participants = {};

  // equal, custom, percentage, ratio
  String _splitType = 'equal';

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

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    if (widget.group.members.isNotEmpty) {
      _paidBy = widget.group.members.first;

      _participants.addAll(
        widget.group.members,
      );

      for (final member in widget.group.members) {
        _customSplitControllers[member] = TextEditingController();

        _percentageSplitControllers[member] = TextEditingController();

        _ratioSplitControllers[member] = TextEditingController();
      }
    }
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

  String _formatMoney(num amount) {
    return '₹${amount.toStringAsFixed(2)}';
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

    setState(() {
      _expenseDate = selectedDate;
    });
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
  // EXPENSE AMOUNT
  // ============================================================

  double get _expenseAmount {
    return double.tryParse(
          _amountController.text.trim(),
        ) ??
        0;
  }

  // ============================================================
  // CUSTOM TOTAL
  // ============================================================

  double get _enteredCustomTotal {
    double total = 0;

    for (final member in _participants) {
      final value = double.tryParse(
        _customSplitControllers[member]?.text.trim() ?? '',
      );

      if (value != null) {
        total += value;
      }
    }

    return total;
  }

  // ============================================================
  // PERCENTAGE TOTAL
  // ============================================================

  double get _enteredPercentageTotal {
    double total = 0;

    for (final member in _participants) {
      final value = double.tryParse(
        _percentageSplitControllers[member]?.text.trim() ?? '',
      );

      if (value != null) {
        total += value;
      }
    }

    return total;
  }

  // ============================================================
  // RATIO TOTAL
  // ============================================================

  double get _enteredRatioTotal {
    double total = 0;

    for (final member in _participants) {
      final value = double.tryParse(
        _ratioSplitControllers[member]?.text.trim() ?? '',
      );

      if (value != null) {
        total += value;
      }
    }

    return total;
  }

  // ============================================================
  // VALIDATE CUSTOM SPLIT
  // ============================================================

  bool _validateCustomSplits(double expenseAmount) {
    if (_participants.isEmpty) {
      _showMessage(
        'Select at least one participant',
      );

      return false;
    }

    double total = 0;

    for (final member in _participants) {
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

    const tolerance = 0.01;

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
  // VALIDATE PERCENTAGE SPLIT
  // ============================================================

  bool _validatePercentageSplits() {
    if (_participants.isEmpty) {
      _showMessage(
        'Select at least one participant',
      );

      return false;
    }

    double total = 0;

    for (final member in _participants) {
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

    const tolerance = 0.01;

    if ((total - 100).abs() > tolerance) {
      _showMessage(
        'Percentage split total must equal 100%',
      );

      return false;
    }

    return true;
  }

  // ============================================================
  // VALIDATE RATIO SPLIT
  // ============================================================

  bool _validateRatioSplits() {
    if (_participants.isEmpty) {
      _showMessage(
        'Select at least one participant',
      );

      return false;
    }

    double total = 0;

    for (final member in _participants) {
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

    if (total <= 0) {
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

    final amount = double.parse(
      _amountController.text.trim(),
    );

    // ==========================================================
    // VALIDATE SPLITS
    // ==========================================================

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

    // ==========================================================
    // CREATE SPLIT MAPS
    // ==========================================================

    final customSplits = <String, double>{};

    final percentageSplits = <String, double>{};

    final ratioSplits = <String, double>{};

    // ==========================================================
    // CUSTOM
    // ==========================================================

    if (_splitType == 'custom') {
      for (final member in _participants) {
        customSplits[member] = double.parse(
          _customSplitControllers[member]!.text.trim(),
        );
      }
    }

    // ==========================================================
    // PERCENTAGE
    // ==========================================================

    if (_splitType == 'percentage') {
      for (final member in _participants) {
        percentageSplits[member] = double.parse(
          _percentageSplitControllers[member]!.text.trim(),
        );
      }
    }

    // ==========================================================
    // RATIO
    // ==========================================================

    if (_splitType == 'ratio') {
      for (final member in _participants) {
        ratioSplits[member] = double.parse(
          _ratioSplitControllers[member]!.text.trim(),
        );
      }
    }

    // ==========================================================
    // CREATE EXPENSE
    // ==========================================================

    final expense = ExpenseData(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: amount,
      category: _category,
      paidBy: _paidBy!,
      participants: _participants.toList(),
      expenseDate: _expenseDate,
      createdAt: DateTime.now(),
      splitType: _splitType,
      customSplits: customSplits,
      percentageSplits: percentageSplits,
      ratioSplits: ratioSplits,
    );

    Navigator.pop(
      context,
      expense,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final expenseAmount = _expenseAmount;

    final enteredCustomTotal = _enteredCustomTotal;

    final enteredPercentageTotal = _enteredPercentageTotal;

    final enteredRatioTotal = _enteredRatioTotal;

    final customRemaining = expenseAmount - enteredCustomTotal;

    final percentageRemaining = 100 - enteredPercentageTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
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
                'New Expense',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Add an expense for ${widget.group.name}',
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
                  hintText: 'Example: Dinner at restaurant',
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
                  hintText: '0.00',
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
                    _formatDate(
                      _expenseDate,
                    ),
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
                    final isSelected = _category == category['name'];

                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
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
              // WHO PAID
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
                items: widget.group.members.map(
                  (member) {
                    return DropdownMenuItem(
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

              const SizedBox(height: 8),

              const Text(
                'Select everyone included in this expense.',
              ),

              const SizedBox(height: 14),

              ...widget.group.members.map(
                (member) {
                  final selected = _participants.contains(member);

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
                            _participants.add(member);
                          } else {
                            _participants.remove(member);
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
                _buildSummaryCard(
                  context,
                  title: 'Equal split',
                  child: Builder(
                    builder: (context) {
                      final split = _participants.isEmpty
                          ? 0
                          : expenseAmount / _participants.length;

                      return Text(
                        'Each person pays '
                        '${_formatMoney(split)}',
                      );
                    },
                  ),
                ),

              // =================================================
              // CUSTOM SPLIT
              // =================================================

              if (_splitType == 'custom') ...[
                _buildSummaryCard(
                  context,
                  title: 'Custom split summary',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense: '
                        '${_formatMoney(expenseAmount)}',
                      ),
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
                ..._participants.map(
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
                _buildSummaryCard(
                  context,
                  title: 'Percentage split summary',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                ..._participants.map(
                  (member) {
                    final percentage = double.tryParse(
                          _percentageSplitControllers[member]?.text.trim() ??
                              '',
                        ) ??
                        0;

                    final memberAmount = expenseAmount * percentage / 100;

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
                          suffixText: _formatMoney(
                            memberAmount,
                          ),
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
                _buildSummaryCard(
                  context,
                  title: 'Ratio split',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total ratio: '
                        '${enteredRatioTotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Example: 1, 2, 3 means '
                        'the expense is divided '
                        'in the ratio 1:2:3.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._participants.map(
                  (member) {
                    final ratio = double.tryParse(
                          _ratioSplitControllers[member]?.text.trim() ?? '',
                        ) ??
                        0;

                    final memberAmount = enteredRatioTotal <= 0
                        ? 0
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
                          suffixText: _formatMoney(
                            memberAmount,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),

              // =================================================
              // SAVE BUTTON
              // =================================================

              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saveExpense,
                  icon: const Icon(
                    Icons.check_rounded,
                  ),
                  label: const Text(
                    'Save Expense',
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

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
