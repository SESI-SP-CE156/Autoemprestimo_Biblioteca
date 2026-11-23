/// Constantes e chaves de APIs externas do sistema.
class ApiConstants {
  /// Chave de API da Google Books (Google Cloud Console).
  ///
  /// Como obter e cadastrar sua chave:
  /// 1. Acesse o Google Cloud Console: https://console.cloud.google.com/
  /// 2. Crie um projeto ou selecione um projeto existente.
  /// 3. No menu lateral, acesse "APIs e serviços" > "Biblioteca".
  /// 4. Pesquise por "Books API" (ou Google Books API) e clique em "Ativar".
  /// 5. Em seguida, vá para "APIs e serviços" > "Credenciais".
  /// 6. Clique em "+ Criar credenciais" > "Chave de API".
  /// 7. Copie a chave gerada e cole no campo [googleBooksApiKey] abaixo ou
  ///    passe ao compilar/executar com:
  ///    `flutter run --dart-define=GOOGLE_BOOKS_API_KEY=sua_chave_aqui`
  static const String googleBooksApiKey = String.fromEnvironment(
    'AIzaSyDqHRwVcPoB5XcanTodLRGrJWVuXg9_eHE',
    defaultValue: '', // Cole sua chave do Google aqui se preferir não usar --dart-define
  );
}
