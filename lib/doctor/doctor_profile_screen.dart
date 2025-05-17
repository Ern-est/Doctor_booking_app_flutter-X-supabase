import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isSaving = false;

  Map<String, dynamic>? profileData;

  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController specialtyController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      profileData = response as Map<String, dynamic>?;

      fullNameController = TextEditingController(text: profileData?['full_name'] ?? '');
      phoneController = TextEditingController(text: profileData?['phone'] ?? '');
      specialtyController = TextEditingController(text: profileData?['specialty'] ?? '');
      bioController = TextEditingController(text: profileData?['bio'] ?? '');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final response = await supabase
          .from('users')
          .update({
            'full_name': fullNameController.text,
            'phone': phoneController.text,
            'specialty': specialtyController.text,
            'bio': bioController.text,
          })
          .eq('id', profileData!['id']);

      if (response == null) {
        throw 'Update failed';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF009688); // Teal for med feel
    final backgroundColor = const Color(0xFFF1F8F7); // Light minty background

    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF009688))),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // Header
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00796B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Full Name
                    _buildTextField(
                      controller: fullNameController,
                      label: 'Full Name',
                      validator: (val) => val == null || val.isEmpty ? 'Please enter full name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone',
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty ? 'Please enter phone number' : null,
                    ),
                    const SizedBox(height: 16),

                    // Specialty
                    _buildTextField(
                      controller: specialtyController,
                      label: 'Specialty',
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    _buildTextField(
                      controller: bioController,
                      label: 'Bio',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 36),

                    // Save button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          isSaving ? 'Saving...' : 'Save Changes',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        onPressed: isSaving ? null : _updateProfile,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final primaryColor = const Color(0xFF009688);
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2.5),
        ),
        filled: true,
        fillColor: const Color(0xFFE0F2F1), // very light teal background for inputs
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    );
  }
}
