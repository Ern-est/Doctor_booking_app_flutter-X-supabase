import 'package:flutter/material.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final String doctorId;

  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Details')),
      body: Center(child: Text('Showing details for Doctor ID: $doctorId')),
    );
  }
}
