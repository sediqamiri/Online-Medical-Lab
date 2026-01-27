import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../widgets/brand_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final drift = (_controller.value - 0.5) * 24;
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF2FBFA),
                      Color(0xFFF6F8FD),
                      Colors.white,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -120,
                right: -80 + drift,
                child: const _BackdropOrb(
                  size: 260,
                  color: Color(0x2614B8A6),
                ),
              ),
              Positioned(
                left: -70 - drift,
                bottom: -90,
                child: const _BackdropOrb(
                  size: 220,
                  color: Color(0x1F0284C7),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 960;
                    final isTablet = constraints.maxWidth >= 720;
                    final content = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(context, isWide: isWide),
                        SizedBox(height: isWide ? 34 : 24),
                        isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: _buildCopyColumn(
                                      context,
                                      theme,
                                      isWide: true,
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: _buildVisualColumn(
                                      context,
                                      theme,
                                      drift,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCopyColumn(
                                    context,
                                    theme,
                                    isWide: false,
                                  ),
                                  const SizedBox(height: 28),
                                  _buildVisualColumn(context, theme, drift),
                                ],
                              ),
                        const SizedBox(height: 28),
                        _buildTrustRibbon(theme),
                        const SizedBox(height: 52),
                        _buildJourneySection(theme,
                            isWide: isWide, isTablet: isTablet),
                        const SizedBox(height: 52),
                        _buildRoleSection(theme,
                            isWide: isWide, isTablet: isTablet),
                        const SizedBox(height: 52),
                        _buildFinalCallToAction(context, theme, isWide: isWide),
                      ],
                    );

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 56 : 24,
                        vertical: 28,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 56,
                        ),
                        child: Center(child: content),
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

  Widget _buildTopBar(BuildContext context, {required bool isWide}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                const _BrandLockup(),
                const Spacer(),
                const _HeaderTag(label: 'Trusted lab booking'),
                const SizedBox(width: 12),
                const _HeaderTag(label: 'Secure report access'),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Sign In'),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 168,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Create Account'),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: _BrandLockup()),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                        foregroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Create Account'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTrustRibbon(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Built to feel trustworthy on first visit and useful after sign-in.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
            ),
          ),
          const _HeaderTag(label: 'Cleaner landing flow'),
          const _HeaderTag(label: 'Stronger trust cues'),
          const _HeaderTag(label: 'Better desktop dashboard'),
        ],
      ),
    );
  }

  Widget _buildJourneySection(
    ThemeData theme, {
    required bool isWide,
    required bool isTablet,
  }) {
    final cardWidth = isWide
        ? 350.0
        : isTablet
            ? 300.0
            : double.infinity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LandingSectionHeading(
          eyebrow: 'HOW IT WORKS',
          title: 'A clearer path from search to result.',
          description:
              'The website now explains the value of the product more clearly before people decide to register.',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: const [
            _JourneyCard(
              width: 0,
              eyebrow: 'Step 1',
              title: 'Search tests with less guesswork',
              description:
                  'Start with a familiar test name, then jump directly into matching labs and next steps.',
              icon: Icons.search_rounded,
            ),
            _JourneyCard(
              width: 0,
              eyebrow: 'Step 2',
              title: 'Compare labs and book in minutes',
              description:
                  'The flow makes appointments feel shorter, cleaner, and easier to repeat from any device.',
              icon: Icons.calendar_month_outlined,
            ),
            _JourneyCard(
              width: 0,
              eyebrow: 'Step 3',
              title: 'Track reports from one dashboard',
              description:
                  'Keep reminders, booking context, and report history together instead of scattered across screens.',
              icon: Icons.assignment_turned_in_outlined,
            ),
          ]
              .map((card) => _JourneyCard(
                    width: cardWidth,
                    eyebrow: card.eyebrow,
                    title: card.title,
                    description: card.description,
                    icon: card.icon,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRoleSection(
    ThemeData theme, {
    required bool isWide,
    required bool isTablet,
  }) {
    final cardWidth = isWide
        ? 350.0
        : isTablet
            ? 300.0
            : double.infinity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LandingSectionHeading(
          eyebrow: 'ROLE-READY',
          title: 'One product, shaped around different users.',
          description:
              'Patients, doctors, and labs each get a clearer story about what the platform helps them do.',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            _RoleCard(
              width: cardWidth,
              title: 'For patients',
              description:
                  'Search, book, and revisit reports without getting lost across different lab systems.',
              icon: Icons.favorite_outline_rounded,
              tone: AppColors.primary,
            ),
            _RoleCard(
              width: cardWidth,
              title: 'For doctors',
              description:
                  'Review patient activity and recent records in a calmer, role-aware clinical workspace.',
              icon: Icons.medical_services_outlined,
              tone: AppColors.doctor,
            ),
            _RoleCard(
              width: cardWidth,
              title: 'For labs',
              description:
                  'Manage bookings, uploads, and reporting flow from one organized operations view.',
              icon: Icons.biotech_outlined,
              tone: AppColors.lab,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinalCallToAction(
    BuildContext context,
    ThemeData theme, {
    required bool isWide,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, AppColors.primary, AppColors.primaryBright],
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'READY TO CONTINUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Move from landing page to care workspace without friction.',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The refreshed website now gives people a clearer story up front and a stronger product feel after sign-in.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 230,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Create Account'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Move from landing page to care workspace without friction.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'The refreshed site now feels more complete on both mobile and desktop.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Text('Sign In'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCopyColumn(
    BuildContext context,
    ThemeData theme, {
    required bool isWide,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.line),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_rounded,
                  size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Verified labs and secure results',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Healthcare access with a calmer, faster flow.',
          style: theme.textTheme.displayMedium?.copyWith(
            height: 1.06,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 520 : 640),
          child: Text(
            'Search tests, compare trusted labs, track appointments, and review results without the usual paperwork chaos.',
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate),
          ),
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FeatureTag(icon: Icons.science_outlined, label: 'Search tests'),
            _FeatureTag(
                icon: Icons.calendar_month_outlined, label: 'Book in minutes'),
            _FeatureTag(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Track reports',
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: isWide ? 240 : double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('Create Account'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: isWide ? 240 : double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('I Already Have an Account'),
          ),
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _StatTile(value: '24/7', label: 'Account access'),
            _StatTile(value: '3 steps', label: 'From search to booking'),
            _StatTile(value: '100%', label: 'Digital appointment history'),
          ],
        ),
      ],
    );
  }

  Widget _buildVisualColumn(
      BuildContext context, ThemeData theme, double drift) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.ink, AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.14),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Today in your care workspace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Results, reminders, and bookings in one clean dashboard.',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 1.18,
                        child: Container(
                          color: const Color(0xFFE9F7F5),
                          padding: const EdgeInsets.all(24),
                          child: const BrandLogo(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildVisualRow(
                      icon: Icons.check_circle_outline,
                      title: 'Report ready',
                      subtitle: 'Full Blood Count from City Medical Lab',
                    ),
                    const SizedBox(height: 12),
                    _buildVisualRow(
                      icon: Icons.schedule_rounded,
                      title: 'Upcoming booking',
                      subtitle: 'Tomorrow, 09:00 AM with Afghan-Swiss Lab',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 32 + drift,
          right: -12,
          child: const _FloatingMetric(
            label: 'Verified labs',
            value: '42',
            tone: AppColors.warm,
          ),
        ),
        Positioned(
          left: -16,
          bottom: 36 - drift,
          child: const _FloatingMetric(
            label: 'Average booking time',
            value: '2 min',
            tone: AppColors.primaryBright,
          ),
        ),
      ],
    );
  }

  Widget _buildVisualRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.slate, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
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
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  const _FeatureTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.slate)),
        ],
      ),
    );
  }
}

class _FloatingMetric extends StatelessWidget {
  const _FloatingMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 54,
          width: 54,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F8F5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const BrandLogo(),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Online Medical Lab',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Book tests and track reports',
              style: TextStyle(
                color: AppColors.slate,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderTag extends StatelessWidget {
  const _HeaderTag({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LandingSectionHeading extends StatelessWidget {
  const _LandingSectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(title, style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(description, style: theme.textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.width,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
  });

  final double width;
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              eyebrow,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.slate,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.width,
    required this.title,
    required this.description,
    required this.icon,
    required this.tone,
  });

  final double width;
  final String title;
  final String description;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tone.withValues(alpha: 0.12), Colors.white],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: tone),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.slate,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
