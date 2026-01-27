import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:online_medicine_lab/app_theme.dart';

class DoctorDashboardTab extends StatelessWidget {
  const DoctorDashboardTab({super.key});

  static const List<_DoctorVisit> _appointments = [
    _DoctorVisit(
      name: 'Sediq Ahmadi',
      reason: 'Blood report review',
      time: '09:15 AM',
      priority: 'Routine',
      stage: 'Reports ready',
      room: 'Consult Room 2',
      note:
          'CBC and lipid profile are already uploaded, so the visit can focus on interpretation and medication guidance.',
      insight: 'Likely a short follow-up if results stay stable.',
    ),
    _DoctorVisit(
      name: 'Mustafa Wali',
      reason: 'Severe abdominal pain',
      time: '10:00 AM',
      priority: 'High',
      stage: 'Urgent review',
      room: 'Consult Room 1',
      note:
          'Symptoms were marked as urgent during booking. Keep imaging and recent chemistry results ready before the visit starts.',
      insight: 'Best candidate for immediate escalation if pain worsens.',
    ),
    _DoctorVisit(
      name: 'Khan Mohammad',
      reason: 'Annual physical check-in',
      time: '11:30 AM',
      priority: 'Routine',
      stage: 'History verified',
      room: 'Consult Room 4',
      note:
          'The patient shared a complete intake form, so this can stay focused on preventive guidance and test planning.',
      insight: 'Good slot for discussing preventive tests and yearly goals.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final priorityCount =
        _appointments.where((visit) => visit.priority == 'High').length;
    final reportReadyCount =
        _appointments.where((visit) => visit.stage == 'Reports ready').length;
    final nextVisit = _appointments.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _DoctorHero(
          consultations: _appointments.length,
          priorityCases: priorityCount,
          reportReadyCount: reportReadyCount,
        ),
        const SizedBox(height: 18),
        _DoctorPulseStrip(
          nextVisit: nextVisit,
          priorityCount: priorityCount,
        ),
        const SizedBox(height: 20),
        const _DoctorHeading(
          title: 'Today\'s consultations',
          subtitle:
              'Everything is organized so you can move from triage to follow-up with less noise and more context.',
        ),
        const SizedBox(height: 14),
        for (final patient in _appointments)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _DoctorVisitCard(patient: patient),
          ),
      ],
    );
  }
}

class _DoctorHero extends StatelessWidget {
  const _DoctorHero({
    required this.consultations,
    required this.priorityCases,
    required this.reportReadyCount,
  });

  final int consultations;
  final int priorityCases;
  final int reportReadyCount;

