import 'package:flutter/material.dart';

void main() {
  runApp(const RentSettlementApp());
}

enum AppRole { tenant, owner }
enum RecordStatus { draft, submitted, rejected, approved, frozen }

class RentSettlementApp extends StatelessWidget {
  const RentSettlementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent Settlement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const RoleSelectionPage(),
    );
  }
}

class MonthlyRecord {
  MonthlyRecord({
    required this.month,
    required this.baseRent,
    required this.electricity,
    required this.water,
    required this.gas,
    required this.other,
    required this.deduction,
    required this.deductionReason,
    required this.notes,
    required this.proofCount,
    this.status = RecordStatus.draft,
    this.ownerComment,
  });

  final String month;
  final double baseRent;
  final double electricity;
  final double water;
  final double gas;
  final double other;
  final double deduction;
  final String deductionReason;
  final String notes;
  final int proofCount;
  final RecordStatus status;
  final String? ownerComment;

  double get totalDeductions => deduction;

  double get finalPayable =>
      (baseRent + electricity + water + gas + other) - totalDeductions;

  MonthlyRecord copyWith({
    RecordStatus? status,
    String? ownerComment,
  }) {
    return MonthlyRecord(
      month: month,
      baseRent: baseRent,
      electricity: electricity,
      water: water,
      gas: gas,
      other: other,
      deduction: deduction,
      deductionReason: deductionReason,
      notes: notes,
      proofCount: proofCount,
      status: status ?? this.status,
      ownerComment: ownerComment ?? this.ownerComment,
    );
  }
}

class AppStore extends InheritedNotifier<ValueNotifier<List<MonthlyRecord>>> {
  AppStore({super.key, required super.child})
      : super(notifier: ValueNotifier<List<MonthlyRecord>>(<MonthlyRecord>[]));

  static ValueNotifier<List<MonthlyRecord>> of(BuildContext context) {
    final store = context.dependOnInheritedWidgetOfExactType<AppStore>();
    assert(store != null, 'AppStore not found in widget tree');
    return store!.notifier!;
  }
}

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStore(
      child: Scaffold(
        appBar: AppBar(title: const Text('Rent Settlement App')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Choose your role',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Simple monthly rent verification with proof, approval, and frozen history.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _RoleCard(
                label: 'Tenant',
                icon: Icons.home_work_outlined,
                description: 'Create monthly entries, add proofs, submit for approval.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LoginPage(role: AppRole.tenant),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _RoleCard(
                label: 'Owner',
                icon: Icons.verified_user_outlined,
                description: 'Review submissions, approve/reject, and freeze records.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LoginPage(role: AppRole.owner),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              child: Icon(icon, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.role});

  final AppRole role;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool otpMode = true;

  @override
  Widget build(BuildContext context) {
    final roleLabel = widget.role == AppRole.tenant ? 'Tenant' : 'Owner';

    return Scaffold(
      appBar: AppBar(title: Text('$roleLabel Login')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Text(
            'Sign in',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(value: true, label: Text('Phone + OTP')),
              ButtonSegment<bool>(value: false, label: Text('Email + Password')),
            ],
            selected: {otpMode},
            onSelectionChanged: (value) {
              setState(() => otpMode = value.first);
            },
          ),
          const SizedBox(height: 18),
          TextField(
            keyboardType: otpMode ? TextInputType.phone : TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: otpMode ? 'Phone Number' : 'Email',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (!otpMode)
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              if (widget.role == AppRole.tenant) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const TenantDashboardPage(),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const OwnerDashboardPage(),
                  ),
                );
              }
            },
            icon: Icon(otpMode ? Icons.sms : Icons.login),
            label: Text(otpMode ? 'Send OTP' : 'Login'),
          ),
        ],
      ),
    );
  }
}

