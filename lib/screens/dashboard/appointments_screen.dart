import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:online_medicine_lab/app_theme.dart';
import 'package:online_medicine_lab/providers/auth_provider.dart';

import '../../models/appointment.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final appointments = auth.appointments;
    final upcomingCount = appointments
        .where(
            (appointment) => !appointment.scheduledAt.isBefore(DateTime.now()))
        .length;
    final nextAppointment = auth.nextAppointment;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _BookingsHero(
          total: appointments.length,
          upcomingCount: upcomingCount,
          nextAppointment: nextAppointment,
        ),
        const SizedBox(height: 20),
        const _BookingsHeading(
          title: 'Saved bookings',
          subtitle:
              'Keep your scheduled visits, test details, and follow-up actions organized in one place.',
        ),
        const SizedBox(height: 14),
        if (appointments.isEmpty)
          const _EmptyAppointments()
        else
          for (final appointment in appointments)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _AppointmentCard(appointment: appointment),
            ),
      ],
    );
  }
}

class _BookingsHero extends StatelessWidget {
  const _BookingsHero({
    required this.total,
    required this.upcomingCount,
    required this.nextAppointment,
  });

  final int total;
  final int upcomingCount;
  final Appointment? nextAppointment;

  @override
  Widget build(BuildContext context) {
    final nextLabel = nextAppointment == null
        ? 'No visit booked yet'
        : '${nextAppointment!.labName} • ${DateFormat('dd MMM, hh:mm a').format(nextAppointment!.scheduledAt)}';

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
              'BOOKING OVERVIEW',
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
            'Your next visit is always easy to find.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            nextLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _BookingsStat(label: 'Total', value: '$total'),
              _BookingsStat(label: 'Upcoming', value: '$upcomingCount'),
              _BookingsStat(
                label: 'Status',
                value: nextAppointment == null
                    ? 'Start booking'
                    : nextAppointment!.status,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingsHeading extends StatelessWidget {
  const _BookingsHeading({
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

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
  });

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final statusTone = _statusTone(appointment.status);

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
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: statusTone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.biotech_outlined, color: statusTone),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.labName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a')
                          .format(appointment.scheduledAt),
                      style: const TextStyle(color: AppColors.slate),
                    ),
                    if (appointment.location != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        appointment.location!,
                        style: const TextStyle(color: AppColors.slate),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusBadge(
                status: appointment.status,
                tone: statusTone,
              ),
            ],
          ),
          if (appointment.testNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: appointment.testNames
                  .map(
                    (test) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mist,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        test,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Use details to review the full booking summary or cancel this visit if your schedule changes.',
                    style: TextStyle(
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
                  onPressed: () => _showCancelDialog(context, appointment.id),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.line),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAppointmentDetails(context),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text(
          'This will remove the appointment from your saved bookings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(dialogContext, listen: false)
                  .cancelAppointment(appointmentId);

              if (!dialogContext.mounted) {
                return;
              }

              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment cancelled.')),
              );
            },
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.labName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.calendar_month_outlined,
              label: DateFormat('dd MMM yyyy, hh:mm a')
                  .format(appointment.scheduledAt),
            ),
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.flag_outlined,
              label: appointment.status,
            ),
            if (appointment.location != null) ...[
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: appointment.location!,
              ),
            ],
            if (appointment.testNames.isNotEmpty) ...[
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.science_outlined,
                label: appointment.testNames.join(', '),
              ),
            ],
            const SizedBox(height: 20),
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

  Color _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'ready':
        return AppColors.success;
      case 'sampling':
      case 'pending':
        return AppColors.warm;
      default:
        return AppColors.primary;
    }
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 54,
            color: AppColors.primary,
          ),
          SizedBox(height: 14),
          Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Search for a test from the home screen to create your first appointment.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}

class _BookingsStat extends StatelessWidget {
  const _BookingsStat({
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.tone,
  });

  final String status;
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
        status,
        style: TextStyle(
          color: tone,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
        Icon(icon, color: AppColors.primary, size: 20),
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
