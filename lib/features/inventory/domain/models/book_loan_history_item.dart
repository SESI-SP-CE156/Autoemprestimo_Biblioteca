class BookLoanHistoryItem {
  final int loanId;
  final String studentName;
  final String studentRmRa;
  final DateTime dataEmprestimo;
  final DateTime? dataDevolucaoPrevista;
  final DateTime? dataDevolucaoEfetiva;
  final String status; // 'Ativo' | 'Devolvido'

  const BookLoanHistoryItem({
    required this.loanId,
    required this.studentName,
    required this.studentRmRa,
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
