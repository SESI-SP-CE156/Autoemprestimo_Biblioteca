/// Constantes e chaves de APIs externas do sistema.
class ApiConstants {
  /// Chave de API da Google Books (Google Cloud Console).
  ///
  /// Para segurança, a chave NUNCA deve ser commitada no código-fonte.
  /// Ela é injetada em tempo de compilação ou execução via:
  ///
  /// Local:
  /// `flutter run --dart-define=GOOGLE_BOOKS_API_KEY=sua_chave`
  /// ou com arquivo não versionado:
  /// `flutter run --dart-define-from-file=secrets.json`
  ///
  /// No GitHub Actions (CI/CD):
  /// Injetada via GitHub Secrets: ${{ secrets.GOOGLE_BOOKS_API_KEY }}
  static const String googleBooksApiKey = String.fromEnvironment(
    'GOOGLE_BOOKS_API_KEY',
    defaultValue: '',
  );
}
