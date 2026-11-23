import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/book_cover_image.dart';

class BookInfoCard extends StatelessWidget {
  final Book? book;
  final String? coverUrl;
  final bool isLoading;
  final VoidCallback? onCheckoutPressed;

  const BookInfoCard({
    super.key,
    this.book,
    this.coverUrl,
    this.isLoading = false,
    this.onCheckoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = book?.status == 'Disponível';

    final effectiveTitle = book?.titulo ?? 'Título de Exemplo do Livro';
    final effectiveAuthor = book?.autor ?? 'Nome do Autor / Ordenar';
    final effectiveArea = book?.areaConhecimento ?? 'Área do Conhecimento';
    final effectiveYear = book?.anoPublicacao ?? '2024';
    final effectiveBarcode = book?.codigoExemplar ?? '00000000';
    final effectiveClassification = book?.classificacao ?? 'CDD 000';

    return Skeletonizer(
      enabled: isLoading,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar with Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAvailable ? AppColors.successLight : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAvailable ? AppColors.success : AppColors.warning,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle_rounded : Icons.lock_clock_rounded,
                          size: 16,
                          color: isAvailable ? AppColors.success : AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAvailable ? 'Exemplar Disponível' : 'Exemplar Emprestado',
                          style: AppTypography.bodySmall.copyWith(
                            color: isAvailable ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Código: $effectiveBarcode',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Center Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCoverImage(
                    coverUrl: coverUrl,
                    title: effectiveTitle,
                    author: effectiveAuthor,
                    width: 170,
                    height: 245,
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          effectiveTitle,
                          style: AppTypography.headlineLarge.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          effectiveAuthor,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: AppColors.divider),
                        const SizedBox(height: 16),
                        _buildMetaRow(
                          icon: Icons.category_rounded,
                          label: 'Área do Conhecimento',
                          value: effectiveArea,
                        ),
                        const SizedBox(height: 10),
                        _buildMetaRow(
                          icon: Icons.calendar_month_rounded,
                          label: 'Ano de Publicação',
                          value: effectiveYear,
                        ),
                        const SizedBox(height: 10),
                        _buildMetaRow(
                          icon: Icons.bookmark_border_rounded,
                          label: 'Classificação',
                          value: effectiveClassification,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Action Button
              if (isAvailable)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onCheckoutPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.library_add_check_rounded, size: 24),
                    label: Text(
                      'Emprestar Livro',
                      style: AppTypography.buttonLarge.copyWith(fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
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
