import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/core_providers.dart';
import '../data/datasources/pdf_students_parser.dart';
import '../domain/repositories/student_repository.dart';

part 'student_list_notifier.g.dart';

class StudentListState {
  final List<Student> students;
  final int totalStudents;
  final String searchQuery;
  final int page;
  final int limit;
  final bool isLoading;
  final bool isImporting;
  final int? lastImportedCount;
  final String? errorMessage;

  const StudentListState({
    this.students = const [],
    this.totalStudents = 0,
    this.searchQuery = '',
    this.page = 0,
    this.limit = 50,
    this.isLoading = false,
    this.isImporting = false,
    this.lastImportedCount,
    this.errorMessage,
  });

  StudentListState copyWith({
    List<Student>? students,
    int? totalStudents,
    String? searchQuery,
    int? page,
    int? limit,
    bool? isLoading,
    bool? isImporting,
    int? lastImportedCount,
    String? errorMessage,
  }) {
    return StudentListState(
      students: students ?? this.students,
      totalStudents: totalStudents ?? this.totalStudents,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      isLoading: isLoading ?? this.isLoading,
      isImporting: isImporting ?? this.isImporting,
      lastImportedCount: lastImportedCount ?? this.lastImportedCount,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class StudentListNotifier extends _$StudentListNotifier {
  StudentRepository get _repository => ref.read(studentRepositoryProvider);

  @override
  StudentListState build() {
    Future.microtask(() => refresh());
    return const StudentListState();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final total = await _repository.getTotalStudentsCount(search: state.searchQuery);
      final students = await _repository.getStudents(
        search: state.searchQuery,
        limit: state.limit,
        offset: state.page * state.limit,
      );

      state = state.copyWith(
        isLoading: false,
        totalStudents: total,
        students: students,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar lista de alunos: $e',
      );
    }
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query, page: 0);
    refresh();
  }

  void onPageChanged(int page) {
    state = state.copyWith(page: page);
    refresh();
  }

  Future<bool> createStudent(StudentsCompanion student) async {
    try {
      await _repository.createStudent(student);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao criar aluno: $e');
      return false;
    }
  }

  Future<bool> updateStudent(Student student) async {
    try {
      await _repository.updateStudent(student);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao atualizar aluno: $e');
      return false;
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await _repository.deleteStudent(id);
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao excluir aluno: $e');
    }
  }

  Future<int?> importFromExcel(String filePath) async {
    state = state.copyWith(isImporting: true, errorMessage: null);

    try {
      final count = await _repository.importStudentsFromExcel(filePath);
      state = state.copyWith(
        isImporting: false,
        lastImportedCount: count,
      );
      await refresh();
      return count;
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        errorMessage: 'Erro ao importar alunos do Excel: $e',
      );
      return null;
    }
  }

  Future<StudentPdfImportResult?> importFromPdf(String filePath) async {
    state = state.copyWith(isImporting: true, errorMessage: null);

    try {
      final result = await _repository.importStudentsFromPdf(filePath);
      state = state.copyWith(
        isImporting: false,
        lastImportedCount: result.inserted,
      );
      await refresh();
      return result;
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        errorMessage: 'Erro ao importar alunos do PDF: $e',
      );
      return null;
    }
  }
}

// Alias for convenience and backward compatibility
final studentListNotifierProvider = studentListProvider;
