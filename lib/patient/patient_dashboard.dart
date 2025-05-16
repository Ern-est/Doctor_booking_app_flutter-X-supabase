import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    final response = await supabase
        .from('users')
        .select('id, full_name')
        .eq('role', 'doctor');

    setState(() {
      doctors = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  void bookAppointment(String doctorId) {
    Navigator.pushNamed(context, '/book-appointment', arguments: doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : doctors.isEmpty
              ? const Center(child: Text('No doctors available'))
              : ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(doctor['full_name'] ?? 'Unnamed Doctor'),
                      trailing: ElevatedButton(
                        onPressed: () => bookAppointment(doctor['id']),
                        child: const Text('Book'),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
