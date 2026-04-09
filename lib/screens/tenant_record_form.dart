import 'package:flutter/material.dart';

import '../models/entities.dart';
import '../state/app_state.dart';

class TenantRecordFormScreen extends StatefulWidget {
  const TenantRecordFormScreen({super.key, this.editRecord});

  final MonthlyRecord? editRecord;

  @override
  State<TenantRecordFormScreen> createState() => _TenantRecordFormScreenState();
}

class _TenantRecordFormScreenState extends State<TenantRecordFormScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController monthCtrl;
  late final TextEditingController rentCtrl;
  final TextEditingController notesCtrl = TextEditingController();
  final TextEditingController deductionReasonCtrl = TextEditingController();

  final Map<BillType, TextEditingController> amountCtrls = {
    BillType.electricity: TextEditingController(),
    BillType.water: TextEditingController(),
    BillType.gas: TextEditingController(),
    BillType.other: TextEditingController(),
  };

  final Map<BillType, TextEditingController> deductionCtrls = {
    BillType.electricity: TextEditingController(),
    BillType.water: TextEditingController(),
    BillType.gas: TextEditingController(),
    BillType.other: TextEditingController(),
  };

  final Set<BillType> selectedProofTypes = <BillType>{};

  @override
  void initState() {
    super.initState();
    monthCtrl = TextEditingController(text: widget.editRecord?.month ?? 'April 2026');
    rentCtrl = TextEditingController(text: widget.editRecord?.baseRent.toStringAsFixed(0) ?? '');
    notesCtrl.text = widget.editRecord?.notes ?? '';

    final existing = widget.editRecord;
    if (existing != null) {
      for (final bill in existing.bills) {
        amountCtrls[bill.type]?.text = bill.amount.toStringAsFixed(0);
        deductionCtrls[bill.type]?.text = bill.deductionAmount.toStringAsFixed(0);
        if (bill.reason.isNotEmpty) deductionReasonCtrl.text = bill.reason;
      }
      for (final proof in existing.proofs) {
        selectedProofTypes.add(proof.billType);
      }
    }
  }

  @override
  void dispose() {
    monthCtrl.dispose();
    rentCtrl.dispose();
    notesCtrl.dispose();
    deductionReasonCtrl.dispose();
    for (final c in amountCtrls.values) {
      c.dispose();
    }
    for (final c in deductionCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.editRecord == null ? 'Create Month Entry' : 'Edit Rejected Month')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Step 1: Month and Rent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: monthCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Month is required' : null,
              readOnly: widget.editRecord != null,
              decoration: const InputDecoration(labelText: 'Month (e.g., April 2026)'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: rentCtrl,
              keyboardType: TextInputType.number,
              validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Base rent is required' : null,
              decoration: const InputDecoration(labelText: 'Base Rent'),
            ),
            const SizedBox(height: 18),
            const Text('Step 2: Bills + Manual Deductions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...BillType.values.map((type) => _billInput(type)),
            const SizedBox(height: 10),
            TextFormField(
              controller: deductionReasonCtrl,
              decoration: const InputDecoration(labelText: 'Deduction Reason'),
            ),
            const SizedBox(height: 18),
            const Text('Step 3: Proof Upload (simulated)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BillType.values
                  .map(
                    (type) => FilterChip(
                      selected: selectedProofTypes.contains(type),
                      label: Text(_label(type)),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedProofTypes.add(type);
                          } else {
                            selectedProofTypes.remove(type);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const Text('Step 4: Notes and Submit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                final bills = BillType.values
                    .map(
                      (type) => BillEntry(
                        type: type,
                        amount: double.tryParse(amountCtrls[type]?.text ?? '') ?? 0,
                        deductionAmount: double.tryParse(deductionCtrls[type]?.text ?? '') ?? 0,
                        reason: deductionReasonCtrl.text.trim(),
                      ),
                    )
                    .toList();

                final proofs = selectedProofTypes
                    .map(
                      (type) => ProofImage(
                        id: 'proof_${type.name}_${DateTime.now().millisecondsSinceEpoch}',
                        billType: type,
                        label: '${_label(type)} proof',
                        uploadedAt: DateTime.now(),
                      ),
                    )
                    .toList();

                try {
                  if (widget.editRecord == null) {
                    app.createDraftOrSubmit(
                      month: monthCtrl.text.trim(),
                      baseRent: double.parse(rentCtrl.text),
                      bills: bills,
                      proofs: proofs,
                      notes: notesCtrl.text.trim(),
                      submit: true,
                    );
                  } else {
                    app.resubmitRejected(
                      recordId: widget.editRecord!.id,
                      baseRent: double.parse(rentCtrl.text),
                      bills: bills,
                      proofs: proofs,
                      notes: notesCtrl.text.trim(),
                    );
                  }
                  Navigator.of(context).pop();
                } on StateError catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
              child: Text(widget.editRecord == null ? 'Submit to Owner' : 'Resubmit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billInput(BillType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: amountCtrls[type],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '${_label(type)} amount'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: deductionCtrls[type],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '${_label(type)} deduction'),
            ),
          ),
        ],
      ),
    );
  }

  String _label(BillType type) => switch (type) {
        BillType.electricity => 'Electricity',
        BillType.water => 'Water',
        BillType.gas => 'Gas',
        BillType.other => 'Other',
      };
}
