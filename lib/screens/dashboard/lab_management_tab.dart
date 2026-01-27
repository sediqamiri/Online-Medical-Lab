import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:online_medicine_lab/app_theme.dart';
import 'package:online_medicine_lab/utils/file_helper.dart';

import '../../models/selected_document.dart';

class LabManagementTab extends StatefulWidget {
  const LabManagementTab({super.key});

  @override
  State<LabManagementTab> createState() => _LabManagementTabState();
}

class _LabManagementTabState extends State<LabManagementTab> {
  static const List<_LabSample> _incomingPatients = [
    _LabSample(
      name: 'Sediq Ahmadi',
      test: 'Blood Sugar Panel',
      time: '09:00 AM',
      status: 'Waiting',
      desk: 'Desk A',
      turnaround: 'Same day',
      note:
          'Patient is already checked in and ready for collection as soon as a slot opens.',
    ),
    _LabSample(
      name: 'Mustafa Wali',
      test: 'Full Body Checkup',
      time: '10:30 AM',
      status: 'Sampling',
      desk: 'Desk C',
      turnaround: '6 hours',
      note:
          'Collection is in progress and this case will likely need result upload right after analysis completes.',
    ),
    _LabSample(
      name: 'Gul Nabi',
      test: 'Thyroid Profile',
      time: '11:15 AM',
      status: 'Upload next',
      desk: 'Desk B',
      turnaround: 'Today evening',
      note:
          'Collection is complete, so the next clean step is packaging the final report for upload.',
    ),
  ];

  String? _latestUploadPatient;
  String? _latestUploadFile;

  Future<void> _handleFileUpload(
    BuildContext context,
    String patientName,
    String type,
  ) async {
    SelectedDocument? file;

    if (type == 'pdf') {
      file = await FileHelper.pickPdf();
    } else if (type == 'camera') {
      file = await FileHelper.pickImage(ImageSource.camera);
    } else {
      file = await FileHelper.pickImage(ImageSource.gallery);
    }

    if (file != null && context.mounted) {
      setState(() {
        _latestUploadPatient = patientName;
        _latestUploadFile = file!.name;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected ${file.name} for $patientName')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _incomingPatients.where((sample) => sample.status == 'Waiting').length;
    final activeCount =
        _incomingPatients.where((sample) => sample.status == 'Sampling').length;
    final uploadCount = _incomingPatients
        .where((sample) => sample.status == 'Upload next')
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _LabHero(
          pendingCount: pendingCount,
          activeCount: activeCount,
          uploadCount: uploadCount,
        ),
        if (_latestUploadFile != null) ...[
          const SizedBox(height: 18),
          _LatestUploadCard(
            patientName: _latestUploadPatient!,
            fileName: _latestUploadFile!,
          ),
        ],
        const SizedBox(height: 20),
        const _LabFlowStrip(),
        const SizedBox(height: 20),
        const _LabHeading(
          title: 'Incoming patients',
          subtitle:
              'The queue is arranged so your team can move from collection to report delivery without losing the thread.',
        ),
        const SizedBox(height: 14),
        for (final patient in _incomingPatients)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _LabPatientCard(
              patient: patient,
              latestUploadFile: patient.name == _latestUploadPatient
                  ? _latestUploadFile
                  : null,
              onTap: () => _showActionSheet(context, patient),
            ),
          ),
      ],
    );
  }

