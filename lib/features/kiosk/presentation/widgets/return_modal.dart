import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/book_cover_image.dart';
import '../../application/return_notifier.dart';
import '../../domain/models/scanned_book_view.dart';

class ReturnModal extends ConsumerWidget {
  final ScannedBookView bookView;

  const ReturnModal({super.key, required this.bookView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnState = ref.watch(returnNotifierProvider);
    final returnNotifier = ref.read(returnNotifierProvider.notifier);

    final book = bookView.book;
    final loan = bookView.activeLoan;
    final borrower = bookView.activeBorrower;

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedLoanDate = loan != null ? dateFormat.format(loan.dataEmprestimo) : 'Data não registrada';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      backgroundColor: Colors.white,
      child: Container(
        width: 640,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_return_rounded,
                    size: 28,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Devolução de Livro',
                        style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Este exemplar encontra-se emprestado no momento',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Book Info Summary Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCoverImage(
                  coverUrl: bookView.coverUrl,
                  title: book.titulo,
                  author: book.autor,
                  width: 110,
                  height: 155,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.titulo,
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.autor ?? 'Autor desconhecido',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInlineInfo('Área:', book.areaConhecimento ?? 'Geral'),
                      const SizedBox(height: 4),
                      _buildInlineInfo('Ano:', book.anoPublicacao ?? 'N/A'),
                      const SizedBox(height: 4),
                      _buildInlineInfo('Código:', book.codigoExemplar),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 20),
            // Loan Details Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Dados do Empréstimo',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Aluno:', style: AppTypography.bodySmall),
                            Text(
                              borrower?.nome ?? 'Aluno não identificado',
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RM/RA:', style: AppTypography.bodySmall),
                          Text(
                            borrower?.rmRa ?? 'N/A',
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Data de Empréstimo: ',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        formattedLoanDate,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (returnState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                returnState.errorMessage!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 24),
            // Action Buttons: "Cancelar" e "Devolver"
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: returnState.isLoading ? null : () => Navigator.of(context).pop(false),
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
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: returnState.isLoading
                          ? null
                          : () async {
                              final success = await returnNotifier.confirmReturn(book.id);
                              if (success && context.mounted) {
                                Navigator.of(context).pop(true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: returnState.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.print_rounded, size: 20),
                      label: Text(
                        'Devolver & Imprimir Comprovante',
                        style: AppTypography.buttonLarge.copyWith(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineInfo(String label, String value) {
    return Row(
      children: [
        Text(
          '$label ',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
