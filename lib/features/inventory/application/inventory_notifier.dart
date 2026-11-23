import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/models/book_import_result.dart';
import '../domain/repositories/inventory_repository.dart';

part 'inventory_notifier.g.dart';

class InventoryState {
  final List<Book> books;
  final int totalBooks;
  final String searchQuery;
  final int page;
  final int limit;
  final String? sortBy;
  final bool sortAscending;
  final bool isLoading;
  final bool isImporting;
  final BookImportResult? lastImportResult;
  final String? errorMessage;

  const InventoryState({
    this.books = const [],
    this.totalBooks = 0,
    this.searchQuery = '',
    this.page = 0,
    this.limit = 20,
    this.sortBy = 'codigoExemplar',
    this.sortAscending = true,
    this.isLoading = false,
    this.isImporting = false,
    this.lastImportResult,
    this.errorMessage,
  });

  int get totalPages => (totalBooks / limit).ceil() == 0 ? 1 : (totalBooks / limit).ceil();
  bool get hasPreviousPage => page > 0;
  bool get hasNextPage => page < totalPages - 1;

  InventoryState copyWith({
    List<Book>? books,
    int? totalBooks,
    String? searchQuery,
    int? page,
    int? limit,
    String? sortBy,
    bool? sortAscending,
    bool? isLoading,
    bool? isImporting,
    BookImportResult? lastImportResult,
    String? errorMessage,
  }) {
    return InventoryState(
      books: books ?? this.books,
      totalBooks: totalBooks ?? this.totalBooks,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      isLoading: isLoading ?? this.isLoading,
      isImporting: isImporting ?? this.isImporting,
      lastImportResult: lastImportResult ?? this.lastImportResult,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  InventoryRepository get _repository => ref.read(inventoryRepositoryProvider);

  @override
  InventoryState build() {
    Future.microtask(() => refresh());
    return const InventoryState();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final total = await _repository.getTotalBooksCount(search: state.searchQuery);
      final books = await _repository.getBooks(
        search: state.searchQuery,
        limit: state.limit,
        offset: state.page * state.limit,
        sortBy: state.sortBy,
        ascending: state.sortAscending,
      );

      state = state.copyWith(
        isLoading: false,
        totalBooks: total,
        books: books,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar acervo: $e',
      );
    }
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query, page: 0);
    refresh();
  }

  void setSorting(String column) {
    if (state.sortBy == column) {
      state = state.copyWith(sortAscending: !state.sortAscending, page: 0);
    } else {
      state = state.copyWith(sortBy: column, sortAscending: true, page: 0);
    }
    refresh();
  }

  void setPage(int newPage) {
    if (newPage < 0 || newPage >= state.totalPages) return;
    state = state.copyWith(page: newPage);
    refresh();
  }

  void nextPage() {
    if (state.hasNextPage) {
      setPage(state.page + 1);
    }
  }

  void previousPage() {
    if (state.hasPreviousPage) {
      setPage(state.page - 1);
    }
  }

  void onPageChanged(int page) {
    setPage(page);
  }

  Future<void> updateBook(Book book) async {
    try {
      await _repository.updateBook(book);
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao atualizar exemplar: $e');
    }
  }

  Future<BookImportResult?> importFromExcel(String filePath) async {
    state = state.copyWith(isImporting: true, errorMessage: null);

    try {
      final result = await _repository.importBooksFromExcel(filePath);
      state = state.copyWith(
        isImporting: false,
        lastImportResult: result,
      );
      await refresh();
      return result;
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        errorMessage: 'Falha na importação do Excel: $e',
      );
      return null;
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      await _repository.deleteBook(id);
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao excluir exemplar: $e');
    }
  }
}

// Alias for convenience and backward compatibility
final inventoryNotifierProvider = inventoryProvider;
