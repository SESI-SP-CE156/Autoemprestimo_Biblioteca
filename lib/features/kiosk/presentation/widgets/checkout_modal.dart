import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/barcode_scanner_listener.dart';
import '../../application/checkout_notifier.dart';

class CheckoutModal extends ConsumerStatefulWidget {
  final Book book;

  const CheckoutModal({super.key, required this.book});

  @override
  ConsumerState<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
  final FocusNode _cardFocusNode = FocusNode();

  @override
  void dispose() {
    _cardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);

    final hasStudent = checkoutState.student != null;

    return BarcodeScannerListener(
      focusNode: _cardFocusNode,
      autoFocus: true,
      onBarcodeScanned: (cardCode) {
        if (!hasStudent && !checkoutState.isLoading) {
          checkoutNotifier.onCardScanned(cardCode);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 12,
        backgroundColor: Colors.white,
        child: Container(
          width: 580,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon & Title
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.badge_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Confirmação de Empréstimo',
                style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Livro: "${widget.book.titulo}"',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              // Body State: Waiting for card scan OR Student Scanned
              if (!hasStudent) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: checkoutState.isNotFound ? AppColors.error : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (checkoutState.isLoading) ...[
                        const CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Identificando aluno...',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ] else ...[
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 54,
                          color: checkoutState.isNotFound ? AppColors.error : AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aproxime sua carteirinha do leitor',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'O código de barras do seu RM/RA será lido automaticamente',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                      if (checkoutState.isNotFound) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Carteirinha não encontrada. Procure o bibliotecário.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Cancel button only when waiting
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Cancelar',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else ...[
                // Student Found Details & Segment Rules
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: (checkoutState.eligibility?.canBorrow == false)
                        ? AppColors.errorLight
                        : AppColors.successLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (checkoutState.eligibility?.canBorrow == false)
                          ? AppColors.error
                          : AppColors.success.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (checkoutState.eligibility?.canBorrow == false)
                                    ? AppColors.error
                                    : AppColors.success,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              (checkoutState.eligibility?.canBorrow == false)
                                  ? Icons.person_off_rounded
                                  : Icons.person_rounded,
                              size: 30,
                              color: (checkoutState.eligibility?.canBorrow == false)
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  checkoutState.student!.nome,
                                  style: AppTypography.headlineMedium.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'RM/RA: ${checkoutState.student!.rmRa}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (checkoutState.eligibility != null) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Prazo de Devolução', style: AppTypography.bodySmall),
                                const SizedBox(height: 2),
                                Text(
                                  '${checkoutState.eligibility!.loanPeriodDays} dias',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 28, color: AppColors.border),
                            Column(
                              children: [
                                Text('Livros Ativos', style: AppTypography.bodySmall),
                                const SizedBox(height: 2),
                                Text(
                                  '${checkoutState.eligibility!.activeLoansCount} de ${checkoutState.eligibility!.maxAllowedLoans}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: (checkoutState.eligibility!.canBorrow)
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (checkoutState.eligibility?.canBorrow == false) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                checkoutState.eligibility?.blockReason ?? 'Limite de empréstimos atingido.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (checkoutState.eligibility!.activeLoans.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Livros atualmente em posse:',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          ...checkoutState.eligibility!.activeLoans.map(
                            (l) => Text(
                              '• ${l.bookTitle}${l.dueDate != null ? " (Devolver até ${DateFormat('dd/MM').format(l.dueDate!)})" : ""}',
                              style: AppTypography.bodySmall.copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // 3 Action Buttons:
                // 1. Concluir Empréstimo
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: (checkoutState.isLoading || (checkoutState.eligibility?.canBorrow == false))
                        ? null
                        : () async {
                            final success = await checkoutNotifier.confirmCheckout(widget.book.id);
                            if (success && context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: checkoutState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.print_rounded, size: 22),
                    label: Text(
                      'Concluir & Imprimir Comprovante',
                      style: AppTypography.buttonLarge.copyWith(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // 2. Corrigir Carteirinha
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: checkoutState.isLoading
                              ? null
                              : () {
                                  checkoutNotifier.clearStudent();
                                  _cardFocusNode.requestFocus();
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: const BorderSide(color: AppColors.warning, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(
                            'Corrigir Carteirinha',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 3. Cancelar
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: checkoutState.isLoading ? null : () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            'Cancelar',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
