import 'package:flutter/material.dart';

import '../models/entities.dart';
import '../state/app_state.dart';
import '../widgets/status_badge.dart';
import 'notifications_screen.dart';
import 'owner_review.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    final pending = app.records.where((r) => r.status == RecordStatus.submitted || r.status == RecordStatus.underReview).toList();
    final approved = app.records.where((r) => r.status == RecordStatus.frozen).toList();
    final rejected = app.records.where((r) => r.status == RecordStatus.rejected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NotificationsScreen(role: AppRole.owner)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Pending Approvals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (pending.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('No pending submissions right now.')))
          else
            ...pending.map((record) => Card(
                  child: ListTile(
                    title: Text(record.month),
                    subtitle: Text('Payable: PKR ${record.finalPayable.toStringAsFixed(0)} • proofs: ${record.proofs.length}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      app.markUnderReview(record.id);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => OwnerReviewScreen(record: record)),
                      );
                    },
                  ),
                )),
          const SizedBox(height: 14),
          _historySection('Approved/Frozen', approved),
          const SizedBox(height: 14),
          _historySection('Rejected', rejected),
        ],
      ),
    );
  }

  Widget _historySection(String title, List<MonthlyRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (records.isEmpty)
          const Text('No records')
        else
          ...records.map(
            (record) => Card(
              child: ListTile(
                title: Text(record.month),
                subtitle: Text('Final payable: PKR ${record.finalPayable.toStringAsFixed(0)}'),
                trailing: StatusBadge(status: record.status),
              ),
            ),
          ),
      ],
    );
  }
}
