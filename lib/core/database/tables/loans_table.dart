import 'package:drift/drift.dart';
import 'books_table.dart';
import 'students_table.dart';

@DataClassName('Loan')
class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get studentId => integer().references(Students, #id)();
  DateTimeColumn get dataEmprestimo => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dataDevolucaoPrevista => dateTime().nullable()();
  DateTimeColumn get dataDevolucaoEfetiva => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('Ativo'))(); // 'Ativo' | 'Devolvido'
  TextColumn get observacoes => text().nullable()();
}
