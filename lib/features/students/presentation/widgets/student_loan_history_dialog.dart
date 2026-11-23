import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/models/student_loan_history_item.dart';

class StudentLoanHistoryDialog extends ConsumerStatefulWidget {
  final Student student;

  const StudentLoanHistoryDialog({super.key, required this.student});

  @override
  ConsumerState<StudentLoanHistoryDialog> createState() => _StudentLoanHistoryDialogState();
}

class _StudentLoanHistoryDialogState extends ConsumerState<StudentLoanHistoryDialog> {
  late Future<List<StudentLoanHistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ref.read(studentRepositoryProvider).getStudentLoanHistory(widget.student.id);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateOnlyFormat = DateFormat('dd/MM/yyyy');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.all(16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_edu_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Histórico de Empréstimos do Aluno',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${widget.student.nome} (RM: ${widget.student.rmRa})',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 720,
        height: 420,
        child: FutureBuilder<List<StudentLoanHistoryItem>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar histórico: ${snapshot.error}',
                  style: GoogleFonts.openSans(color: AppColors.error),
                ),
              );
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories_rounded, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum livro emprestado ainda',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Este estudante ainda não retirou nenhum livro na biblioteca.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                    columns: [
                      DataColumn(label: Text('Livro / Obra', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Exemplar / ISBN', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Data que Pegou', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Prazo Previsto', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Data que Devolveu', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                    ],
                    rows: items.map((item) {
                      Color statusBg;
                      Color statusText;
                      String statusLabel;

                      if (item.isDevolvido) {
                        statusBg = AppColors.successLight;
                        statusText = AppColors.success;
                        statusLabel = 'Devolvido';
                      } else if (item.isAtrasado) {
                        statusBg = AppColors.errorLight;
                        statusText = AppColors.error;
                        statusLabel = 'Em atraso';
                      } else {
                        statusBg = AppColors.warningLight;
                        statusText = AppColors.warning;
                        statusLabel = 'Em andamento';
                      }

                      return DataRow(
                        cells: [
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                item.bookTitle,
                                style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.bookIsbn != null && item.bookIsbn!.trim().isNotEmpty
                                  ? '${item.bookBarcode} (${item.bookIsbn!.trim()})'
                                  : item.bookBarcode,
                              style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(Text(dateFormat.format(item.dataEmprestimo))),
                          DataCell(
                            Text(
                              item.dataDevolucaoPrevista != null
                                  ? dateOnlyFormat.format(item.dataDevolucaoPrevista!)
                                  : '-',
                            ),
                          ),
                          DataCell(
                            Text(
                              item.dataDevolucaoEfetiva != null
                                  ? dateFormat.format(item.dataDevolucaoEfetiva!)
                                  : 'Não devolvido',
                              style: TextStyle(
                                color: item.dataDevolucaoEfetiva != null
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                                fontStyle: item.dataDevolucaoEfetiva == null ? FontStyle.italic : FontStyle.normal,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.openSans(
                                  color: statusText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
