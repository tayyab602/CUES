import 'dart:math'; //  ADDED: Required for generating random discriminator tags
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _selectedDepartment;
  String? _selectedSemester;

  final List<Map<String, dynamic>> _departmentItems = [
    {'label': '── Computer Science ──', 'isHeader': true},
    {'label': 'BSCS - Computer Sciences', 'isHeader': false},
    {'label': 'BSCYS - Cyber Security', 'isHeader': false},
    {'label': 'BSSE - Software Engineering', 'isHeader': false},
    {'label': 'MSCS - Computer Sciences', 'isHeader': false},
    {'label': 'PhD Computer Science', 'isHeader': false},

    {'label': '── Electrical & Avionics Engineering ──', 'isHeader': true},
    {'label': 'BEE - Electrical Engineering', 'isHeader': false},
    {'label': 'MS AvE - Avionics Engineering', 'isHeader': false},
    {'label': 'MS EE - Electrical Engineering', 'isHeader': false},
    {'label': 'PhD EE - Electrical Engineering', 'isHeader': false},

    {'label': '── Mechanical & Aerospace Engineering ──', 'isHeader': true},
    {'label': 'BE ME - Mechanical Engineering', 'isHeader': false},
    {'label': 'MS ME - Mechanical Engineering', 'isHeader': false},
    {'label': 'MS AE - Aerospace Engineering', 'isHeader': false},
    {'label': 'PhD ME - Mechanical Engineering', 'isHeader': false},

    {'label': '── Business Administration ──', 'isHeader': true},
    {'label': 'BBA - Business Administration', 'isHeader': false},
    {'label': 'BSAvM - Aviation Management', 'isHeader': false},
    {'label': 'BS Fintech', 'isHeader': false},
    {'label': 'BSBA - Business Administration', 'isHeader': false},
    {'label': 'BSBIT - Business & IT', 'isHeader': false},
    {'label': 'MS Management Science', 'isHeader': false},

    {'label': '── Computer & Software Engineering ──', 'isHeader': true},
    {'label': 'BS Computer & Software Engineering', 'isHeader': false},
  ];

  final List<String> _semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
    'MS - Semester 1',
    'MS - Semester 2',
    'MS - Semester 3',
    'MS - Semester 4',
    'PhD',
  ];

  bool _isValidEmail(String email) {
    email = email.trim();
    if (email.contains('@')) {
      return email.endsWith('@aack.au.edu.pk');
    }
    return email.isNotEmpty;
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    String email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      _showError('Only @aack.au.edu.pk email addresses are allowed');
      return;
    }

    if (!email.contains('@')) {
      email = '$email@aack.au.edu.pk';
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    if (_selectedDepartment == null) {
      _showError('Please select your department/program');
      return;
    }
    if (_selectedSemester == null) {
      _showError('Please select your semester');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Extract prefix string from email to serve as basic base username
      String emailPrefix = email.split('@')[0];

      // 2. Generate Discord-style unique numerical tag snippet
      int randomSuffix = Random().nextInt(9000) + 1000; // Generates 1000 - 9999
      String uniqueSearchTag = '$emailPrefix#$randomSuffix';

      // 3. Pass uniqueSearchTag safely into registration pipeline
      await _authService.register(
        name: _nameController.text.trim(),
        email: email,
        password: _passwordController.text.trim(),
        department: _selectedDepartment!,
        semester: _selectedSemester!,
        searchTag: uniqueSearchTag, //  UPDATED: Sending data to service
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'AACK university emails only',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              _buildTextField(_nameController, 'Full Name', Icons.person),
              const SizedBox(height: 16),

              _buildTextField(
                _emailController,
                'University Email',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
                hintText: 'username',
                suffixText: '@aack.au.edu.pk',
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Department / Program',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: _departmentItems.map((item) {
                  final bool isHeader = item['isHeader'] as bool;
                  return DropdownMenuItem<String>(
                    value: isHeader ? null : item['label'] as String,
                    enabled: !isHeader,
                    child: Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: isHeader ? Colors.blue : Colors.black,
                        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                        fontSize: isHeader ? 13 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDepartment = val);
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: _semesters.map((sem) {
                  return DropdownMenuItem(value: sem, child: Text(sem));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSemester = val),
              ),
              const SizedBox(height: 28),

              CustomButton(
                label: 'Register',
                onPressed: _register,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        String? hintText,
        String? suffixText,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffixText,
        suffixStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}