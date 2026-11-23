import 'package:drift/drift.dart';

@DataClassName('Student')
class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rmRa => text().unique()(); // Código de barras da carteirinha (RM/RA)
  TextColumn get nome => text()();
  TextColumn get segmento => text().withDefault(const Constant('fundamental1'))();
  TextColumn get fotoPath => text().nullable()();
  BoolColumn get ativo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