  void _showActionSheet(BuildContext context, _LabSample patient) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '${patient.test} • ${patient.status}',
                style: const TextStyle(color: AppColors.slate),
              ),
              const SizedBox(height: 18),
              const Text(
                'Choose the next step',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                ),
                title: const Text('Confirm collection is complete'),
                subtitle:
                    const Text('Mark the sample flow as ready for processing'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Marked ${patient.name} as collected.')),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColors.lab,
                ),
                title: const Text('Upload result as PDF'),
                subtitle: const Text('Best for polished final report delivery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _handleFileUpload(context, patient.name, 'pdf');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.accent,
                ),
                title: const Text('Scan with camera'),
                subtitle:
                    const Text('Capture a report or stamped sheet quickly'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _handleFileUpload(context, patient.name, 'camera');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Choose from gallery'),
                subtitle: const Text(
                    'Attach a prepared image result from the device'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _handleFileUpload(context, patient.name, 'gallery');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LabHero extends StatelessWidget {
  const _LabHero({
    required this.pendingCount,
    required this.activeCount,
    required this.uploadCount,
  });

  final int pendingCount;
  final int activeCount;
  final int uploadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lab, AppColors.warm],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.lab.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'LAB OPERATIONS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The daily queue feels lighter when every step is visible.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Track waiting patients, active sampling, and upload-ready work from one operations-friendly view.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _LabStat(label: 'Waiting', value: '$pendingCount'),
              _LabStat(label: 'Sampling', value: '$activeCount'),
              _LabStat(label: 'Upload next', value: '$uploadCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LatestUploadCard extends StatelessWidget {
  const _LatestUploadCard({
    required this.patientName,
    required this.fileName,
  });

  final String patientName;
  final String fileName;

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
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latest upload ready',
                  style: TextStyle(
                    color: AppColors.slate,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$fileName for $patientName',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
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

class _LabFlowStrip extends StatelessWidget {
  const _LabFlowStrip();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 640;

        if (stacked) {
          return const Column(
            children: [
              _LabFlowCard(
                icon: Icons.science_outlined,
                accent: AppColors.lab,
                title: 'Collection flow',
                value: 'Check-in → sample → review',
                subtitle: 'A simple visual rhythm keeps the team aligned.',
              ),
              SizedBox(height: 12),
              _LabFlowCard(
                icon: Icons.upload_file_outlined,
                accent: AppColors.accent,
                title: 'Report handoff',
                value: 'PDF or image upload',
                subtitle: 'Choose the cleanest result format for delivery.',
              ),
            ],
          );
        }

        return const Row(
          children: [
            Expanded(
              child: _LabFlowCard(
                icon: Icons.science_outlined,
                accent: AppColors.lab,
                title: 'Collection flow',
                value: 'Check-in → sample → review',
                subtitle: 'A simple visual rhythm keeps the team aligned.',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _LabFlowCard(
                icon: Icons.upload_file_outlined,
                accent: AppColors.accent,
                title: 'Report handoff',
                value: 'PDF or image upload',
                subtitle: 'Choose the cleanest result format for delivery.',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LabHeading extends StatelessWidget {
  const _LabHeading({
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

class _LabPatientCard extends StatelessWidget {
  const _LabPatientCard({
    required this.patient,
    required this.latestUploadFile,
    required this.onTap,
  });

  final _LabSample patient;
  final String? latestUploadFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = _statusTone(patient.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
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
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      _initials(patient.name),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: tone,
                      ),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        patient.test,
                        style: const TextStyle(color: AppColors.slate),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    patient.status,
                    style: TextStyle(
                      color: tone,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _LabMetaChip(
                  icon: Icons.schedule_outlined,
                  label: patient.time,
                  tone: AppColors.primary,
                ),
                _LabMetaChip(
                  icon: Icons.location_on_outlined,
                  label: patient.desk,
                  tone: AppColors.lab,
                ),
                _LabMetaChip(
                  icon: Icons.timer_outlined,
                  label: patient.turnaround,
                  tone: tone,
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
            if (latestUploadFile != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.task_alt_rounded,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Latest selected file: $latestUploadFile',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.more_horiz_rounded),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Actions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusTone(String status) {
    switch (status) {
      case 'Waiting':
        return AppColors.warm;
      case 'Sampling':
        return AppColors.accent;
      case 'Upload next':
        return AppColors.success;
      default:
        return AppColors.lab;
    }
  }

  String _initials(String name) {
    return name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }
}

class _LabFlowCard extends StatelessWidget {
  const _LabFlowCard({
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
                  style: const TextStyle(color: AppColors.slate, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabStat extends StatelessWidget {
  const _LabStat({
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

class _LabMetaChip extends StatelessWidget {
  const _LabMetaChip({
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
          Text(
            label,
            style: TextStyle(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabSample {
  const _LabSample({
    required this.name,
    required this.test,
    required this.time,
    required this.status,
    required this.desk,
    required this.turnaround,
    required this.note,
  });

  final String name;
  final String test;
  final String time;
  final String status;
  final String desk;
  final String turnaround;
  final String note;
}
