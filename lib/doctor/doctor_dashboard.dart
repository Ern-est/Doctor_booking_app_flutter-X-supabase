// lib/doctor/doctor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('appointments')
        .select(
          'id, appointment_date, reason, status, users:patient_id (full_name)',
        )
        .eq('doctor_id', userId)
        .order('appointment_date', ascending: true);

    setState(() {
      appointments = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await supabase.from('appointments').update({'status': status}).eq('id', id);
    fetchAppointments(); // Refresh list
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
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
              : appointments.isEmpty
              ? const Center(child: Text("No appointments yet."))
              : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  final patientName = appt['users']['full_name'] ?? 'Unknown';
                  final dateTime = DateTime.parse(appt['appointment_date']);
                  final status = appt['status'] ?? 'Pending';

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text("Patient: $patientName"),
                      subtitle: Text(
                        "${appt['reason']}\n${dateTime.toLocal()}",
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: getStatusColor(status),
                            ),
                          ),
                          if (status == 'Pending') ...[
                            TextButton(
                              onPressed:
                                  () => updateStatus(appt['id'], 'Confirmed'),
                              child: const Text("Accept"),
                            ),
                            TextButton(
                              onPressed:
                                  () => updateStatus(appt['id'], 'Cancelled'),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          if (status == 'Confirmed') ...[
                            TextButton(
                              onPressed:
                                  () => updateStatus(appt['id'], 'Completed'),
                              child: const Text("Mark Done"),
                            ),
                            TextButton(
                              onPressed:
                                  () => updateStatus(appt['id'], 'Cancelled'),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
