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
    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Role")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RadioListTile(
            title: const Text("I am a Patient"),
            value: 'patient',
            groupValue: selectedRole,
            onChanged: (value) {
              setState(() {
                selectedRole = value!;
              });
            },
          ),
          RadioListTile(
            title: const Text("I am a Doctor"),
            value: 'doctor',
            groupValue: selectedRole,
            onChanged: (value) {
              setState(() {
                selectedRole = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading ? null : _completeRegistration,
            child:
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Complete Registration"),
          ),
        ],
      ),
    );
  }
}
