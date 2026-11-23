enum StudentSegment {
  padrao(
    code: 'padrao',
    label: 'Estudante',
    description: 'Regra Geral',
    maxLoans: 4,
    loanPeriodDays: 30,
  ),
  fundamental1(
    code: 'fundamental1',
    label: 'Ensino Fundamental 1',
    description: '1º ao 5º ano',
    maxLoans: 4,
    loanPeriodDays: 30,
  ),
  fundamental2(
    code: 'fundamental2',
    label: 'Ensino Fundamental 2',
    description: '6º ao 9º ano',
    maxLoans: 4,
    loanPeriodDays: 30,
  ),
  medio(
    code: 'medio',
    label: 'Ensino Médio',
    description: '1ª à 3ª série',
    maxLoans: 4,
    loanPeriodDays: 30,
  );

  final String code;
  final String label;
  final String description;
  final int maxLoans;
  final int loanPeriodDays;

  const StudentSegment({
    required this.code,
    required this.label,
    required this.description,
    required this.maxLoans,
    required this.loanPeriodDays,
  });

  static StudentSegment fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return StudentSegment.fundamental1;
    final normalized = code.toLowerCase().trim();

    return StudentSegment.values.firstWhere(
      (s) => s.code == normalized,
      orElse: () {
        if (normalized.contains('fundamental 1') ||
            normalized.contains('fund 1') ||
            normalized.contains('ef1') ||
            normalized.contains('1º ano') ||
            normalized.contains('2º ano') ||
            normalized.contains('3º ano') ||
            normalized.contains('4º ano') ||
            normalized.contains('5º ano')) {
          return StudentSegment.fundamental1;
        }
        if (normalized.contains('fundamental 2') ||
            normalized.contains('fund 2') ||
            normalized.contains('fundamental ii') ||
            normalized.contains('fund ii') ||
            normalized.contains('ef2') ||
            normalized.contains('6º ano') ||
            normalized.contains('7º ano') ||
            normalized.contains('8º ano') ||
            normalized.contains('9º ano')) {
          return StudentSegment.fundamental2;
        }
        if (normalized.contains('médio') ||
            normalized.contains('medio') ||
            normalized.contains('em') ||
            normalized.contains('1ª serie') ||
            normalized.contains('2ª serie') ||
            normalized.contains('3ª serie') ||
            normalized.contains('1ª série') ||
            normalized.contains('2ª série') ||
            normalized.contains('3ª série')) {
          return StudentSegment.medio;
        }
        return StudentSegment.fundamental1;
      },
    );
  }
}
