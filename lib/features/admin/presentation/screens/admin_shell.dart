import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/sesi_header.dart';
import '../../../auth/application/auth_notifier.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SesiHeader(
            isAdminArea: true,
            onAdminButtonPressed: () {
              context.go('/');
            },
          ),
          Expanded(
            child: Row(
              children: [
                // Navigation Sidebar
                Container(
                  width: 260,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildNavItem(
                        context: context,
                        icon: Icons.menu_book_rounded,
                        label: 'Acervo & Patrimônio',
                        isSelected: location.startsWith('/admin/inventory'),
                        onTap: () => context.go('/admin/inventory'),
                      ),
                      _buildNavItem(
                        context: context,
                        icon: Icons.people_alt_rounded,
                        label: 'Gestão de Alunos',
                        isSelected: location.startsWith('/admin/students'),
                        onTap: () => context.go('/admin/students'),
                      ),
                      _buildNavItem(
                        context: context,
                        icon: Icons.manage_accounts_rounded,
                        label: 'Editar Perfil Admin',
                        isSelected: location.startsWith('/admin/profile'),
                        onTap: () => context.go('/admin/profile'),
                      ),
                      const Spacer(),
                      const Divider(color: AppColors.divider),
                      _buildNavItem(
                        context: context,
                        icon: Icons.logout_rounded,
                        label: 'Encerrar Sessão',
                        isSelected: false,
                        isDestructive: true,
                        onTap: () async {
                          await authNotifier.logout();
                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Content View
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.error
        : (isSelected ? AppColors.primary : AppColors.textPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
