import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  bool _isLoading = true;
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final details = await AuthService.getUserDetails();
    
    if (!mounted) return;
    
    setState(() {
      _studentId = details['studentId'] ?? '';
      _nameController.text = details['name'] ?? '';
      _emailController.text = details['email'] ?? '';
      _ageController.text = details['age'] == 0 ? '' : details['age'].toString();
      
      final gender = details['gender'] ?? '';
      if (_genderOptions.contains(gender)) {
        _selectedGender = gender;
      } else {
        _selectedGender = null;
      }
      
      _isLoading = false;
    });
  }

  Future<void> _saveDetails() async {
    await AuthService.updateUserDetails(
      name: _nameController.text,
      email: _emailController.text,
      age: int.tryParse(_ageController.text),
      gender: _selectedGender,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherit dark theme from main
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.tealAccent,
                    child: Icon(Icons.person, size: 30, color: Color(0xFF1B1B26)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isNotEmpty ? _nameController.text : 'Student Profile',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'ID: $_studentId',
                        style: const TextStyle(fontSize: 14, color: Colors.tealAccent, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                ],
              ),
              
              const SizedBox(height: 32),

              const Text(
                "Personal Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.people_outline),
                      ),
                      items: _genderOptions
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SAVE DETAILS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
