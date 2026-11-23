class BookImportResult {
  final int totalRows;
  final int inserted;
  final int updated;
  final int errors;
  final List<String> errorMessages;

  const BookImportResult({
    required this.totalRows,
    required this.inserted,
    required this.updated,
    required this.errors,
    required this.errorMessages,
  });
}
