import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // for nice date formatting

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String _selectedStatusFilter = 'All';

  final List<String> statusOptions = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    var query = supabase
        .from('appointments')
        .select(
          'id, appointment_date, reason, status, users:patient_id (full_name)',
        );

    if (_selectedStatusFilter != 'All') {
      query = query.eq('status', _selectedStatusFilter);
    }

    final response = await query
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
          'Doctor Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/doctor-profile');
            },
          ),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: DropdownButtonFormField<String>(
                value: _selectedStatusFilter,
                items:
                    statusOptions
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatusFilter = value!;
                    isLoading = true;
                  });
                  fetchAppointments();
                },
                decoration: InputDecoration(
                  labelText: 'Filter by Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF009688),
                        ),
                      )
                      : appointments.isEmpty
                      ? Center(
                        child: Text(
                          "No appointments yet.",
                          style: TextStyle(
                            fontSize: 18,
                            color: primaryColor.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: appointments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final appt = appointments[index];
                          final patientName =
                              appt['users']['full_name'] ?? 'Unknown';
                          final dateTime = DateTime.parse(
                            appt['appointment_date'],
                          );
                          final formattedDate = DateFormat(
                            'EEE, MMM d, yyyy – hh:mm a',
                          ).format(dateTime.toLocal());
                          final status = appt['status'] ?? 'Pending';

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Patient: $patientName",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Reason: ${appt['reason']}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Date: $formattedDate",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Status: $status",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _statusColor(status),
                                          fontSize: 16,
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          if (status == 'Pending') ...[
                                            ElevatedButton(
                                              onPressed:
                                                  () => updateStatus(
                                                    appt['id'],
                                                    'Confirmed',
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text('Accept'),
                                            ),
                                            ElevatedButton(
                                              onPressed:
                                                  () => updateStatus(
                                                    appt['id'],
                                                    'Cancelled',
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text('Decline'),
                                            ),
                                          ] else if (status == 'Confirmed') ...[
                                            ElevatedButton(
                                              onPressed:
                                                  () => updateStatus(
                                                    appt['id'],
                                                    'Completed',
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text('Mark Done'),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
