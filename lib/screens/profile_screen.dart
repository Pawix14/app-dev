import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for rootBundle
import 'package:finallanggo/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _avatarPath = 'assets/images/whiteboy.png'; 

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _nameController.text = prefs.getString('userName') ?? '';
        _ageController.text = prefs.getInt('userAge')?.toString() ?? ''; // Load age
        _avatarPath = prefs.getString('userAvatar') ?? 'assets/images/whiteboy.png';
      });

      if (!await _imageExists(_avatarPath)) {
        setState(() {
          _avatarPath = 'assets/images/whiteboy.png'; // Reset to default if the image doesn't exist
        });
      }

      // Ensure currentUser is updated if it exists in your app
      if (currentUser != null) {
        currentUser.name = _nameController.text;
        currentUser.avatar = _avatarPath;
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load profile data.');
    }
  }

  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setInt('userAge', int.tryParse(_ageController.text) ?? 0); // Save age
      await prefs.setString('userAvatar', _avatarPath); // Ensure avatar is saved

      setState(() {
        if (currentUser != null) {
          currentUser.name = _nameController.text;
          currentUser.avatar = _avatarPath;
        }
      });

      _showSuccessSnackBar('Profile saved successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to save profile.');
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<bool> _imageExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.green))),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.red))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'View your progress and achievements',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildUserCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Implement image picker logic here
                _showSuccessSnackBar('Image picker not implemented.');
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(_avatarPath),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}