import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biblioteca/core/database/app_database.dart';
import 'package:biblioteca/features/kiosk/presentation/widgets/book_info_card.dart';

void main() {
  group('BookInfoCard Widget', () {
    testWidgets('renders book information and available badge correctly', (tester) async {
      final dummyBook = Book(
        id: 1,
        codigoExemplar: 'EXEMP-001',
        titulo: 'Memórias Póstumas de Brás Cubas',
        autor: 'Machado de Assis',
        areaConhecimento: 'Literatura',
        anoPublicacao: '1881',
        isbn: '9788535910667',
        status: 'Disponível',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool checkoutClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BookInfoCard(
                book: dummyBook,
                coverUrl: null,
                isLoading: false,
                onCheckoutPressed: () {
                  checkoutClicked = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Memórias Póstumas de Brás Cubas'), findsAtLeastNWidgets(1));
      expect(find.text('Machado de Assis'), findsAtLeastNWidgets(1));
      expect(find.text('Exemplar Disponível'), findsOneWidget);
      expect(find.text('Emprestar Livro'), findsOneWidget);

      await tester.tap(find.text('Emprestar Livro'));
      await tester.pump();

      expect(checkoutClicked, isTrue);
    });

    testWidgets('does not show Emprestar button when book is Emprestado', (tester) async {
      final dummyBook = Book(
        id: 2,
        codigoExemplar: 'EXEMP-002',
        titulo: 'O Cortiço',
        autor: 'Aluísio Azevedo',
        areaConhecimento: 'Literatura Naturalista',
        anoPublicacao: '1890',
        isbn: null,
        status: 'Emprestado',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BookInfoCard(
                book: dummyBook,
                coverUrl: null,
                isLoading: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Exemplar Emprestado'), findsOneWidget);
      expect(find.text('Emprestar Livro'), findsNothing);
    });
  });
}
