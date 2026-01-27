import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:online_medicine_lab/app_theme.dart';
import 'package:online_medicine_lab/providers/auth_provider.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({
    super.key,
    required this.testName,
  });

  final String testName;

  static const List<_LabOption> _labs = [
    _LabOption(
      name: 'City Medical Lab',
      price: 450,
      rating: 4.8,
      location: 'Kabul',
      turnaround: 'Same day',
      accent: AppColors.primary,
    ),
    _LabOption(
      name: 'Afghan-Swiss Lab',
      price: 600,
      rating: 4.9,
      location: 'Shahr-e-Naw',
      turnaround: '6 hours',
      accent: AppColors.accent,
    ),
    _LabOption(
      name: 'Zuhal Diagnostic',
      price: 380,
      rating: 4.2,
      location: 'Karte Parwan',
      turnaround: 'Next morning',
      accent: AppColors.warm,
    ),
    _LabOption(
      name: 'Hayat Medical',
      price: 500,
      rating: 4.5,
      location: 'Wazir Akbar Khan',
      turnaround: 'Same day',
      accent: AppColors.primaryBright,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sortedLabs = [..._labs]..sort((first, second) => first.price.compareTo(second.price));
    final bestPrice = sortedLabs.first.price;
    final bestRated = [..._labs]..sort((first, second) => second.rating.compareTo(first.rating));

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF2FBFA),
              Color(0xFFF7FAFE),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.ink,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Search results',
                            style: TextStyle(
                              color: AppColors.slate,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            testName,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    _SearchHeroCard(
                      testName: testName,
                      resultCount: _labs.length,
                      bestPrice: bestPrice,
                      bestRatedLab: bestRated.first.name,
                    ),
                    const SizedBox(height: 20),
                    const _SectionHeading(
                      title: 'Recommended labs',
                      subtitle: 'Choose the turnaround, location, and price that fit your visit best.',
                    ),
                    const SizedBox(height: 14),
                    for (final lab in _labs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _LabResultCard(
                          lab: lab,
                          testName: testName,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchHeroCard extends StatelessWidget {
  const _SearchHeroCard({
    required this.testName,
    required this.resultCount,
    required this.bestPrice,
    required this.bestRatedLab,
  });

  final String testName;
  final int resultCount;
  final int bestPrice;
  final String bestRatedLab;

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
            color: AppColors.ink.withValues(alpha: 0.15),
            blurRadius: 32,
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
              'READY TO BOOK',
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
            'Here are the strongest matches for $testName.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Compare trusted labs by rating, turnaround time, and price before you lock in a booking.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroStat(label: 'Labs found', value: '$resultCount'),
              _HeroStat(label: 'Lowest price', value: '$bestPrice AFN'),
              _HeroStat(label: 'Best rated', value: bestRatedLab),
            ],
          ),
        ],
      ),
    );
  }
}

class _LabResultCard extends StatelessWidget {
  const _LabResultCard({
    required this.lab,
    required this.testName,
  });

  final _LabOption lab;
  final String testName;

  @override
  Widget build(BuildContext context) {
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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: lab.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.science_outlined,
                  color: lab.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lab.name,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _InlineMeta(
                          icon: Icons.star_rounded,
                          color: AppColors.warm,
                          label: '${lab.rating}',
                        ),
                        _InlineMeta(
                          icon: Icons.location_on_outlined,
                          color: AppColors.slate,
                          label: lab.location,
                        ),
                        _InlineMeta(
                          icon: Icons.schedule_outlined,
                          color: AppColors.primary,
                          label: lab.turnaround,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${lab.price} AFN',
                style: TextStyle(
                  color: lab.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$testName is available here with a ${lab.turnaround.toLowerCase()} reporting window.',
                    style: const TextStyle(
                      color: AppColors.slate,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved ${lab.name} to compare later.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark_outline_rounded),
                  label: const Text('Save'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _book(context),
                  icon: const Icon(Icons.event_available_rounded),
                  label: const Text('Book'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _book(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate == null || !context.mounted) {
      return;
    }

    final scheduledAt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      9,
    );
    final formattedDate = DateFormat('dd MMM yyyy').format(scheduledAt);

    await Provider.of<AuthProvider>(context, listen: false).addAppointment(
      labName: lab.name,
      scheduledAt: scheduledAt,
      testNames: [testName],
      location: lab.location,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booked at ${lab.name} for $formattedDate'),
      ),
    );

    Navigator.pop(context);
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
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
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
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

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.slate,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LabOption {
  const _LabOption({
    required this.name,
    required this.price,
    required this.rating,
    required this.location,
    required this.turnaround,
    required this.accent,
  });

  final String name;
  final int price;
  final double rating;
  final String location;
  final String turnaround;
  final Color accent;
}
