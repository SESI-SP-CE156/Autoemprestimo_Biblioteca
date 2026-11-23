class StudentLoanHistoryItem {
  final int loanId;
  final String bookTitle;
  final String bookBarcode;
  final String? bookIsbn;
  final DateTime dataEmprestimo;
  final DateTime? dataDevolucaoPrevista;
  final DateTime? dataDevolucaoEfetiva;
  final String status; // 'Ativo' | 'Devolvido'

  const StudentLoanHistoryItem({
    required this.loanId,
    required this.bookTitle,
    required this.bookBarcode,
    this.bookIsbn,
    required this.dataEmprestimo,
    this.dataDevolucaoPrevista,
    this.dataDevolucaoEfetiva,
    required this.status,
  });

  bool get isAtivo => status == 'Ativo';
  bool get isDevolvido => status == 'Devolvido';
  bool get isAtrasado =>
      isAtivo &&
      dataDevolucaoPrevista != null &&
      DateTime.now().isAfter(dataDevolucaoPrevista!);
}
