import 'package:doctor_appointment_app/auth/login_screen.dart';
import 'package:doctor_appointment_app/auth/register_screen.dart';
import 'package:doctor_appointment_app/auth/role_selection_screen.dart';
import 'package:doctor_appointment_app/doctor/doctor_dashboard.dart';
import 'package:doctor_appointment_app/doctor/doctor_profile_screen.dart'; // ✅
import 'package:doctor_appointment_app/patient/patient_dashboard.dart';
import 'package:doctor_appointment_app/screens/appointment_booking_screen.dart';
import 'package:doctor_appointment_app/screens/doctor_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xerjcggovrxxqzmdvxjm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhlcmpjZ2dvdnJ4eHF6bWR2eGptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDczOTAwNDksImV4cCI6MjA2Mjk2NjA0OX0.GrVKRl1Xxdo24jsoTBZBSlwXV2KR7ISJTEcXQV2uJBA',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Appointment App',
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());

          case '/select-role':
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              final userId = args['userId'] as String?;
              final email = args['email'] as String?;
              final fullName = args['fullName'] as String?;

              if (userId != null && email != null && fullName != null) {
                return MaterialPageRoute(
                  builder:
                      (_) => RoleSelectionScreen(
                        userId: userId,
                        email: email,
                        fullName: fullName,
                      ),
                );
              }
            }
            return _errorRoute('Invalid arguments for Role Selection');

          case '/doctor-home':
            return MaterialPageRoute(builder: (_) => const DoctorHomeScreen());

          case '/patient-home':
            return MaterialPageRoute(builder: (_) => const PatientHomeScreen());

          case '/book-appointment':
            final doctorId = settings.arguments;
            if (doctorId is String) {
              return MaterialPageRoute(
                builder: (_) => AppointmentBookingScreen(doctorId: doctorId),
              );
            } else {
              return _errorRoute('Invalid doctor ID');
            }

          case '/doctor-details':
            final doctorId = settings.arguments;
            if (doctorId is String) {
              return MaterialPageRoute(
                builder: (_) => DoctorDetailsScreen(doctorId: doctorId),
              );
            } else {
              return _errorRoute('Invalid doctor ID');
            }

          case '/doctor-profile': // ✅ updated route
            return MaterialPageRoute(builder: (_) => const UserProfileScreen());

          default:
            return _errorRoute('Page not found');
        }
      },
    );
  }

  MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            body: Center(
              child: Text(message, style: const TextStyle(fontSize: 18)),
            ),
          ),
    );
  }
}
