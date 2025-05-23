import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:impara_gurbani/Metodi.dart';
import 'package:impara_gurbani/Tema.dart';
import 'package:impara_gurbani/main.dart';
import 'dart:async';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  _AccountManagementPageState createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  late String username;
  late String email;
  String? profileImageUrl;
  bool _isLoading = false;
  late ThemeData theme;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      username = user?.displayName ?? "No name provided";
      email = user?.email ?? "No email provided";
      profileImageUrl = user?.photoURL;
    });
  }

  Future<void> _editAccountDetails() async {
    final result = await showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        username: username,
        currentImageUrl: profileImageUrl,
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (result['imageUrl'] != null) {
            await user.updatePhotoURL(result['imageUrl']);
          }

          if (result['username'] != username) {
            await user.updateDisplayName(result['username']);
          }

          await user.reload();
          _loadUserData();

          _showSuccessSnackbar("Profile updated successfully");
        }
      } catch (e) {
        _showErrorSnackbar("Error updating profile: ${e.toString()}");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(),
    );

    if (result != null && result is Map<String, String>) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: result['currentPassword']!,
          );

          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(result['newPassword']!);

          _showSuccessSnackbar("Password changed successfully");
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        _handlePasswordError(e);
      } catch (e) {
        _showErrorSnackbar("Error changing password: ${e.toString()}");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handlePasswordError(FirebaseAuthException e) {
    String errorMessage = "Error changing password";
    if (e.code == 'wrong-password') {
      errorMessage = "Current password is incorrect";
    } else if (e.code == 'weak-password') {
      errorMessage = "New password is too weak";
    }
    _showErrorSnackbar(errorMessage);
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: Theme.of(context).textTheme.titleLarge),
        content: Text("Are you sure you want to logout?", 
          style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: AppTheme.secondaryColor)),
          ),
          TextButton(
            onPressed: _confirmLogout,
            child: Text("Logout", style: TextStyle(color: AppTheme.errorColor)),
          )
          
        ],
      ),
    );
  }

  void _confirmLogout() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyApp()),
      (route) => false,
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => DeleteAccountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Scaffold(
      appBar: AppBarTitle('Account'),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.defaultPadding),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  _buildAccountDetailsCard(),
                  const SizedBox(height: 24),
                  _buildActionsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _editAccountDetails,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.surface,
            backgroundImage: profileImageUrl != null ? AssetImage(profileImageUrl!) : null,
            child: profileImageUrl == null
                ? Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onSurface)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(username, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        )),
      ],
    );
  }

  Widget _buildAccountDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailItem(
              icon: Icons.person_outline,
              title: "Username",
              value: username,
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.email_outlined,
              title: "Email",
              value: email,
            ),
            const Divider(height: 24),
            _buildDetailItem(
              icon: Icons.security_outlined,
              title: "Password",
              value: "••••••••",
              isSensitive: true,
              onTap: _changePassword,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool isSensitive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: AppTheme.iconSize, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
            if (isSensitive)
              Icon(Icons.chevron_right_outlined, size: 20, color: Theme.of(context).disabledColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.edit_outlined,
          title: "Edit Profile",
          onTap: _editAccountDetails,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.password_outlined,
          title: "Change Password",
          onTap: _changePassword,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.logout_outlined,
          title: "Logout",
          color: AppTheme.errorColor,
          onTap: _logout,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.delete_outline,
          title: "Delete Account",
          color: AppTheme.errorColor,
          onTap: _deleteAccount,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? (theme.brightness == Brightness.dark
             ? theme.colorScheme.secondary // Colore per tema scuro
             : theme.colorScheme.primary   // Colore per tema chiaro
         ),),
            const SizedBox(width: 16),
            Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
            )),
            const Spacer(),
            Icon(Icons.chevron_right_outlined, color: Theme.of(context).disabledColor),
          ],
        ),
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final String username;
  final String? currentImageUrl;

  const EditProfileDialog({
    required this.username,
    this.currentImageUrl,
    Key? key,
  }) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _usernameController;
  String? _selectedImageUrl;

  final List<String> _predefinedImages = [
    'assets/images/Uomo.png',
    'assets/images/Donna.png',
    'assets/images/Bambino.png',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _selectedImageUrl = widget.currentImageUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Edit Profile", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text("Choose your avatar", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _predefinedImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedImageUrl = _predefinedImages[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      border: _selectedImageUrl == _predefinedImages[index]
                          ? Border.all(color: AppTheme.primaryColor, width: 3)
                          : null,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(_predefinedImages[index]),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                ),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    child: Text("Cancel", style: TextStyle(color: AppTheme.secondaryColor)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    child: Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Username cannot be empty"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'username': _usernameController.text,
      'imageUrl': _selectedImageUrl,
    });
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Change Password", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              _buildPasswordField(
                controller: _currentPasswordController,
                label: "Current Password",
                obscureText: _obscureCurrentPassword,
                onToggleVisibility: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your current password' : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPasswordController,
                label: "New Password",
                obscureText: _obscureNewPassword,
                onToggleVisibility: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter a new password';
                  if (value!.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: "Confirm New Password",
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (value) => value != _newPasswordController.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                        ),
                      ),
                      child: Text("Cancel", style: TextStyle(color: AppTheme.secondaryColor)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitPasswordChange,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                        ),
                      ),
                      child: Text("Change Password", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        ),
        prefixIcon: Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }

  void _submitPasswordChange() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      });
    }
  }
}

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({Key? key}) : super(key: key);

  @override
  _DeleteAccountDialogState createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  int _counter = 5;
  late Timer _timer;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() => _counter--);
      } else {
        setState(() => _isButtonEnabled = true);
        _timer.cancel();
      }
    }
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account deleted successfully"),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting account: ${e.toString()}"),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 60, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text("Delete Account?", style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.errorColor,
            )),
            const SizedBox(height: 16),
            Text(
              "This action is irreversible. All your data will be permanently deleted.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              ),
              child: Column(
                children: [
                  Text("Confirmation will be enabled in:", 
                    style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text("$_counter seconds", style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.errorColor,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _timer.cancel();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    child: Text("Cancel", style: TextStyle(color: AppTheme.secondaryColor)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? _deleteAccount : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled ? AppTheme.errorColor : 
                        AppTheme.errorColor.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    child: Text("Delete", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}