import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../application/student_list_notifier.dart';
import '../widgets/student_loan_history_dialog.dart';

class StudentsScreen extends HookConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final state = ref.watch(studentListNotifierProvider);
    final notifier = ref.read(studentListNotifierProvider.notifier);

    Future<void> handleImportExcel() async {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        dialogTitle: 'Selecionar Planilha de Alunos (.xlsx)',
      );

      if (result.isNotEmpty && result.first.path != null) {
        final filePath = result.first.path!;
        final count = await notifier.importFromExcel(filePath);

        if (context.mounted) {
          if (count != null && count > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$count alunos importados com sucesso!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      'Nenhum aluno foi importado. Verifique se o cabeçalho possui "Nome do Estudante" e "RM/RA".',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    }

    Future<void> handleImportPdf() async {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        dialogTitle: 'Selecionar Diário de Classe em PDF (.pdf)',
      );

      if (result.isNotEmpty && result.first.path != null) {
        final filePath = result.first.path!;
        final res = await notifier.importFromPdf(filePath);

        if (context.mounted) {
          if (res != null && res.inserted > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${res.inserted} alunos importados/atualizados com sucesso a partir do diário PDF!',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            final error = (res != null && res.errorMessages.isNotEmpty)
                ? res.errorMessages.first
                : (state.errorMessage ??
                    'Nenhum aluno foi importado. Verifique se o arquivo é um diário de classe PDF com texto selecionável.');

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('Atenção ao importar PDF'),
                  ],
                ),
                content: Text(
                  error,
                  style: GoogleFonts.openSans(fontSize: 14, height: 1.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
    }

    Future<void> showStudentDialog({Student? student}) async {
      final nomeController = TextEditingController(text: student?.nome ?? '');
      final rmRaController = TextEditingController(text: student?.rmRa ?? '');
      final formKey = GlobalKey<FormState>();

      final isEditing = student != null;

      final saved = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(isEditing ? 'Editar Aluno' : 'Cadastrar Novo Aluno'),
            content: SizedBox(
              width: 440,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo do Estudante *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: rmRaController,
                      decoration: const InputDecoration(
                        labelText: 'Código RM/RA (Carteirinha) *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe o RM/RA' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(ctx).pop(true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(isEditing ? 'Salvar Alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      );

      if (saved == true) {
        if (isEditing) {
          await notifier.updateStudent(
            student.copyWith(
              nome: nomeController.text.trim(),
              rmRa: rmRaController.text.trim(),
              updatedAt: DateTime.now(),
            ),
          );
        } else {
          await notifier.createStudent(
            StudentsCompanion(
              nome: drift.Value(nomeController.text.trim()),
              rmRa: drift.Value(rmRaController.text.trim()),
              ativo: const drift.Value(true),
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestão de Estudantes',
                        style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cadastro e importação de carteirinhas de alunos (${state.totalStudents} estudantes cadastrados)',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => showStudentDialog(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                  label: Text('Novo Aluno', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: state.isImporting ? null : handleImportExcel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.table_view_rounded, size: 20),
                  label: Text(
                    'Planilha (.xlsx)',
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: state.isImporting ? null : handleImportPdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: state.isImporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_rounded, size: 20),
                  label: Text(
                    state.isImporting ? 'Importando...' : 'Importar Diário (.pdf)',
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar aluno por nome ou RM/RA...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          searchController.clear();
                          notifier.onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (val) => notifier.onSearchChanged(val),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : state.students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.badge_outlined, size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum estudante cadastrado',
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Clique em "Novo Aluno" ou importe uma planilha .xlsx.',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                                columns: [
                                  DataColumn(label: Text('Nome do Estudante', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('RM / RA (Carteirinha)', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Status', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Ações', style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                                ],
                                rows: state.students.map((student) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 14,
                                              backgroundColor: AppColors.surfaceVariant,
                                              child: Icon(Icons.person, size: 16, color: AppColors.primary),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(student.nome, style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(student.rmRa, style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: student.ativo ? AppColors.successLight : AppColors.errorLight,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            student.ativo ? 'Ativo' : 'Inativo',
                                            style: GoogleFonts.openSans(
                                              color: student.ativo ? AppColors.success : AppColors.error,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.history_edu_rounded, size: 18, color: AppColors.primary),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => StudentLoanHistoryDialog(student: student),
                                                );
                                              },
                                              tooltip: 'Histórico de Empréstimos do Aluno',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                                              onPressed: () => showStudentDialog(student: student),
                                              tooltip: 'Editar Aluno',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text('Excluir Aluno'),
                                                    content: Text('Deseja excluir "${student.nome}" (${student.rmRa})?'),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                                      TextButton(
                                                        onPressed: () => Navigator.of(ctx).pop(true),
                                                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                                        child: const Text('Excluir'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  notifier.deleteStudent(student.id);
                                                }
                                              },
                                              tooltip: 'Excluir Aluno',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
