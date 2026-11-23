import 'package:drift/drift.dart';

@DataClassName('Book')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get codigoExemplar => text().unique()(); // Código de barras do exemplar
  TextColumn get nomeLocalExemplar => text().nullable()();
  TextColumn get numeroPatrimonio => text().nullable()();
  TextColumn get titulo => text()();
  TextColumn get tituloRevista => text().nullable()();
  TextColumn get classificacao => text().nullable()();
  TextColumn get codigoTipoObra => text().nullable()();
  TextColumn get nomeTipoObra => text().nullable()();
  TextColumn get exemplarVolume => text().nullable()();
  TextColumn get autor => text().nullable()(); // Campo "Ordenar"
  TextColumn get areaConhecimento => text().nullable()(); // "Nome Área conhecimento"
  TextColumn get anoPublicacao => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get referencia => text().nullable()();
  TextColumn get coverUrl => text().nullable()(); // URL da capa salva (OpenLibrary, Google Books ou local)
  TextColumn get status => text().withDefault(const Constant('Disponível'))(); // 'Disponível' | 'Emprestado'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