  @override
  Widget build(BuildContext context) {
    final todayLabel = DateFormat('EEEE, dd MMM').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.doctor, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.doctor.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'DOCTOR WORKSPACE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                todayLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'A calmer clinical view for the whole day.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Review urgent cases quickly, keep patient context nearby, and move through consultations without losing your place.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DoctorStat(label: 'Consultations', value: '$consultations'),
              _DoctorStat(label: 'High priority', value: '$priorityCases'),
              _DoctorStat(label: 'Reports ready', value: '$reportReadyCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorPulseStrip extends StatelessWidget {
  const _DoctorPulseStrip({
    required this.nextVisit,
    required this.priorityCount,
  });

  final _DoctorVisit nextVisit;
  final int priorityCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 620;

        if (stacked) {
          return Column(
            children: [
              _DoctorInsightCard(
                icon: Icons.upcoming_outlined,
                accent: AppColors.doctor,
                title: 'Next patient',
                value: '${nextVisit.name} at ${nextVisit.time}',
                subtitle: nextVisit.reason,
              ),
              const SizedBox(height: 12),
              _DoctorInsightCard(
                icon: Icons.priority_high_rounded,
                accent: AppColors.warm,
                title: 'Needs attention',
                value:
                    '$priorityCount priority case${priorityCount == 1 ? '' : 's'}',
                subtitle: 'Keep the urgent review workflow close.',
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _DoctorInsightCard(
                icon: Icons.upcoming_outlined,
                accent: AppColors.doctor,
                title: 'Next patient',
                value: '${nextVisit.name} at ${nextVisit.time}',
                subtitle: nextVisit.reason,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DoctorInsightCard(
                icon: Icons.priority_high_rounded,
                accent: AppColors.warm,
                title: 'Needs attention',
                value:
                    '$priorityCount priority case${priorityCount == 1 ? '' : 's'}',
                subtitle: 'Keep the urgent review workflow close.',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DoctorHeading extends StatelessWidget {
  const _DoctorHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _DoctorVisitCard extends StatelessWidget {
  const _DoctorVisitCard({
    required this.patient,
  });

  final _DoctorVisit patient;

  @override
  Widget build(BuildContext context) {
    final highPriority = patient.priority == 'High';
    final tone = highPriority ? AppColors.warm : AppColors.doctor;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: tone.withValues(alpha: 0.12),
                child: Text(
                  patient.name
                      .split(' ')
                      .where((part) => part.isNotEmpty)
                      .take(2)
                      .map((part) => part[0].toUpperCase())
                      .join(),
                  style: TextStyle(
                    color: tone,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      patient.reason,
                      style: const TextStyle(color: AppColors.slate),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _PriorityBadge(
                    label: patient.priority,
                    tone: tone,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patient.time,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DoctorMetaChip(
                icon: Icons.room_preferences_outlined,
                label: patient.room,
                tone: AppColors.doctor,
              ),
              _DoctorMetaChip(
                icon: Icons.task_alt_outlined,
                label: patient.stage,
                tone: tone,
              ),
              _DoctorMetaChip(
                icon: Icons.lightbulb_outline_rounded,
                label: patient.insight,
                tone: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              patient.note,
              style: const TextStyle(
                color: AppColors.slate,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewPatientDetails(context, patient),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Records'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewPatientDetails(context, patient),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Actions'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _viewPatientDetails(BuildContext context, _DoctorVisit patient) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              patient.reason,
              style: const TextStyle(color: AppColors.slate),
            ),
            const SizedBox(height: 18),
            _SheetDetailRow(
              icon: Icons.schedule_outlined,
              label: patient.time,
            ),
            const SizedBox(height: 10),
            _SheetDetailRow(
              icon: Icons.room_preferences_outlined,
              label: patient.room,
            ),
            const SizedBox(height: 10),
            _SheetDetailRow(
              icon: Icons.task_alt_outlined,
              label: patient.stage,
            ),
            const SizedBox(height: 10),
            _SheetDetailRow(
              icon: Icons.priority_high_rounded,
              label: '${patient.priority} priority',
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                patient.note,
                style: const TextStyle(color: AppColors.slate, height: 1.45),
              ),
            ),
            const SizedBox(height: 18),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.history_edu_outlined, color: AppColors.doctor),
              title: Text('Open medical history'),
              subtitle: Text('Review previous visits and report trends'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.medication_outlined, color: AppColors.warm),
              title: Text('Prepare next action'),
              subtitle: Text('Write a prescription or add follow-up notes'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorInsightCard extends StatelessWidget {
  const _DoctorInsightCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.slate,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.slate,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorStat extends StatelessWidget {
  const _DoctorStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorMetaChip extends StatelessWidget {
  const _DoctorMetaChip({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tone),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tone,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({
    required this.label,
    required this.tone,
  });

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SheetDetailRow extends StatelessWidget {
  const _SheetDetailRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.doctor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.slate, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _DoctorVisit {
  const _DoctorVisit({
    required this.name,
    required this.reason,
    required this.time,
    required this.priority,
    required this.stage,
    required this.room,
    required this.note,
    required this.insight,
  });

  final String name;
  final String reason;
  final String time;
  final String priority;
  final String stage;
  final String room;
  final String note;
  final String insight;
}
