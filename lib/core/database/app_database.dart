import 'package:drift/drift.dart';
import '../security/password_hasher.dart';
import 'connection/native.dart' as impl;
import 'tables/admin_users_table.dart';
import 'tables/books_table.dart';
import 'tables/loans_table.dart';
import 'tables/students_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [AdminUsers, Books, Students, Loans])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(books, books.coverUrl);
        }
        if (from < 3) {
          try {
            await customStatement('ALTER TABLE students DROP COLUMN cpf;');
          } catch (_) {
            // Se a versão do SQLite não suportar drop column direto, a coluna não atrapalha
          }
        }
        if (from < 4) {
          try {
            await customStatement("ALTER TABLE students ADD COLUMN segmento TEXT NOT NULL DEFAULT 'fundamental1';");
          } catch (_) {}
        }
      },
      beforeOpen: (details) async {
        // Enforce foreign key constraints
        await customStatement('PRAGMA foreign_keys = ON');

        // Ensure cover_url column exists if db was created at version 1
        try {
          await customStatement('ALTER TABLE books ADD COLUMN cover_url TEXT;');
        } catch (_) {
          // Column already exists
        }

        // Drop cpf column if it still exists from version 2
        try {
          await customStatement('ALTER TABLE students DROP COLUMN cpf;');
        } catch (_) {
          // Column already dropped or not supported
        }

        // Ensure segmento column exists if db was created at earlier version
        try {
          await customStatement("ALTER TABLE students ADD COLUMN segmento TEXT NOT NULL DEFAULT 'fundamental1';");
        } catch (_) {
          // Column already exists
        }

        // Check if initial admin exists, if not seed it
        final adminExists = await (select(adminUsers)..where((tbl) => tbl.email.equals('silvia.francisca@sesisp.org.br'))).getSingleOrNull();
        if (adminExists == null) {
          final hashResult = PasswordHasher.createHash('SenhaForte123');
          await into(adminUsers).insert(
            AdminUsersCompanion.insert(
              name: 'Silvia Francisca Lima Goncalves',
              email: 'silvia.francisca@sesisp.org.br',
              passwordHash: hashResult.hash,
              salt: hashResult.salt,
            ),
          );
        }
      },
    );
  }
}
