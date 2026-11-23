import '../../../../core/database/app_database.dart';
import '../../data/datasources/pdf_students_parser.dart';
import '../models/student_loan_history_item.dart';

abstract class StudentRepository {
  Stream<List<Student>> watchStudents({String? search, int limit = 50, int offset = 0});
  Future<List<Student>> getStudents({String? search, int limit = 50, int offset = 0});
  Future<int> getTotalStudentsCount({String? search});
  Future<void> createStudent(StudentsCompanion student);
  Future<void> updateStudent(Student student);
  Future<void> deleteStudent(int id);
  Future<int> importStudentsFromExcel(String filePath);
  Future<StudentPdfImportResult> importStudentsFromPdf(String filePath);
  Future<List<StudentLoanHistoryItem>> getStudentLoanHistory(int studentId);
}
