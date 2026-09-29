import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final user = c.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: context.bg1,
        body: const Center(child: Text('Sesión no iniciada')),
      );
    }

    return Scaffold(
      backgroundColor: context.bg1,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: context.isDarkMode
                      ? [const Color(0xFF1A0000), Colors.black]
                      : [Colors.red.shade900, AppColors.strongRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.strongRed.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => context.go('/garage'),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(text: 'Mi '),
                              TextSpan(
                                text: 'Perfil',
                                style: TextStyle(color: AppColors.strongRed),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tu información, siempre segura',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Top Profile Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: context.isDarkMode
                      ? [const Color(0xFF1A0000), Colors.black]
                      : [Colors.red.shade900, AppColors.strongRed],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.strongRed),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.strongRed.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with Camera Badge
                  Stack(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.strongRed.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.strongRed, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.strongRed.withValues(alpha: 0.5),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: const Icon(Icons.two_wheeler, color: Colors.white, size: 36),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.strongRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                user.email,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Edit Button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Fields
            _buildProfileField(
              context,
              icon: Icons.person_outline,
              label: 'Nombre',
              value: user.name,
            ),
            const SizedBox(height: 12),
            _buildProfileField(
              context,
              icon: Icons.two_wheeler,
              label: 'Modelo',
              value: user.bikeModel,
            ),
            const SizedBox(height: 12),
            _buildProfileField(
              context,
              icon: Icons.pin,
              label: 'Placa',
              value: user.bikePlate,
            ),

            const SizedBox(height: 32),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.strongRed.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.strongRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Update profile action
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.edit_square),
                      SizedBox(width: 12),
                      Text('Guardar cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.textPrimary,
                    side: BorderSide(color: AppColors.strongRed.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    c.handleLogout();
                    context.go('/login');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, color: AppColors.strongRed),
                      SizedBox(width: 12),
                      Text('Cerrar sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.strongRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.strongRed, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.bg1,
              shape: BoxShape.circle,
              border: Border.all(color: context.dividerColor),
            ),
            child: Icon(Icons.edit, color: context.textSecondary, size: 16),
          ),
        ],
      ),
    );
  }
}
