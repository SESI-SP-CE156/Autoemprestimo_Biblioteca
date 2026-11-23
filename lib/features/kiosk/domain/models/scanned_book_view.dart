import '../../../../core/database/app_database.dart';

class ScannedBookView {
  final Book book;
  final String? coverUrl;
  final Loan? activeLoan;
  final Student? activeBorrower;

  const ScannedBookView({
    required this.book,
    this.coverUrl,
    this.activeLoan,
    this.activeBorrower,
  });

  bool get isAvailable => book.status == 'Disponível';
  bool get isBorrowed => book.status == 'Emprestado';

  ScannedBookView copyWith({
    Book? book,
    String? coverUrl,
    Loan? activeLoan,
    Student? activeBorrower,
  }) {
    return ScannedBookView(
      book: book ?? this.book,
      coverUrl: coverUrl ?? this.coverUrl,
      activeLoan: activeLoan ?? this.activeLoan,
      activeBorrower: activeBorrower ?? this.activeBorrower,
    );
  }
}