class TenantDashboardPage extends StatelessWidget {
  const TenantDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Dashboard')),
      body: ValueListenableBuilder<List<MonthlyRecord>>(
        valueListenable: store,
        builder: (_, records, __) {
          final approved = records.where((e) => e.status == RecordStatus.frozen).length;
          final rejected = records.where((e) => e.status == RecordStatus.rejected).length;
          final pending = records.where((e) => e.status == RecordStatus.submitted).length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SummaryBadges(approved: approved, rejected: rejected, pending: pending),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CreateMonthPage()),
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create Monthly Entry'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Monthly Records',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (records.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No records yet. Tap “Create Monthly Entry” to start.'),
                  ),
                )
              else
                ...records.reversed.map(
                  (record) => Card(
                    child: ListTile(
                      title: Text(record.month),
                      subtitle: Text(
                        'Final Payable: PKR ${record.finalPayable.toStringAsFixed(0)}',
                      ),
                      trailing: StatusChip(status: record.status),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: ValueListenableBuilder<List<MonthlyRecord>>(
        valueListenable: store,
        builder: (_, records, __) {
          final pending = records.where((e) => e.status == RecordStatus.submitted).toList();
          final frozen = records.where((e) => e.status == RecordStatus.frozen).length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Pending approvals: ${pending.length}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text('Approved/Frozen records: $frozen'),
              const SizedBox(height: 16),
              if (pending.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No pending submissions.'),
                  ),
                )
              else
                ...pending.map(
                  (record) => Card(
                    child: ListTile(
                      title: Text(record.month),
                      subtitle: Text(
                        'Submitted total: PKR ${record.finalPayable.toStringAsFixed(0)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => OwnerReviewPage(record: record),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class CreateMonthPage extends StatefulWidget {
  const CreateMonthPage({super.key});

  @override
  State<CreateMonthPage> createState() => _CreateMonthPageState();
}

class _CreateMonthPageState extends State<CreateMonthPage> {
  final _formKey = GlobalKey<FormState>();

  final monthCtrl = TextEditingController(text: 'April 2026');
  final rentCtrl = TextEditingController();
  final elecCtrl = TextEditingController();
  final waterCtrl = TextEditingController();
  final gasCtrl = TextEditingController();
  final otherCtrl = TextEditingController();
  final deductionCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final proofsCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    monthCtrl.dispose();
    rentCtrl.dispose();
    elecCtrl.dispose();
    waterCtrl.dispose();
    gasCtrl.dispose();
    otherCtrl.dispose();
    deductionCtrl.dispose();
    reasonCtrl.dispose();
    notesCtrl.dispose();
    proofsCtrl.dispose();
    super.dispose();
  }

  double _toAmount(String value) => double.tryParse(value.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Monthly Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Step-by-step monthly submission',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _field(monthCtrl, 'Month', requiredValue: true),
            _field(rentCtrl, 'Base Rent', number: true, requiredValue: true),
            _field(elecCtrl, 'Electricity Bill', number: true),
            _field(waterCtrl, 'Water Bill', number: true),
            _field(gasCtrl, 'Gas Bill', number: true),
            _field(otherCtrl, 'Other Bill', number: true),
            _field(deductionCtrl, 'Manual Deduction', number: true),
            _field(reasonCtrl, 'Deduction Reason'),
            _field(proofsCtrl, 'Attached Proof Count', number: true),
            _field(notesCtrl, 'Notes', maxLines: 3),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) return;

                final record = MonthlyRecord(
                  month: monthCtrl.text.trim(),
                  baseRent: _toAmount(rentCtrl.text),
                  electricity: _toAmount(elecCtrl.text),
                  water: _toAmount(waterCtrl.text),
                  gas: _toAmount(gasCtrl.text),
                  other: _toAmount(otherCtrl.text),
                  deduction: _toAmount(deductionCtrl.text),
                  deductionReason: reasonCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                  proofCount: int.tryParse(proofsCtrl.text.trim()) ?? 0,
                  status: RecordStatus.submitted,
                );

                final duplicate = store.value.any((e) => e.month == record.month);
                if (duplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A record for this month already exists.'),
                    ),
                  );
                  return;
                }

                store.value = [...store.value, record];
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Month submitted to owner successfully.'),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Submit to Owner'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool number = false,
    bool requiredValue = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (requiredValue && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class OwnerReviewPage extends StatelessWidget {
  const OwnerReviewPage({super.key, required this.record});

  final MonthlyRecord record;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.of(context);

    void updateRecord(MonthlyRecord updated) {
      final current = store.value;
      store.value = current.map((e) => e.month == updated.month ? updated : e).toList();
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Review ${record.month}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _line('Base Rent', record.baseRent),
          _line('Electricity', record.electricity),
          _line('Water', record.water),
          _line('Gas', record.gas),
          _line('Other', record.other),
          _line('Deduction', record.deduction),
          _line('Final Payable', record.finalPayable),
          const SizedBox(height: 8),
          Text('Deduction reason: ${record.deductionReason.isEmpty ? '-' : record.deductionReason}'),
          Text('Notes: ${record.notes.isEmpty ? '-' : record.notes}'),
          Text('Attached proofs: ${record.proofCount}'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              updateRecord(
                record.copyWith(
                  status: RecordStatus.frozen,
                  ownerComment: 'Approved and frozen',
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Approve & Freeze'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              updateRecord(
                record.copyWith(
                  status: RecordStatus.rejected,
                  ownerComment: 'Please recheck utility deductions.',
                ),
              );
            },
            icon: const Icon(Icons.cancel),
            label: const Text('Reject with Comment'),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('PKR ${value.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}

class _SummaryBadges extends StatelessWidget {
  const _SummaryBadges({
    required this.approved,
    required this.rejected,
    required this.pending,
  });

  final int approved;
  final int rejected;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _badge(context, 'Pending', pending, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _badge(context, 'Approved', approved, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _badge(context, 'Rejected', rejected, Colors.red)),
      ],
    );
  }

  Widget _badge(BuildContext context, String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final RecordStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      RecordStatus.draft => ('Draft', Colors.grey),
      RecordStatus.submitted => ('Submitted', Colors.orange),
      RecordStatus.rejected => ('Rejected', Colors.red),
      RecordStatus.approved => ('Approved', Colors.green),
      RecordStatus.frozen => ('Frozen', Colors.green),
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color.withOpacity(0.35)),
    );
  }
}
