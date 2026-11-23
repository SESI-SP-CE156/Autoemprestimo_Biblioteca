import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/book_cover_image.dart';
import '../../application/inventory_notifier.dart';
import '../widgets/book_loan_history_dialog.dart';

class InventoryScreen extends HookConsumerWidget {
  const InventoryScreen({super.key});

  int? _getSortColumnIndex(String? sortBy) {
    switch (sortBy) {
      case 'codigoExemplar':
        return 0;
      case 'titulo':
        return 2;
      case 'autor':
        return 3;
      case 'areaConhecimento':
        return 4;
      case 'anoPublicacao':
        return 5;
      case 'status':
        return 7;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final state = ref.watch(inventoryNotifierProvider);
    final notifier = ref.read(inventoryNotifierProvider.notifier);

    Future<void> handleImportExcel() async {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        dialogTitle: 'Selecionar Planilha de Acervo/Patrimônio (.xlsx)',
      );

      if (result.isNotEmpty && result.first.path != null) {
        final filePath = result.first.path!;
        final importResult = await notifier.importFromExcel(filePath);

        if (context.mounted) {
          if (importResult != null) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      importResult.inserted > 0
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      color: importResult.inserted > 0 ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 10),
                    Text(importResult.inserted > 0 ? 'Importação Concluída' : 'Aviso de Importação'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total de linhas processadas: ${importResult.totalRows}'),
                    Text('Exemplares cadastrados/atualizados: ${importResult.inserted}'),
                    if (importResult.errors > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Erros/Avisos (${importResult.errors}):',
                        style: GoogleFonts.openSans(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: SingleChildScrollView(
                          child: Text(
                            importResult.errorMessages.take(10).join('\n') +
                                (importResult.errorMessages.length > 10 ? '\n...' : ''),
                            style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Falha ao processar arquivo Excel.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
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
                        'Acervo & Patrimônio',
                        style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gerenciamento dos exemplares da biblioteca (${state.totalBooks} livros cadastrados)',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: state.isImporting ? null : handleImportExcel,
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
                      : const Icon(Icons.upload_file_rounded, size: 20),
                  label: Text(
                    state.isImporting ? 'Processando Planilha...' : 'Importar Planilha (.xlsx)',
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por título, autor, código do exemplar ou patrimônio...',
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
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: () => notifier.refresh(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  tooltip: 'Recarregar dados',
                ),
              ],
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
                    : state.books.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.menu_book_outlined, size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum exemplar encontrado no acervo',
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Importe uma planilha .xlsx do acervo para popular os dados.',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        sortColumnIndex: _getSortColumnIndex(state.sortBy),
                                        sortAscending: state.sortAscending,
                                        headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                                        columns: [
                                          DataColumn(
                                            label: Text('Código Exemplar', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                            onSort: (columnIndex, ascending) => notifier.setSorting('codigoExemplar'),
                                          ),
                                          DataColumn(
                                            label: Text('Patrimônio', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                          ),
                                          DataColumn(
                                            label: Text('Título', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                            onSort: (columnIndex, ascending) => notifier.setSorting('titulo'),
                                          ),
                                          DataColumn(
                                            label: Text('Autor (Ordenar)', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                            onSort: (columnIndex, ascending) => notifier.setSorting('autor'),
                                          ),
                                          DataColumn(
                                            label: Text('Área Conhecimento', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                            onSort: (columnIndex, ascending) => notifier.setSorting('areaConhecimento'),
                                          ),
                                          DataColumn(
                                            label: Text('Ano', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                            onSort: (columnIndex, ascending) => notifier.setSorting('anoPublicacao'),
                                          ),
                                          DataColumn(
                                            label: Text('ISBN', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                          ),
                                          DataColumn(
                                            label: Text('Status', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                            onSort: (columnIndex, ascending) => notifier.setSorting('status'),
                                          ),
                                          DataColumn(
                                            label: Text('Ações', style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                        rows: state.books.map((book) {
                                          final isAvail = book.status == 'Disponível';
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(book.codigoExemplar, style: GoogleFonts.openSans(fontWeight: FontWeight.bold))),
                                              DataCell(Text(book.numeroPatrimonio ?? '-')),
                                              DataCell(
                                                ConstrainedBox(
                                                  constraints: const BoxConstraints(maxWidth: 220),
                                                  child: Text(book.titulo.isEmpty ? '(Sem título / Periódico)' : book.titulo, overflow: TextOverflow.ellipsis),
                                                ),
                                              ),
                                              DataCell(
                                                ConstrainedBox(
                                                  constraints: const BoxConstraints(maxWidth: 160),
                                                  child: Text(book.autor ?? '-', overflow: TextOverflow.ellipsis),
                                                ),
                                              ),
                                              DataCell(Text(book.areaConhecimento ?? '-')),
                                              DataCell(Text(book.anoPublicacao ?? '-')),
                                              DataCell(Text(book.isbn ?? '-')),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isAvail ? AppColors.successLight : AppColors.warningLight,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    book.status,
                                                    style: GoogleFonts.openSans(
                                                      color: isAvail ? AppColors.success : AppColors.warning,
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
                                                      icon: const Icon(Icons.history_rounded, size: 18, color: AppColors.textSecondary),
                                                      tooltip: 'Histórico de empréstimos do livro',
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) => BookLoanHistoryDialog(book: book),
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                                      tooltip: 'Editar exemplar e capa',
                                                      onPressed: () => _showEditBookDialog(context, ref, book),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                                      tooltip: 'Excluir exemplar',
                                                      onPressed: () => _showDeleteConfirmDialog(context, notifier, book),
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
                              _buildPaginationFooter(context, state, notifier),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(BuildContext context, InventoryState state, InventoryNotifier notifier) {
    final startItem = state.totalBooks == 0 ? 0 : state.page * state.limit + 1;
    final endItem = ((state.page + 1) * state.limit).clamp(0, state.totalBooks);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            state.totalBooks == 0
                ? 'Nenhum exemplar no acervo'
                : 'Exibindo $startItem a $endItem de ${state.totalBooks} exemplares (${state.limit} por página)',
            style: GoogleFonts.openSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page_rounded, size: 20),
                tooltip: 'Primeira página',
                onPressed: state.hasPreviousPage ? () => notifier.setPage(0) : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                tooltip: 'Página anterior',
                onPressed: state.hasPreviousPage ? () => notifier.previousPage() : null,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Página ${state.page + 1} de ${state.totalPages}',
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                tooltip: 'Próxima página',
                onPressed: state.hasNextPage ? () => notifier.nextPage() : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page_rounded, size: 20),
                tooltip: 'Última página',
                onPressed: state.hasNextPage ? () => notifier.setPage(state.totalPages - 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context, InventoryNotifier notifier, Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Exemplar'),
        content: Text('Deseja excluir "${book.titulo}" (${book.codigoExemplar})?'),
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
      notifier.deleteBook(book.id);
    }
  }

  Future<void> _showEditBookDialog(BuildContext context, WidgetRef ref, Book book) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _EditBookDialog(book: book),
    );
  }
}

class _EditBookDialog extends ConsumerStatefulWidget {
  final Book book;

  const _EditBookDialog({required this.book});

  @override
  ConsumerState<_EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends ConsumerState<_EditBookDialog> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _autorCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _anoCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _patrimonioCtrl;
  late final TextEditingController _coverUrlCtrl;
  late String _status;
  bool _isSearchingCoverOnline = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.book.titulo);
    _autorCtrl = TextEditingController(text: widget.book.autor ?? '');
    _areaCtrl = TextEditingController(text: widget.book.areaConhecimento ?? '');
    _anoCtrl = TextEditingController(text: widget.book.anoPublicacao ?? '');
    _isbnCtrl = TextEditingController(text: widget.book.isbn ?? '');
    _patrimonioCtrl = TextEditingController(text: widget.book.numeroPatrimonio ?? '');
    _coverUrlCtrl = TextEditingController(text: widget.book.coverUrl ?? '');
    _status = widget.book.status;

    _coverUrlCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _autorCtrl.dispose();
    _areaCtrl.dispose();
    _anoCtrl.dispose();
    _isbnCtrl.dispose();
    _patrimonioCtrl.dispose();
    _coverUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocalCoverImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      dialogTitle: 'Selecionar Imagem de Capa do Livro',
    );

    if (result.isNotEmpty && result.first.path != null) {
      final selectedPath = result.first.path!;
      setState(() {
        _coverUrlCtrl.text = selectedPath;
      });
    }
  }

  Future<void> _searchCoverOnline() async {
    final rawIsbn = _isbnCtrl.text.trim();
    if (rawIsbn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o campo ISBN para buscar a capa online.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSearchingCoverOnline = true);

    try {
      final dataSource = ref.read(openLibraryDataSourceProvider);
      final resolvedUrl = await dataSource.resolveCoverUrl(rawIsbn);

      if (mounted) {
        if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
          setState(() {
            _coverUrlCtrl.text = resolvedUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Capa encontrada online com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma capa encontrada online para este ISBN.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao consultar capa online: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingCoverOnline = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedBook = widget.book.copyWith(
      titulo: _tituloCtrl.text.trim(),
      autor: drift.Value(_autorCtrl.text.trim().isEmpty ? null : _autorCtrl.text.trim()),
      areaConhecimento: drift.Value(_areaCtrl.text.trim().isEmpty ? null : _areaCtrl.text.trim()),
      anoPublicacao: drift.Value(_anoCtrl.text.trim().isEmpty ? null : _anoCtrl.text.trim()),
      isbn: drift.Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
      numeroPatrimonio: drift.Value(_patrimonioCtrl.text.trim().isEmpty ? null : _patrimonioCtrl.text.trim()),
      status: _status,
      coverUrl: drift.Value(_coverUrlCtrl.text.trim().isEmpty ? null : _coverUrlCtrl.text.trim()),
    );

    final notifier = ref.read(inventoryNotifierProvider.notifier);
    await notifier.updateBook(updatedBook);

    if (mounted) {
      Navigator.of(context).pop();
      final hasIsbn = updatedBook.isbn != null && updatedBook.isbn!.isNotEmpty;
      final hasCover = updatedBook.coverUrl != null && updatedBook.coverUrl!.isNotEmpty;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasIsbn && hasCover
                ? 'Exemplar e capa salvos! A capa foi sincronizada para todos os exemplares com ISBN ${updatedBook.isbn}.'
                : 'Exemplar "${updatedBook.titulo}" atualizado com sucesso!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const statusOptions = ['Disponível', 'Emprestado', 'Em Manutenção', 'Perdido', 'Baixado'];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Editar Exemplar', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  'Código Exemplar: ${widget.book.codigoExemplar}',
                  style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 650,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info banner sobre vinculação de capa ao ISBN
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A capa é associada ao ISBN do livro. Ao salvar ou alterar a capa aqui, todos os exemplares cadastrados com este mesmo ISBN receberão a capa automaticamente.',
                          style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Seção de Capa e Pré-visualização
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCoverImage(
                      coverUrl: _coverUrlCtrl.text.trim().isEmpty ? null : _coverUrlCtrl.text.trim(),
                      title: _tituloCtrl.text.trim().isEmpty ? 'Sem título' : _tituloCtrl.text.trim(),
                      author: _autorCtrl.text.trim(),
                      width: 90,
                      height: 130,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capa do Livro',
                            style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _coverUrlCtrl,
                            decoration: InputDecoration(
                              labelText: 'URL da Imagem ou Caminho Local',
                              hintText: 'https://... ou /home/.../capa.jpg',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              suffixIcon: _coverUrlCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      tooltip: 'Remover capa',
                                      onPressed: () => _coverUrlCtrl.clear(),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickLocalCoverImage,
                                icon: const Icon(Icons.folder_open_rounded, size: 16),
                                label: const Text('Selecionar Imagem'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _isSearchingCoverOnline ? null : _searchCoverOnline,
                                icon: _isSearchingCoverOnline
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.cloud_download_rounded, size: 16),
                                label: const Text('Buscar Capa Online (ISBN)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                // Dados bibliográficos
                TextFormField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título da Obra',
                    hintText: 'Digite o título da obra (pode ser vazio para periódicos)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _autorCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Autor(es)',
                    hintText: 'Ex: SILVA, João; SANTOS, Maria',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _isbnCtrl,
                        decoration: const InputDecoration(
                          labelText: 'ISBN',
                          hintText: 'Ex: 9786525922607',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _anoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Ano',
                          hintText: 'Ex: 2023',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _areaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Área do Conhecimento',
                          hintText: 'Ex: Literatura Infantil',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _patrimonioCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nº do Patrimônio',
                          hintText: 'Ex: CE156004836',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: statusOptions.contains(_status) ? _status : 'Disponível',
                  decoration: const InputDecoration(
                    labelText: 'Status do Exemplar',
                    border: OutlineInputBorder(),
                  ),
                  items: statusOptions.map((s) {
                    return DropdownMenuItem<String>(
                      value: s,
                      child: Text(s, style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _status = val);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          child: const Text('Salvar Alterações'),
        ),
      ],
    );
  }
}
