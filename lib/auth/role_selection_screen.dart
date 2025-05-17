import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String fullName;

  const RoleSelectionScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.fullName,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = 'patient';
  bool isLoading = false;

  void _completeRegistration() async {
    final supabase = Supabase.instance.client;

    setState(() => isLoading = true);

    try {
      await supabase.from('users').insert({
        'id': widget.userId,
        'email': widget.email,
        'full_name': widget.fullName,
        'role': selectedRole,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (selectedRole == 'doctor') {
        Navigator.pushReplacementNamed(context, '/doctor-home');
      } else {
        Navigator.pushReplacementNamed(context, '/patient-home');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Role")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose your role to continue",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: const Text("I am a Patient"),
                value: 'patient',
                groupValue: selectedRole,
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: const Text("I am a Doctor"),
                value: 'doctor',
                groupValue: selectedRole,
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _completeRegistration,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : const Text("Complete Registration"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
