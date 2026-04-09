import 'package:flutter/material.dart';

import '../models/entities.dart';
import '../state/app_state.dart';
import '../widgets/status_badge.dart';
import 'notifications_screen.dart';
import 'tenant_record_form.dart';

class TenantDashboardScreen extends StatelessWidget {
  const TenantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final records = app.records;

    final pending = records.where((r) => r.status == RecordStatus.submitted || r.status == RecordStatus.underReview).length;
    final approved = records.where((r) => r.status == RecordStatus.frozen).length;
    final rejected = records.where((r) => r.status == RecordStatus.rejected).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NotificationsScreen(role: AppRole.tenant)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TenantRecordFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Create Month'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: _tile('Pending', pending, Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _tile('Approved', approved, Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _tile('Rejected', rejected, Colors.red)),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Monthly History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (records.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No monthly entries yet.'),
              ),
            )
          else
            ...records.reversed.map((record) => _recordCard(context, record, app)),
          const SizedBox(height: 16),
          const Text('Audit Logs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...app.auditLogs.take(8).map((e) => Text('• $e')),
          const SizedBox(height: 72),
        ],
      ),
    );
  }

  Widget _tile(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.12),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _recordCard(BuildContext context, MonthlyRecord record, AppController app) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(record.month, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                StatusBadge(status: record.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Final payable: PKR ${record.finalPayable.toStringAsFixed(0)}'),
            Text('Proofs attached: ${record.proofs.length}'),
            if (record.comments.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Owner comment: ${record.comments.last.message}'),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (record.status.canTenantEdit)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => TenantRecordFormScreen(editRecord: record)),
                      ),
                      child: const Text('Edit / Resubmit'),
                    ),
                  ),
                if (record.status.canTenantEdit) const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: null,
                    child: Text(record.status.isLocked ? 'Locked for tenant edit' : 'Editable'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
