import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:online_medicine_lab/app_theme.dart';
import 'package:online_medicine_lab/providers/auth_provider.dart';
import 'package:online_medicine_lab/screens/dashboard/appointments_screen.dart';
import 'package:online_medicine_lab/screens/dashboard/doctor_dashboard_tab.dart';
import 'package:online_medicine_lab/screens/dashboard/home_tab.dart';
import 'package:online_medicine_lab/screens/dashboard/lab_management_tab.dart';
import 'package:online_medicine_lab/screens/dashboard/profile_settings_screen.dart';
import 'package:online_medicine_lab/screens/dashboard/reports_screen.dart';

import '../../utils/profile_image_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profileImage = buildProfileImage(auth.profileImagePath);
    final items = _buildItems(auth);
    final roleColor = _roleColor(auth);
    final isDesktop = MediaQuery.sizeOf(context).width >= 1180;

    if (_selectedIndex >= items.length) {
      _selectedIndex = 0;
    }

    final currentItem = items[_selectedIndex];

    return isDesktop
        ? _buildDesktopScaffold(
            context,
            auth,
            items,
            currentItem,
            roleColor,
            profileImage,
          )
        : Scaffold(
            drawer: Drawer(
              backgroundColor: AppColors.mist,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(18),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.ink, roleColor],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 16),
                          Text(
                            '${auth.firstName} ${auth.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
                          const SizedBox(height: 14),
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
                              _roleBadge(auth),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _DrawerInfoChip(
                                icon: Icons.dashboard_customize_outlined,
                                label: currentItem.label,
                              ),
                              const _DrawerInfoChip(
                                icon: Icons.check_circle_outline_rounded,
                                label: 'Signed in',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final selected = index == _selectedIndex;
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            selected: selected,
                            selectedTileColor:
                                roleColor.withValues(alpha: 0.12),
                            leading: Icon(
                              item.icon,
                              color: selected ? roleColor : AppColors.slate,
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                color: selected ? roleColor : AppColors.ink,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() => _selectedIndex = index);
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          await auth.logout();
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/welcome',
                            (route) => false,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              AppColors.danger.withValues(alpha: 0.14),
                          foregroundColor: AppColors.danger,
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              leadingWidth: 68,
              leading: Builder(
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: IconButton.filledTonal(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.ink,
                      ),
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  );
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${auth.firstName}'),
                  const SizedBox(height: 2),
                  Text(
                    '${_dashboardTitle(auth)} | ${currentItem.label}',
                    style: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImage,
                    child: profileImage == null
                        ? const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
              ],
            ),
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    roleColor.withValues(alpha: 0.05),
                    AppColors.mist,
                    const Color(0xFFF8FBFE),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                      child: _DashboardHeroCard(
                        color: roleColor,
                        roleLabel: _roleBadge(auth),
                        title: _dashboardTitle(auth),
                        subtitle: _dashboardSummary(auth),
                        currentLabel: currentItem.label,
                        profileImage: profileImage,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.66),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(34),
                          ),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.05),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(34),
                          ),
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: items.map((item) => item.screen).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.06),
                    blurRadius: 28,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    backgroundColor: Colors.white,
                    indicatorColor: roleColor.withValues(alpha: 0.14),
                    height: 76,
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return TextStyle(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                        color: selected ? roleColor : AppColors.slate,
                      );
                    }),
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return IconThemeData(
                        color: selected ? roleColor : AppColors.slate,
                        size: 22,
                      );
                    }),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  destinations: items
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
  }

  Widget _buildDesktopScaffold(
    BuildContext context,
    AuthProvider auth,
    List<_DashboardItem> items,
    _DashboardItem currentItem,
    Color roleColor,
    ImageProvider<Object>? profileImage,
  ) {
    return Scaffold(
      backgroundColor: AppColors.mist,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              roleColor.withValues(alpha: 0.05),
              AppColors.mist,
              const Color(0xFFF8FBFE),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: _buildDesktopNavigationPanel(
                    context,
                    auth,
                    items,
                    currentItem,
                    roleColor,
                    profileImage,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.74),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.04),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${auth.firstName}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_dashboardTitle(auth)} | ${currentItem.label}',
                                    style: const TextStyle(
                                      color: AppColors.slate,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              backgroundImage: profileImage,
                              child: profileImage == null
                                  ? const Icon(
                                      Icons.person_outline_rounded,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _DashboardHeroCard(
                        color: roleColor,
                        roleLabel: _roleBadge(auth),
                        title: _dashboardTitle(auth),
                        subtitle: _dashboardSummary(auth),
                        currentLabel: currentItem.label,
                        profileImage: profileImage,
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.74),
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ink.withValues(alpha: 0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(34),
                            child: IndexedStack(
                              index: _selectedIndex,
                              children:
                                  items.map((item) => item.screen).toList(),
                            ),
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
      ),
    );
  }

  Widget _buildDesktopNavigationPanel(
    BuildContext context,
    AuthProvider auth,
    List<_DashboardItem> items,
    _DashboardItem currentItem,
    Color roleColor,
    ImageProvider<Object>? profileImage,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(18),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.ink, roleColor],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),
                Text(
                  '${auth.firstName} ${auth.lastName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
                const SizedBox(height: 14),
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
                    _roleBadge(auth),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _DrawerInfoChip(
                      icon: Icons.dashboard_customize_outlined,
                      label: currentItem.label,
                    ),
                    const _DrawerInfoChip(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Signed in',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = index == _selectedIndex;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  selected: selected,
                  selectedTileColor: roleColor.withValues(alpha: 0.12),
                  leading: Icon(
                    item.icon,
                    color: selected ? roleColor : AppColors.slate,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? roleColor : AppColors.ink,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: FilledButton.tonalIcon(
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) {
                  return;
                }
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcome',
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.14),
                foregroundColor: AppColors.danger,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  List<_DashboardItem> _buildItems(AuthProvider auth) {
    if (auth.isLabAdmin) {
      return const [
        _DashboardItem(
          label: 'Lab Work',
          icon: Icons.biotech_outlined,
          selectedIcon: Icons.biotech,
          screen: LabManagementTab(),
        ),
        _DashboardItem(
          label: 'Results',
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          screen: ReportsScreen(),
        ),
        _DashboardItem(
          label: 'Profile',
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person_rounded,
          screen: ProfileSettingsScreen(),
        ),
      ];
    }

    if (auth.isDoctor) {
      return const [
        _DashboardItem(
          label: 'Patients',
          icon: Icons.people_outline_rounded,
          selectedIcon: Icons.people_rounded,
          screen: DoctorDashboardTab(),
        ),
        _DashboardItem(
          label: 'Records',
          icon: Icons.history_edu_outlined,
          selectedIcon: Icons.history_edu,
          screen: ReportsScreen(),
        ),
        _DashboardItem(
          label: 'Profile',
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person_rounded,
          screen: ProfileSettingsScreen(),
        ),
      ];
    }

    return const [
      _DashboardItem(
        label: 'Home',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        screen: HomeTab(),
      ),
      _DashboardItem(
        label: 'Reports',
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        screen: ReportsScreen(),
      ),
      _DashboardItem(
        label: 'Bookings',
        icon: Icons.calendar_today_outlined,
        selectedIcon: Icons.calendar_today_rounded,
        screen: AppointmentsScreen(),
      ),
      _DashboardItem(
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        screen: ProfileSettingsScreen(),
      ),
    ];
  }

  String _dashboardTitle(AuthProvider auth) {
    if (auth.isLabAdmin) {
      return 'Lab Workspace';
    }
    if (auth.isDoctor) {
      return 'Doctor Workspace';
    }
    return 'Patient Dashboard';
  }

  String _roleBadge(AuthProvider auth) {
    if (auth.isLabAdmin) {
      return 'LAB ADMIN';
    }
    if (auth.isDoctor) {
      return 'DOCTOR';
    }
    return 'PATIENT';
  }

  String _dashboardSummary(AuthProvider auth) {
    if (auth.isLabAdmin) {
      return 'Track bookings, uploads, and reporting flow from one cleaner operations view.';
    }
    if (auth.isDoctor) {
      return 'Review patient activity, records, and updates in a calmer clinical workspace.';
    }
    return 'Stay on top of bookings, reports, and your care history from one polished dashboard.';
  }

  Color _roleColor(AuthProvider auth) {
    if (auth.isLabAdmin) {
      return AppColors.lab;
    }
    if (auth.isDoctor) {
      return AppColors.doctor;
    }
    return AppColors.primary;
  }
}

class _DashboardHeroCard extends StatelessWidget {
  const _DashboardHeroCard({
    required this.color,
    required this.roleLabel,
    required this.title,
    required this.subtitle,
    required this.currentLabel,
    required this.profileImage,
  });

  final Color color;
  final String roleLabel;
  final String title;
  final String subtitle;
  final String currentLabel;
  final ImageProvider<Object>? profileImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, color],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                        roleLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: profileImage,
                child: profileImage == null
                    ? Icon(Icons.person_rounded, color: color, size: 28)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DrawerInfoChip(
                icon: Icons.layers_outlined,
                label: currentLabel,
              ),
              const _DrawerInfoChip(
                icon: Icons.auto_awesome_outlined,
                label: 'Polished workspace',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerInfoChip extends StatelessWidget {
  const _DrawerInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardItem {
  const _DashboardItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
}
