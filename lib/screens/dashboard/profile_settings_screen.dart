import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:online_medicine_lab/app_theme.dart';
import 'package:online_medicine_lab/models/selected_document.dart';
import 'package:online_medicine_lab/providers/auth_provider.dart';
import 'package:online_medicine_lab/utils/file_helper.dart';
import 'package:online_medicine_lab/utils/profile_image_codec.dart';
import 'package:online_medicine_lab/utils/profile_image_provider.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _passwordController;

  DateTime? _birthDateValue;
  bool _showPassword = false;
  bool _isSaving = false;
  bool _isUpdatingPhoto = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _firstNameController = TextEditingController(text: auth.firstName);
    _lastNameController = TextEditingController(text: auth.lastName);
    _emailController = TextEditingController(text: auth.userEmail ?? '');
    _phoneController = TextEditingController(text: auth.phoneNumber ?? '');
    _addressController = TextEditingController(text: auth.address ?? '');
    _birthDateValue = _parseBirthDate(auth.birthDate);
    _birthDateController = TextEditingController(
      text: _birthDateValue == null
          ? ''
          : DateFormat('dd MMM yyyy').format(_birthDateValue!),
    );
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHero(auth),
            const SizedBox(height: 18),
            _buildOverviewStrip(auth),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Personal details',
              subtitle:
                  'Keep the identity details used across bookings, reports, and dashboard greetings tidy.',
              child: Column(
                children: [
                  _buildResponsiveNameFields(),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _birthDateController,
                    label: 'Birth Date',
                    icon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: _pickBirthDate,
                    suffixIcon: const Icon(Icons.expand_more_rounded),
                    validator: _requiredValidator,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Contact details',
              subtitle:
                  'These details help with confirmations, appointment updates, and result handoff.',
              child: Column(
                children: [
                  _buildField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.mail_outline_rounded,
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_android_rounded,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _addressController,
                    label: 'Residential Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    alignLabelWithHint: true,
                    validator: _requiredValidator,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Security',
              subtitle:
                  'Leave the password blank unless you want to refresh access on this device.',
              child: _buildField(
                controller: _passwordController,
                label: 'New Password',
                icon: Icons.lock_outline_rounded,
                obscureText: !_showPassword,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return null;
                  }
                  if (text.length < 6) {
                    return 'Use at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSavePanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHero(AuthProvider auth) {
    final profileImage = buildProfileImage(auth.profileImagePath);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(30),
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                backgroundImage: profileImage,
                child: profileImage == null
                    ? const Icon(
                        Icons.person_rounded,
                        size: 38,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 180, maxWidth: 360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _roleLabel(auth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${auth.firstName} ${auth.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.userEmail ?? 'user@email.com',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'A cleaner profile keeps your experience consistent everywhere in the app.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: _isUpdatingPhoto ? null : () => _showPhotoOptions(auth),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              foregroundColor: Colors.white,
            ),
            icon: _isUpdatingPhoto
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.camera_alt_outlined),
            label: Text(
              auth.profileImagePath == null ? 'Upload Photo' : 'Update Photo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStrip(AuthProvider auth) {
    final hasPhoto = auth.profileImagePath != null;
    final hasContactDetails = (_phoneController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;

        final items = [
          _OverviewCard(
            icon: Icons.verified_user_outlined,
            accent: AppColors.primary,
            label: 'Workspace',
            value: _roleLabel(auth),
          ),
          _OverviewCard(
            icon: Icons.photo_camera_back_outlined,
            accent: AppColors.accent,
            label: 'Profile photo',
            value: hasPhoto ? 'Ready' : 'Missing',
          ),
          _OverviewCard(
            icon: Icons.contact_phone_outlined,
            accent: AppColors.warm,
            label: 'Contact info',
            value: hasContactDetails ? 'Complete' : 'Needs care',
          ),
        ];

        if (compact) {
          return Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                items[index],
                if (index != items.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Expanded(child: items[index]),
              if (index != items.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildResponsiveNameFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 620) {
          return Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline_rounded,
                  validator: _requiredValidator,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.badge_outlined,
                  validator: _requiredValidator,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person_outline_rounded,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.badge_outlined,
              validator: _requiredValidator,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: AppColors.slate)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSavePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to save',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your changes update the profile used across the dashboard, bookings, and role workspace.',
            style: TextStyle(color: AppColors.slate, height: 1.45),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () =>
                    _save(Provider.of<AuthProvider>(context, listen: false)),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    bool readOnly = false,
    int maxLines = 1,
    bool alignLabelWithHint = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        alignLabelWithHint: alignLabelWithHint,
        fillColor: enabled ? Colors.white : AppColors.mist,
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDateValue ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _birthDateValue = picked;
      _birthDateController.text = DateFormat('dd MMM yyyy').format(picked);
    });
  }

  Future<void> _save(AuthProvider auth) async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await auth.updateProfile(
        first: _firstNameController.text,
        last: _lastNameController.text,
        phone: _phoneController.text,
        addr: _addressController.text,
        dob: _birthDateValue == null
            ? null
            : DateFormat('yyyy-MM-dd').format(_birthDateValue!),
        newPassword: _passwordController.text,
      );

      _passwordController.clear();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showPhotoOptions(AuthProvider auth) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a new profile image from your camera or gallery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.slate),
                ),
                const SizedBox(height: 16),
                _photoOptionTile(
                  icon: Icons.camera_alt_outlined,
                  color: AppColors.primary,
                  label: 'Take a photo',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickAndSaveProfileImage(auth, ImageSource.camera);
                  },
                ),
                _photoOptionTile(
                  icon: Icons.photo_library_outlined,
                  color: AppColors.accent,
                  label: 'Choose from gallery',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickAndSaveProfileImage(auth, ImageSource.gallery);
                  },
                ),
                if (auth.profileImagePath != null)
                  _photoOptionTile(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.danger,
                    label: 'Remove current photo',
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await _removeProfileImage(auth);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _photoOptionTile({
    required IconData icon,
    required Color color,
    required String label,
    required Future<void> Function() onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(label),
      onTap: onTap,
    );
  }

  Future<void> _pickAndSaveProfileImage(
    AuthProvider auth,
    ImageSource source,
  ) async {
    if (_isUpdatingPhoto) {
      return;
    }

    setState(() => _isUpdatingPhoto = true);

    try {
      final SelectedDocument? image = await FileHelper.pickImage(source);
      if (image == null) {
        return;
      }

      final encodedImage = encodeProfileImage(image);
      if (encodedImage == null || encodedImage.isEmpty) {
        throw Exception('Unable to read the selected image.');
      }

      await auth.updateProfileImage(encodedImage);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPhoto = false);
      }
    }
  }

  Future<void> _removeProfileImage(AuthProvider auth) async {
    if (_isUpdatingPhoto) {
      return;
    }

    setState(() => _isUpdatingPhoto = true);

    try {
      await auth.updateProfileImage('');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo removed.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPhoto = false);
      }
    }
  }

  DateTime? _parseBirthDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final normalized = value.trim();
    try {
      return DateTime.parse(normalized);
    } catch (_) {
      try {
        return DateFormat('dd MMM yyyy').parseStrict(normalized);
      } catch (_) {
        return null;
      }
    }
  }

  String _roleLabel(AuthProvider auth) {
    if (auth.isDoctor) {
      return 'Doctor workspace';
    }
    if (auth.isLabAdmin) {
      return 'Lab workspace';
    }
    return 'Patient workspace';
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;

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
            color: AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
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
