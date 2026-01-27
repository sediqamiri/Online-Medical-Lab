import 'package:flutter/material.dart';

import 'package:online_medicine_lab/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const List<_ReportEntry> _reports = [
    _ReportEntry(
      test: 'Full Blood Count',
      lab: 'City Medical Lab',
      date: '20 Dec 2025',
      status: 'Ready',
      result: 'Normal',
      note: 'All major markers are within the expected range.',
    ),
    _ReportEntry(
      test: 'Lipid Profile',
      lab: 'Afghan-Swiss Lab',
      date: '15 Dec 2025',
      status: 'Ready',
      result: 'Borderline',
      note: 'A follow-up consultation is worth scheduling.',
    ),
    _ReportEntry(
      test: 'COVID-19 (PCR)',
      lab: 'Zuhal Diagnostic',
      date: '10 Dec 2025',
      status: 'Ready',
      result: 'Negative',
      note: 'Result delivered and safe to download anytime.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final readyCount = _reports.where((report) => report.status == 'Ready').length;
    final highlightedCount = _reports.where((report) => report.result == 'Borderline').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _ReportsHero(
          total: _reports.length,
          readyCount: readyCount,
          highlightedCount: highlightedCount,
        ),
        const SizedBox(height: 20),
        const _ReportsHeading(
          title: 'Recent results',
          subtitle: 'Open completed reports, review outcomes, and keep the important ones close.',
        ),
        const SizedBox(height: 14),
        for (final report in _reports)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ReportCard(report: report),
          ),
      ],
    );
  }
}

class _ReportsHero extends StatelessWidget {
  const _ReportsHero({
    required this.total,
    required this.readyCount,
    required this.highlightedCount,
  });

  final int total;
  final int readyCount;
  final int highlightedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.14),
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
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'REPORTS CENTER',
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
            'Your most recent outcomes are ready to review.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Keep results, follow-up notes, and downloads organized in one calmer place.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ReportsStat(label: 'Total reports', value: '$total'),
              _ReportsStat(label: 'Ready now', value: '$readyCount'),
              _ReportsStat(label: 'Need attention', value: '$highlightedCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportsHeading extends StatelessWidget {
  const _ReportsHeading({
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

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
  });

  final _ReportEntry report;

  @override
  Widget build(BuildContext context) {
    final positiveTone = report.result == 'Normal' || report.result == 'Negative';
    final tone = positiveTone ? AppColors.success : AppColors.warm;

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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.assignment_turned_in_outlined, color: tone),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.test,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.lab,
                      style: const TextStyle(color: AppColors.slate),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.date,
                      style: const TextStyle(color: AppColors.slate),
                    ),
                  ],
                ),
              ),
              _ResultBadge(
                label: report.result,
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
              report.note,
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
                  onPressed: () => _simulateDownload(context, report.test),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Download PDF'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening ${report.test} online soon.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View Online'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _simulateDownload(BuildContext context, String testName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading $testName report...')),
    );
  }
}

class _ReportsStat extends StatelessWidget {
  const _ReportsStat({
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
        color: Colors.white.withValues(alpha: 0.12),
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

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({
    required this.label,
    required this.tone,
  });

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReportEntry {
  const _ReportEntry({
    required this.test,
    required this.lab,
    required this.date,
    required this.status,
    required this.result,
    required this.note,
  });

  final String test;
  final String lab;
  final String date;
  final String status;
  final String result;
  final String note;
}
