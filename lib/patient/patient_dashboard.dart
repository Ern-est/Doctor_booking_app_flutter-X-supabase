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
    final primaryColor = const Color(0xFF009688);
    final backgroundColor = const Color(0xFFF1F8F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Patient Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF009688)),
                  )
                  : doctors.isEmpty
                  ? Center(
                    child: Text(
                      'No doctors available',
                      style: TextStyle(
                        fontSize: 18,
                        color: primaryColor.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  : ListView.separated(
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Text(
                            doctor['full_name'] ?? 'Unnamed Doctor',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => bookAppointment(doctor['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Book',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
