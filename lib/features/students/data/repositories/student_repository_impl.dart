import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/student_loan_history_item.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/excel_students_parser.dart';
import '../datasources/pdf_students_parser.dart';

class StudentRepositoryImpl implements StudentRepository {
  final AppDatabase db;

  StudentRepositoryImpl({required this.db});

  SimpleSelectStatement<$StudentsTable, Student> _buildQuery({String? search}) {
    final query = db.select(db.students);
    if (search != null && search.trim().isNotEmpty) {
      final pattern = '%${search.trim().toLowerCase()}%';
      query.where((tbl) =>
          tbl.nome.lower().like(pattern) |
          tbl.rmRa.lower().like(pattern));
    }
    return query;
  }

  @override
  Stream<List<Student>> watchStudents({String? search, int limit = 50, int offset = 0}) {
    final query = _buildQuery(search: search);
    query
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.nome)])
      ..limit(limit, offset: offset);
    return query.watch();
  }

  @override
  Future<List<Student>> getStudents({String? search, int limit = 50, int offset = 0}) {
    final query = _buildQuery(search: search);
    query
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.nome)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  @override
  Future<int> getTotalStudentsCount({String? search}) async {
    final countExp = db.students.id.count();
    final query = db.selectOnly(db.students)..addColumns([countExp]);
    if (search != null && search.trim().isNotEmpty) {
      final pattern = '%${search.trim().toLowerCase()}%';
      query.where(
        db.students.nome.lower().like(pattern) |
        db.students.rmRa.lower().like(pattern),
      );
    }
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  @override
  Future<void> createStudent(StudentsCompanion student) {
    return db.into(db.students).insert(student);
  }

  @override
  Future<void> updateStudent(Student student) {
    return db.update(db.students).replace(student);
  }

  @override
  Future<void> deleteStudent(int id) {
    return (db.delete(db.students)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<int> importStudentsFromExcel(String filePath) {
    return ExcelStudentsParser.parseAndImport(filePath: filePath, db: db);
  }

  @override
  Future<StudentPdfImportResult> importStudentsFromPdf(String filePath) {
    return PdfStudentsParser.parseAndImport(filePath: filePath, db: db);
  }

  @override
  Future<List<StudentLoanHistoryItem>> getStudentLoanHistory(int studentId) async {
    final query = db.select(db.loans).join([
      innerJoin(db.books, db.books.id.equalsExp(db.loans.bookId)),
    ])
      ..where(db.loans.studentId.equals(studentId))
      ..orderBy([OrderingTerm.desc(db.loans.dataEmprestimo)]);

    final rows = await query.get();
    return rows.map((r) {
      final loan = r.readTable(db.loans);
      final book = r.readTable(db.books);
      return StudentLoanHistoryItem(
        loanId: loan.id,
        bookTitle: book.titulo,
        bookBarcode: book.codigoExemplar,
        bookIsbn: book.isbn,
        dataEmprestimo: loan.dataEmprestimo,
        dataDevolucaoPrevista: loan.dataDevolucaoPrevista,
        dataDevolucaoEfetiva: loan.dataDevolucaoEfetiva,
        status: loan.status,
      );
    }).toList();
  }
}
