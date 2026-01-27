import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:online_medicine_lab/app_theme.dart';
import 'package:online_medicine_lab/providers/auth_provider.dart';
import 'package:online_medicine_lab/screens/dashboard/search_results_screen.dart';

import '../../models/appointment.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final nextAppointment = auth.nextAppointment;
    final activeAppointments = auth.appointments
        .where(
            (appointment) => !appointment.scheduledAt.isBefore(DateTime.now()))
        .length;
    final profileCompletion = _profileCompletion(auth);
    final upcomingTests = nextAppointment?.testNames.length ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1080;

        final primaryColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(context, auth, nextAppointment),
            const SizedBox(height: 20),
            _buildSearchCard(context),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: isWide ? 250 : 260,
                  child: _MetricCard(
                    label: 'Active bookings',
                    value: '$activeAppointments',
                    icon: Icons.event_available_rounded,
                    tone: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: isWide ? 250 : 260,
                  child: _MetricCard(
                    label: 'Profile readiness',
                    value: '$profileCompletion%',
                    icon: Icons.health_and_safety_outlined,
                    tone: AppColors.accent,
                  ),
                ),
                SizedBox(
                  width: isWide ? 250 : 260,
                  child: _MetricCard(
                    label: 'Upcoming test items',
                    value: '$upcomingTests',
                    icon: Icons.science_outlined,
                    tone: AppColors.warm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(
              context,
              title: 'Popular test searches',
              subtitle: 'Start from the most common requests.',
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ServiceCard(
                  title: 'Full Blood Count',
                  subtitle: 'Fast baseline screening',
                  icon: Icons.bloodtype_outlined,
                  color: AppColors.primary,
                  onTap: () => _openSearch(context, 'Full Blood Count'),
                ),
                _ServiceCard(
                  title: 'Lipid Profile',
                  subtitle: 'Heart health overview',
                  icon: Icons.favorite_outline_rounded,
                  color: AppColors.accent,
                  onTap: () => _openSearch(context, 'Lipid Profile'),
                ),
                _ServiceCard(
                  title: 'Thyroid Test',
                  subtitle: 'Hormone balance check',
                  icon: Icons.monitor_heart_outlined,
                  color: AppColors.warm,
                  onTap: () => _openSearch(context, 'Thyroid Profile'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(
              context,
              title: 'Care checklist',
              subtitle: 'Small reminders that keep appointments smoother.',
            ),
            const SizedBox(height: 14),
            const _ChecklistTile(
              icon: Icons.verified_user_outlined,
              title: 'Keep your contact details updated',
              subtitle:
                  'Labs can confirm appointments faster when your profile is current.',
            ),
            const SizedBox(height: 12),
            const _ChecklistTile(
              icon: Icons.description_outlined,
              title: 'Review your latest reports regularly',
              subtitle:
                  'A quick check helps you spot new results without waiting for a call.',
            ),
          ],
        );

        final secondaryColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusPanel(
              title: 'Your next milestone',
              subtitle: nextAppointment == null
                  ? 'No upcoming appointment is booked yet.'
                  : '${nextAppointment.labName} on ${DateFormat('dd MMM, hh:mm a').format(nextAppointment.scheduledAt)}',
              icon: Icons.schedule_rounded,
              tone: AppColors.primary,
              detail: nextAppointment == null
                  ? 'Search for a test to create your first booking.'
                  : nextAppointment.location ??
                      'Location will appear inside your booking details.',
            ),
            const SizedBox(height: 14),
            _StatusPanel(
              title: 'Profile readiness',
              subtitle: '$profileCompletion% of core details are filled in.',
              icon: Icons.person_outline_rounded,
              tone:
                  profileCompletion >= 80 ? AppColors.success : AppColors.warm,
              detail: profileCompletion >= 80
                  ? 'Your account is in good shape for faster booking confirmation.'
                  : 'Adding more profile details can make appointment handling smoother.',
            ),
            const SizedBox(height: 14),
            _StatusPanel(
              title: 'Before your next visit',
              subtitle: upcomingTests == 0
                  ? 'No test list has been attached to an upcoming booking yet.'
                  : '$upcomingTests test item${upcomingTests == 1 ? '' : 's'} attached to your next appointment.',
              icon: Icons.fact_check_outlined,
              tone: AppColors.accent,
              detail: nextAppointment?.testNames.isNotEmpty == true
                  ? nextAppointment!.testNames.take(3).join('  |  ')
                  : 'Once you book, this panel can remind you what to bring and what to expect.',
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: primaryColumn),
                        const SizedBox(width: 18),
                        Expanded(flex: 2, child: secondaryColumn),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        primaryColumn,
                        const SizedBox(height: 18),
                        secondaryColumn,
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    AuthProvider auth,
    Appointment? nextAppointment,
  ) {
    final appointmentText = nextAppointment == null
        ? 'You do not have an upcoming appointment yet.'
        : '${nextAppointment.labName} on ${DateFormat('dd MMM, hh:mm a').format(nextAppointment.scheduledAt)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.16),
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
              'TODAY AT A GLANCE',
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
            'Welcome back, ${auth.firstName}.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  height: 1.06,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            appointmentText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search faster',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Compare labs before you book.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure profile',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Your saved account is ready.',
                        style: TextStyle(color: AppColors.slate),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find a test or lab',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Type a test name and jump straight into matching labs.',
            style: TextStyle(color: AppColors.slate),
          ),
          const SizedBox(height: 14),
          TextField(
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              if (value.trim().isEmpty) {
                return;
              }
              _openSearch(context, value.trim());
            },
            decoration: const InputDecoration(
              hintText: 'Blood Sugar, X-Ray, Thyroid Profile...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  void _openSearch(BuildContext context, String testName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(testName: testName),
      ),
    );
  }

  int _profileCompletion(AuthProvider auth) {
    final List<String?> fields = [
      auth.firstName,
      auth.lastName,
      auth.userEmail,
      auth.phoneNumber,
      auth.address,
      auth.birthDate,
    ];

    final completed = fields
        .where(
          (value) => value != null && value.trim().isNotEmpty,
        )
        .length;

    return ((completed / fields.length) * 100).round();
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tone),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.slate)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.slate, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.slate, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.detail,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tone;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: tone),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.ink,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail,
            style: const TextStyle(
              color: AppColors.slate,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
