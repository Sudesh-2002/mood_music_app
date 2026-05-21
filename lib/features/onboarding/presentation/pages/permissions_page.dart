import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});
  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _cameraGranted = false;
  bool _storageGranted = false;

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();
    setState(() { _cameraGranted = status.isGranted; });
  }

  Future<void> _requestStorage() async {
    final status = await Permission.storage.request();
    setState(() { _storageGranted = status.isGranted; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                AppStrings.permissionsTitle,
                style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                AppStrings.permissionsSubtitle,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 60),
              _buildPermRow(
                icon: Icons.camera_alt_rounded,
                label: AppStrings.allowCamera,
                granted: _cameraGranted,
                onTap: _requestCamera,
              ),
              const SizedBox(height: 16),
              _buildPermRow(
                icon: Icons.folder_open_rounded,
                label: AppStrings.allowStorage,
                granted: _storageGranted,
                onTap: _requestStorage,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _cameraGranted ? () => context.go('/home') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cameraGranted
                      ? AppColors.primary
                      : AppColors.bgCard,
                ),
                child: const Text('Start listening'),
              ),
              const SizedBox(height: 16),
              if (!_cameraGranted)
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Skip for now',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermRow({
    required IconData icon,
    required String label,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: granted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: granted ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: granted ? AppColors.accent : AppColors.textSecondary,
                size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16, fontWeight: FontWeight.w500,
                  )),
            ),
            Text(
              granted ? AppStrings.permGranted : AppStrings.permDenied,
              style: TextStyle(
                color: granted ? AppColors.accent : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}