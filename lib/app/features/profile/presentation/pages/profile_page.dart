import 'package:flutter/material.dart';
import 'package:agentic_ai/app/features/authentication/presentation/pages/login_page.dart';
import '../../../authentication/data/models/profile_model.dart';
import '../../../authentication/data/repositories/auth_service.dart';
import '../../../authentication/data/repositories/profile_service.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileData? _profileData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final profileResponse = await ProfileService.getProfile();

      if (profileResponse.success) {
        setState(() {
          _profileData = profileResponse.data;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Clear local data
      await AuthService.logout();

      // Navigate to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditProfileDialog() {
    if (_profileData == null) return;

    final nameController = TextEditingController(text: _profileData!.name);
    final emailController = TextEditingController(text: _profileData!.email);
    final phoneController = TextEditingController(text: _profileData!.phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateProfile(
                  nameController.text.trim(),
                  emailController.text.trim(),
                  phoneController.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfile(String name, String email, String phone) async {
    try {
      final response = await ProfileService.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );

      if (response.success) {
        setState(() {
          _profileData = response.data;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                await _changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    try {
      final success = await ProfileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_profileData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('No profile data available'),
        ),
      );
    }

    final profileUser = _profileData!.toProfileUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              color: theme.primaryColor,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(profileUser.profileImageUrl),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profileUser.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profileUser.email,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profileData!.phone,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Account Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Member Since',
                          '${_profileData!.createdAt.day}/${_profileData!.createdAt.month}/${_profileData!.createdAt.year}'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Last Updated',
                          '${_profileData!.updatedAt.day}/${_profileData!.updatedAt.month}/${_profileData!.updatedAt.year}'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Menu Options
            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(
                    context,
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: _showEditProfileDialog,
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: _showChangePasswordDialog,
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings tapped!')),
                      );
                    },
                  ),
                  _buildProfileOption(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & Support tapped!')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}