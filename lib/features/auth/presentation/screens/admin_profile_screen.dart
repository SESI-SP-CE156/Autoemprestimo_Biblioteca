import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../application/auth_notifier.dart';

class AdminProfileScreen extends HookConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final user = ref.read(authNotifierProvider).currentUser;

    final nameController = useTextEditingController(text: user?.name ?? '');
    final emailController = useTextEditingController(text: user?.email ?? '');
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final obscurePassword = useState(true);

    final authState = ref.watch(authNotifierProvider);

    Future<void> handleSave() async {
      if (!formKey.currentState!.validate()) return;

      final newPass = newPasswordController.text.trim();
      final authNotifier = ref.read(authNotifierProvider.notifier);

      final success = await authNotifier.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        newPassword: newPass.isNotEmpty ? newPass : null,
      );

      if (context.mounted) {
        if (success) {
          newPasswordController.clear();
          confirmPasswordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ref.read(authNotifierProvider).errorMessage ?? 'Falha ao atualizar perfil.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Editar Perfil do Administrador',
                            style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Atualize suas credenciais e dados de acesso',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 20),
                  Text('Nome Completo *', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome completo' : null,
                  ),
                  const SizedBox(height: 18),
                  Text('E-mail Institucional *', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Informe o e-mail' : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Alterar Senha (deixe em branco para manter a atual)',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: obscurePassword.value,
                    decoration: InputDecoration(
                      labelText: 'Nova Senha',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: () => obscurePassword.value = !obscurePassword.value,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscurePassword.value,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Nova Senha',
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (newPasswordController.text.isNotEmpty && v != newPasswordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: authState.isLoading ? null : handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: authState.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded, size: 20),
                      label: Text(
                        authState.isLoading ? 'Salvando...' : 'Salvar Dados do Perfil',
                        style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
