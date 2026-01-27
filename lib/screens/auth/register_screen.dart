import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AnimationController _controller;

  String? _gender;
  String _countryCode = '+93';
  DateTime? _birthDate;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _firstController.dispose();
    _lastController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final drift = (_controller.value - 0.5) * 28;
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEEF9F6),
                      Color(0xFFF5F8FD),
                      Colors.white,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -120,
                right: -40 + drift,
                child: const _RegisterOrb(size: 250, color: Color(0x2414B8A6)),
              ),
              Positioned(
                bottom: -90,
                left: -80 - drift,
                child: const _RegisterOrb(size: 240, color: Color(0x1C0284C7)),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 980;
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 48 : 22,
                        vertical: 22,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 44,
                        ),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildSidePanel(theme),
                                  ),
                                  const SizedBox(width: 26),
                                  Expanded(
                                    flex: 2,
                                    child: _buildFormPanel(theme, isWide),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton.filledTonal(
                                    onPressed: () =>
                                        Navigator.pushReplacementNamed(
                                      context,
                                      '/welcome',
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.ink,
                                    ),
                                    icon: const Icon(Icons.arrow_back_rounded),
                                  ),
                                  const SizedBox(height: 18),
                                  _buildSidePanel(theme, compact: true),
                                  const SizedBox(height: 22),
                                  _buildFormPanel(theme, isWide),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidePanel(ThemeData theme, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 34),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.accent,
            Color(0xFF46C5B7),
          ],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.16),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Text(
              'ACCOUNT SETUP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Create a clean, role-ready profile in one pass.',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              height: 1.06,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'This setup prepares your bookings, reminders, identity details, and the workspace you choose next.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: _RegisterMiniStat(
                    value: '1 min',
                    label: 'Setup time',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _RegisterMiniStat(
                    value: 'Step 1',
                    label: 'Profile first',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _RegisterMiniStat(
                    value: 'Step 2',
                    label: 'Choose role',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _RegisterBenefit(
            icon: Icons.badge_outlined,
            title: 'Clean identity setup',
            subtitle:
                'Your details are organized once, then reused everywhere.',
          ),
          const SizedBox(height: 12),
          const _RegisterBenefit(
            icon: Icons.health_and_safety_outlined,
            title: 'Safer access',
            subtitle: 'Your password stays protected on this device.',
          ),
          const SizedBox(height: 12),
          const _RegisterBenefit(
            icon: Icons.rocket_launch_outlined,
            title: 'Smoother next step',
            subtitle: 'After this form, you move straight into role selection.',
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(ThemeData theme, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: const Text(
                'Step 1 of 2',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Create your account', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Complete your profile first, then we will help you choose the workspace that fits you best.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.slate,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.line),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Keep this simple: enter your core details now, then pick Patient, Doctor, or Lab on the next screen.',
                      style: TextStyle(
                        color: AppColors.slate,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Identity'),
            const SizedBox(height: 12),
            isWide
                ? Row(
                    children: [
                      Expanded(child: _buildFirstNameField()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildLastNameField()),
                    ],
                  )
                : Column(
                    children: [
                      _buildFirstNameField(),
                      const SizedBox(height: 12),
                      _buildLastNameField(),
                    ],
                  ),
            const SizedBox(height: 12),
            _buildBirthDateField(),
            const SizedBox(height: 12),
            _buildGenderChooser(),
            const SizedBox(height: 22),
            _buildSectionTitle('Account access'),
            const SizedBox(height: 12),
            _buildEmailField(),
            const SizedBox(height: 12),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildConfirmPasswordField(),
            const SizedBox(height: 22),
            _buildSectionTitle('Contact details'),
            const SizedBox(height: 12),
            _buildPhoneField(),
            const SizedBox(height: 12),
            _buildAddressField(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Account and Continue'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('I Already Have an Account'),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'You will choose your role on the next screen, so you do not need to decide everything right now.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstController,
      decoration: const InputDecoration(
        labelText: 'First Name',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      validator: _requiredValidator,
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastController,
      decoration: const InputDecoration(
        labelText: 'Last Name',
        prefixIcon: Icon(Icons.badge_outlined),
      ),
      validator: _requiredValidator,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.mail_outline_rounded),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return 'Email is required';
        }
        if (!text.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_showPassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _showPassword = !_showPassword),
          icon: Icon(
            _showPassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
          ),
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return 'Password is required';
        }
        if (text.length < 6) {
          return 'Use at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_showConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: const Icon(Icons.verified_user_outlined),
        suffixIcon: IconButton(
          onPressed: () => setState(
            () => _showConfirmPassword = !_showConfirmPassword,
          ),
          icon: Icon(
            _showConfirmPassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
          ),
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return 'Confirm your password';
        }
        if (text != _passwordController.text.trim()) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildBirthDateField() {
    final label = _birthDate == null
        ? 'Select Birth Date'
        : DateFormat('dd MMM yyyy').format(_birthDate!);

    return InkWell(
      onTap: _pickBirthDate,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: _birthDate == null ? AppColors.slate : AppColors.ink,
                  fontWeight:
                      _birthDate == null ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.expand_more_rounded, color: AppColors.slate),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderChooser() {
    return Row(
      children: [
        Expanded(
          child: _GenderCard(
            label: 'Male',
            icon: Icons.male_rounded,
            selected: _gender == 'male',
            onTap: () => setState(() => _gender = 'male'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderCard(
            label: 'Female',
            icon: Icons.female_rounded,
            selected: _gender == 'female',
            onTap: () => setState(() => _gender = 'female'),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: CountryCodePicker(
            onChanged: (code) {
              _countryCode = code.dialCode ?? _countryCode;
            },
            initialSelection: 'AF',
            favorite: const ['+93'],
            showDropDownButton: true,
            padding: EdgeInsets.zero,
            textStyle: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_android_rounded),
            ),
            validator: _requiredValidator,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Residential Address',
        prefixIcon: Icon(Icons.location_on_outlined),
        alignLabelWithHint: true,
      ),
      validator: _requiredValidator,
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    if (_gender == null || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose gender and birth date.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        firstName: _firstController.text.trim(),
        lastName: _lastController.text.trim(),
        address: _addressController.text.trim(),
        phone: '$_countryCode ${_phoneController.text.trim()}',
        birthDate: DateFormat('yyyy-MM-dd').format(_birthDate!),
        gender: _gender!,
        role: authProvider.userRole ?? 'PATIENT',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful.')),
      );

      Navigator.pushReplacementNamed(context, '/select-role');
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}

class _RegisterOrb extends StatelessWidget {
  const _RegisterOrb({
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
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _RegisterBenefit extends StatelessWidget {
  const _RegisterBenefit({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.45,
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

class _RegisterMiniStat extends StatelessWidget {
  const _RegisterMiniStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.slate,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
