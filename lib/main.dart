import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_medicine_lab/app_theme.dart';
import 'package:online_medicine_lab/providers/auth_provider.dart';
import 'package:online_medicine_lab/providers/test_cart_provider.dart';
import 'package:online_medicine_lab/services/notification_service.dart';
// My Screens
import 'package:online_medicine_lab/screens/splash_screen.dart';
import 'package:online_medicine_lab/screens/dashboard/dashboard_screen.dart';
import 'package:online_medicine_lab/screens/welcome_screen.dart';
import 'package:online_medicine_lab/screens/auth/login_screen.dart';
import 'package:online_medicine_lab/screens/auth/register_screen.dart';
import 'package:online_medicine_lab/screens/role/role_selection_screen.dart';
import 'package:online_medicine_lab/screens/booking/appointment_screen.dart';

// A global key to allow context-less navigation (e.g., from NotificationService)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  final authProvider = AuthProvider();
  await authProvider.loadUserSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => TestCartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Online Medical Lab',
      theme: buildClinicalTheme(),
      initialRoute: auth.isAuthenticated ? '/dashboard' : '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/select-role': (context) => const RoleSelectionScreen(),
        '/home_tab': (context) => const DashboardScreen(),
        '/patient-home': (context) => const DashboardScreen(),
        '/lab-dashboard': (context) => const DashboardScreen(),
        '/doctor-dashboard': (context) => const DashboardScreen(),
        '/appointment': (context) => const AppointmentScreen(),
      },
    );
  }
}
