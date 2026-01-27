import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:online_medicine_lab/app_theme.dart';
import 'package:online_medicine_lab/providers/auth_provider.dart';
import 'package:online_medicine_lab/utils/file_helper.dart';

import '../../models/selected_document.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  static const List<_RoleDefinition> _roles = [
    _RoleDefinition(
      id: 'PATIENT',
      title: 'Patient',
      badge: 'Recommended start',
      description:
          'A calm, friendly workspace for booking tests, checking reports, and staying on top of appointments.',
      helperText: 'Fastest setup with instant access.',
      icon: Icons.favorite_outline_rounded,
      color: AppColors.primary,
      requiresVerification: false,
      bullets: [
        'Compare trusted labs quickly',
        'Book tests in just a few taps',
        'Keep results and reminders together',
      ],
      insights: [
        _RoleInsight(
          icon: Icons.rocket_launch_outlined,
          label: 'Best for',
          value: 'Everyday care and personal lab bookings',
        ),
        _RoleInsight(
          icon: Icons.dashboard_customize_outlined,
          label: 'Dashboard focus',
          value: 'Bookings, reports, and visit history',
        ),
        _RoleInsight(
          icon: Icons.bolt_rounded,
          label: 'Access',
          value: 'Instant once you continue',
        ),
      ],
      acceptedDocs: [],
    ),
    _RoleDefinition(
      id: 'DOCTOR',
      title: 'Doctor',
      badge: 'Professional access',
      description:
          'A focused clinical workspace for reviewing records, tracking follow-ups, and helping patients understand results.',
      helperText: 'Requires a professional document before entry.',
      icon: Icons.medical_services_outlined,
      color: AppColors.doctor,
      requiresVerification: true,
      bullets: [
        'Review patient test history clearly',
        'Keep follow-ups and records organized',
        'Guide patients through report findings',
      ],
      insights: [
        _RoleInsight(
          icon: Icons.monitor_heart_outlined,
          label: 'Best for',
          value: 'Clinicians supporting diagnosis and follow-up',
        ),
        _RoleInsight(
          icon: Icons.folder_open_outlined,
          label: 'Dashboard focus',
          value: 'Patient records, notes, and review flow',
        ),
        _RoleInsight(
          icon: Icons.verified_user_outlined,
          label: 'Access',
          value: 'Upload a license or work credential first',
        ),
      ],
      acceptedDocs: ['Medical license', 'Hospital ID', 'Council certificate'],
    ),
    _RoleDefinition(
      id: 'LAB_ADMIN',
      title: 'Lab',
      badge: 'Operations workspace',
      description:
          'A cleaner operations view for managing incoming bookings, report uploads, and day-to-day laboratory flow.',
      helperText: 'Requires a lab document before entry.',
      icon: Icons.biotech_outlined,
      color: AppColors.lab,
      requiresVerification: true,
      bullets: [
        'Manage bookings and sample flow',
        'Upload reports with less friction',
        'Keep turnaround status easy to follow',
      ],
      insights: [
        _RoleInsight(
          icon: Icons.apartment_outlined,
          label: 'Best for',
          value: 'Laboratories and diagnostic operations teams',
        ),
        _RoleInsight(
          icon: Icons.inventory_2_outlined,
          label: 'Dashboard focus',
          value: 'Bookings, uploads, and report delivery',
        ),
        _RoleInsight(
          icon: Icons.badge_outlined,
          label: 'Access',
          value: 'Upload facility proof or manager ID first',
        ),
      ],
      acceptedDocs: ['Lab registration', 'Facility license', 'Manager ID'],
    ),
  ];

  String? _selectedRole;
  SelectedDocument? _selectedDocument;
  bool _isLoading = false;
  bool _didSeedInitialRole = false;

  _RoleDefinition get _currentRole {
    final roleId = _selectedRole ?? 'PATIENT';
    return _roles.firstWhere(
      (role) => role.id == roleId,
      orElse: () => _roles.first,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSeedInitialRole) return;
    _didSeedInitialRole = true;
    final auth = context.read<AuthProvider>();
    final savedRole = auth.userRole ?? 'PATIENT';
    _selectedRole =
        _roles.any((role) => role.id == savedRole) ? savedRole : 'PATIENT';
  }

  void _selectRole(String roleId) {
    setState(() {
      _selectedRole = roleId;
      _selectedDocument = null;
    });
  }

  Future<void> _pickDocument(String type) async {
    SelectedDocument? file;

    if (type == 'camera') {
      file = await FileHelper.pickImage(ImageSource.camera);
    } else if (type == 'gallery') {
      file = await FileHelper.pickImage(ImageSource.gallery);
    } else {
      file = await FileHelper.pickPdf();
    }

    if (file != null && mounted) {
      setState(() => _selectedDocument = file);
    }
  }

  bool _canContinue() {
    if (_selectedRole == null) return false;
    if (!_currentRole.requiresVerification) return true;
    return _selectedDocument != null;
  }

  String _ctaLabel() {
    if (_selectedRole == null) return 'Choose a workspace to continue';
    if (!_currentRole.requiresVerification) {
      return 'Continue as ${_currentRole.title}';
    }
    if (_selectedDocument == null) return 'Upload a document to continue';
    return 'Continue as ${_currentRole.title}';
  }

  String _footerMessage() {
    if (_selectedRole == null) {
      return 'Choose the role that matches how you want to use the app today.';
    }
    if (!_currentRole.requiresVerification) {
      return 'Patient is the easiest place to start, and it keeps the experience fast and welcoming.';
    }
    if (_selectedDocument == null) {
      return 'A quick professional document check keeps doctor and lab workspaces more trustworthy.';
    }
    return 'Everything is ready for this workspace. Continue to save your role and open the dashboard.';
  }

  Future<void> _completeSetup() async {
    if (_selectedRole == null) return;
    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.setUserRole(_selectedRole!);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving role: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0FBF7),
                  Color(0xFFF4F8FE),
                  Colors.white,
                ],
              ),
            ),
          ),
          const Positioned(
            top: -90,
            right: -70,
            child: _BackdropOrb(size: 260, color: Color(0x2414B8A6)),
          ),
          const Positioned(
            bottom: -110,
            left: -90,
            child: _BackdropOrb(size: 280, color: Color(0x1F0284C7)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1080;
                final horizontalPadding = isWide ? 40.0 : 22.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 46,
                    ),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 11,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTopBar(),
                                    const SizedBox(height: 22),
                                    _buildHero(theme, isWide: true),
                                    const SizedBox(height: 24),
                                    _buildRoleSection(theme),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(flex: 9, child: _buildSideColumn(theme)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopBar(),
                              const SizedBox(height: 22),
                              _buildHero(theme, isWide: false),
                              const SizedBox(height: 24),
                              _buildRoleSection(theme),
                              const SizedBox(height: 24),
                              _buildSideColumn(theme),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.ink,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoBadge(icon: Icons.layers_outlined, label: 'Workspace setup'),
              _InfoBadge(
                icon: Icons.favorite_rounded,
                label: 'Friendly onboarding',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero(ThemeData theme, {required bool isWide}) {
    return Container(
      padding: EdgeInsets.all(isWide ? 32 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            _currentRole.color.withValues(alpha: 0.08),
            const Color(0xFFF9FCFF),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
        boxShadow: [
          BoxShadow(
            color: _currentRole.color.withValues(alpha: 0.12),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              'Choose the workspace that fits your day best',
              style: theme.textTheme.labelLarge?.copyWith(color: AppColors.ink),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'A friendlier start for every kind of user.',
            style: theme.textTheme.displaySmall?.copyWith(height: 1.05),
          ),
          const SizedBox(height: 12),
          Text(
            'We kept the flow simple, but made the decision clearer. Pick a role, preview what changes, and continue with confidence.',
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatPill(
                icon: Icons.bolt_rounded,
                color: AppColors.primary,
                label: 'Quick setup',
                value: _currentRole.requiresVerification ? '2 steps' : '1 step',
              ),
              _StatPill(
                icon: Icons.dashboard_customize_outlined,
                color: _currentRole.color,
                label: 'Selected',
                value: _currentRole.title,
              ),
              _StatPill(
                icon: Icons.shield_outlined,
                color: AppColors.accent,
                label: 'Experience',
                value: _currentRole.requiresVerification
                    ? 'Verified access'
                    : 'Instant access',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your role', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Each workspace has a different mood, toolset, and dashboard focus. You can switch roles later if needed.',
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final isThreeColumn = maxWidth >= 920;
              final isTwoColumn = maxWidth >= 610;
              final cardWidth = isThreeColumn
                  ? (maxWidth - 32) / 3
                  : isTwoColumn
                      ? (maxWidth - 16) / 2
                      : maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final role in _roles)
                    SizedBox(
                      width: cardWidth,
                      child: _RoleOptionCard(
                        role: role,
                        selected: role.id == _selectedRole,
                        onTap: () => _selectRole(role.id),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSideColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPreviewPanel(theme),
        if (_currentRole.requiresVerification) ...[
          const SizedBox(height: 22),
          _buildVerificationPanel(theme),
        ],
        const SizedBox(height: 22),
        _buildActionPanel(theme),
      ],
    );
  }

  Widget _buildPreviewPanel(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _currentRole.color.withValues(alpha: 0.14),
            Colors.white,
          ],
        ),
        border: Border.all(color: _currentRole.color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: _currentRole.color.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: Column(
          key: ValueKey(_currentRole.id),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: _currentRole.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _currentRole.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_currentRole.title} workspace',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentRole.helperText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What changes for you',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  for (final insight in _currentRole.insights)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InsightTile(
                        icon: insight.icon,
                        label: insight.label,
                        value: insight.value,
                        color: _currentRole.color,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final bullet in _currentRole.bullets)
                  _FeatureChip(color: _currentRole.color, label: bullet),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationPanel(ThemeData theme) {
    final document = _selectedDocument;
    final showImage = document?.hasImagePreview ?? false;
    final isPdf = document?.isPdf ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: _currentRole.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: _currentRole.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Professional verification',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload one clear document to unlock the ${_currentRole.title.toLowerCase()} workspace.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final doc in _currentRole.acceptedDocs)
                _InfoBadge(
                  icon: Icons.check_circle_outline_rounded,
                  label: doc,
                  tint: _currentRole.color,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _UploadActionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () => _pickDocument('camera'),
              ),
              _UploadActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () => _pickDocument('gallery'),
              ),
              _UploadActionButton(
                icon: Icons.picture_as_pdf_outlined,
                label: 'PDF',
                onTap: () => _pickDocument('pdf'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: () => _pickDocument('pdf'),
            borderRadius: BorderRadius.circular(28),
            child: Ink(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FBFD),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _currentRole.color.withValues(alpha: 0.18),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: document == null
                    ? Padding(
                        key: const ValueKey('empty'),
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 68,
                              width: 68,
                              decoration: BoxDecoration(
                                color:
                                    _currentRole.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Icon(
                                Icons.cloud_upload_outlined,
                                color: _currentRole.color,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Drop in one clean document',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use camera, gallery, or PDF. A clear license, certificate, or ID usually works best.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        key: ValueKey(document.name),
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: showImage
                                ? Image.memory(
                                    document.bytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: isPdf
                                        ? AppColors.lab.withValues(alpha: 0.12)
                                        : AppColors.accent
                                            .withValues(alpha: 0.1),
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isPdf
                                              ? Icons.picture_as_pdf_outlined
                                              : Icons
                                                  .insert_drive_file_outlined,
                                          size: 58,
                                          color: isPdf
                                              ? AppColors.lab
                                              : AppColors.accent,
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          document.name,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'File ready',
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: IconButton.filled(
                              onPressed: () =>
                                  setState(() => _selectedDocument = null),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.94),
                                foregroundColor: AppColors.danger,
                              ),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ready when you are',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _footerMessage(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canContinue() && !_isLoading ? _completeSetup : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.ink,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.18),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.48),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.ink,
                      ),
                    )
                  : Text(_ctaLabel()),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedRole == null
                ? 'Nothing will be saved until you continue.'
                : _currentRole.requiresVerification
                    ? 'Choose a role, upload one document, and then continue into the workspace.'
                    : 'Choose patient for the fastest and friendliest path into the app.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.66),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final _RoleDefinition role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      role.color.withValues(alpha: 0.17),
                      Colors.white,
                      const Color(0xFFFDFEFF),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFFBFCFE),
                    ],
            ),
            border: Border.all(
              color: selected ? role.color : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (selected ? role.color : AppColors.ink)
                    .withValues(alpha: selected ? 0.12 : 0.04),
                blurRadius: selected ? 28 : 18,
                offset: const Offset(0, 12),
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
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: selected
                          ? role.color
                          : role.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      role.icon,
                      color: selected ? Colors.white : role.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: role.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            role.badge,
                            style: TextStyle(
                              color: role.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          role.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected ? role.color : AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                role.description,
                style: const TextStyle(color: AppColors.slate, height: 1.55),
              ),
              const SizedBox(height: 16),
              for (final bullet in role.bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: role.color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          bullet,
                          style: const TextStyle(
                            color: AppColors.ink,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppColors.line.withValues(alpha: 0.8)),
                ),
                child: Row(
                  children: [
                    Icon(
                      role.requiresVerification
                          ? Icons.verified_user_outlined
                          : Icons.bolt_rounded,
                      color: role.color,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        role.helperText,
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    this.tint = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
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
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _UploadActionButton extends StatelessWidget {
  const _UploadActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _RoleDefinition {
  const _RoleDefinition({
    required this.id,
    required this.title,
    required this.badge,
    required this.description,
    required this.helperText,
    required this.icon,
    required this.color,
    required this.requiresVerification,
    required this.bullets,
    required this.insights,
    required this.acceptedDocs,
  });

  final String id;
  final String title;
  final String badge;
  final String description;
  final String helperText;
  final IconData icon;
  final Color color;
  final bool requiresVerification;
  final List<String> bullets;
  final List<_RoleInsight> insights;
  final List<String> acceptedDocs;
}

class _RoleInsight {
  const _RoleInsight({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
