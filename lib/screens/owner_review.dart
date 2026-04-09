import 'package:flutter/material.dart';

import '../models/entities.dart';
import '../state/app_state.dart';
import '../widgets/status_badge.dart';

class OwnerReviewScreen extends StatefulWidget {
  const OwnerReviewScreen({super.key, required this.record});

  final MonthlyRecord record;

  @override
  State<OwnerReviewScreen> createState() => _OwnerReviewScreenState();
}

class _OwnerReviewScreenState extends State<OwnerReviewScreen> {
  final commentCtrl = TextEditingController();

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final record = app.records.firstWhere((r) => r.id == widget.record.id, orElse: () => widget.record);

    return Scaffold(
      appBar: AppBar(title: Text('Review ${record.month}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: Text(record.propertyTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              StatusBadge(status: record.status),
            ],
          ),
          const SizedBox(height: 10),
          Text('Base rent: PKR ${record.baseRent.toStringAsFixed(0)}'),
          Text('Total bills: PKR ${record.totalBillAmount.toStringAsFixed(0)}'),
          Text('Total deductions: PKR ${record.totalDeductions.toStringAsFixed(0)}'),
          Text('Final payable: PKR ${record.finalPayable.toStringAsFixed(0)}'),
          const Divider(height: 26),
          const Text('Bill entries', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ...record.bills.map((bill) => ListTile(
                dense: true,
                title: Text('${bill.type.name.toUpperCase()} - PKR ${bill.amount.toStringAsFixed(0)}'),
                subtitle: Text('Deduction: ${bill.deductionAmount.toStringAsFixed(0)} | Reason: ${bill.reason.isEmpty ? '-' : bill.reason}'),
              )),
          const Divider(height: 26),
          const Text('Proofs', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: record.proofs
                .map((proof) => Chip(label: Text('${proof.billType.name} (${proof.uploadedAt.hour}:${proof.uploadedAt.minute.toString().padLeft(2, '0')})')))
                .toList(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Comment / rejection reason'),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {
              app.approveAndFreeze(record.id, comment: commentCtrl.text);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Approve and Freeze'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              final reason = commentCtrl.text.trim().isEmpty
                  ? 'Please review deductions and proofs.'
                  : commentCtrl.text.trim();
              app.reject(record.id, reason: reason);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Reject Submission'),
          ),
        ],
      ),
    );
  }
}
