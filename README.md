# 📚 Biblioteca SESI-SP - Totem de Autoatendimento e Retaguarda

<p align="center">
  <img src="assets/images/sesi_logo_thermal.png" alt="SESI São Paulo" width="280"/>
</p>

<p align="center">
  <strong>Sistema integrado para Totem de Autoatendimento e Gestão da Biblioteca Escolar</strong><br>
  Desenvolvido em <strong>Flutter Desktop (Linux & Windows)</strong> com arquitetura limpa, banco de dados local SQLite (Drift) e integração com impressora térmica ESC/POS.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Desktop%20(Linux%20%7C%20Windows)-02569B?logo=flutter" alt="Flutter Desktop"/>
  <img src="https://img.shields.io/badge/Database-SQLite%20(Drift)-003B57?logo=sqlite" alt="SQLite Drift"/>
  <img src="https://img.shields.io/badge/State-Hooks%20Riverpod-blue" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/Tests-46%20Passing-success" alt="Tests"/>
  <img src="https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions" alt="GitHub Actions"/>
</p>

---

## 🎯 Visão Geral

A aplicação atende a duas frentes essenciais do cotidiano escolar do SESI:
1. **Modo Totem de Autoatendimento (Kiosk Mode)**: Interface touch e leitor de código de barras para que os estudantes realizem o autoempréstimo e a autodevolução de livros de forma rápida e autônoma, com emissão de comprovante impresso na hora.
2. **Área Administrativa (Retaguarda)**: Gestão de acervo, importação de planilhas de livros, importação de diários de classe de alunos em PDF, auditoria e consulta de históricos completos de empréstimos por exemplar e por estudante.

---

## ✨ Funcionalidades Principais

### 🖥️ Totem de Autoatendimento
- **Scanner Contínuo de Código de Barras**: O totem mantém foco ininterrupto na leitura óptica, sem necessidade de cliques em campos de texto.
  - Remove zeros à esquerda automaticamente para compatibilidade de códigos.
- **Resolução Inteligente de Capas de Livros**:
  - Consulta automática em cadeia: **Open Library** ➔ **Amazon Books** ➔ **Google Books**.
  - Download das capas para cache local em disco (`covers/`), garantindo carregamento instantâneo offline após o primeiro acesso.
  - Sincronização automática de capa por ISBN para todos os exemplares idênticos.
- **Autoempréstimo Inteligente**:
  - Limite padronizado de **até 4 livros simultâneos** por estudante.
  - Prazo de devolução automático de **30 dias**.
  - Bloqueio automático de novos empréstimos caso o estudante atinja o limite de 4 livros em aberto.
- **Autodevolução Instantânea**:
  - Basta escanear o exemplar para exibir o modal de devolução e disponibilizar o livro imediatamente para o próximo leitor.
- **Proteção por Inatividade**: Timeout de 40 segundos que limpa a tela automaticamente se o aluno se afastar.

### 🖨️ Impressora Térmica de Comprovantes (GPrinter GP-C80250I PLUS - 80mm)
- **Cabeçalho com Logotipo Oficial do SESI**: Rasterização monocromática em alta definição via comandos ESC/POS (`GS v 0`), com fallback textual caso a impressora opere em modo texto simples.
- **Comprovante de Autoempréstimo**:
  - Dados do estudante (Nome, RM/RA).
  - Dados do livro (Título, Código do exemplar, ISBN).
  - Data e hora exatas do empréstimo (`dd/MM/yyyy HH:mm`) e data limite de devolução (`30 dias`).
  - Total de livros ativos restantes com o aluno.
  - Comando de corte automático do papel (`GS V 66 0`).
- **Comprovante de Autodevolução**:
  - Exibe data e hora exatas em que o aluno retirou o livro e o momento exato da devolução.
  - Data estimada original com cálculo automático de pontualidade (`[OK] Devolvido no prazo` ou `[!] Devolvido com atraso`).
  - Quantidade de livros que ainda permanecem em posse do aluno.
- **Comunicação Multiplataforma**:
  - **Linux**: Gravação direta em `/dev/usb/lp0` ou fila CUPS `lp -o raw`.
  - **Windows**: Impressão direta no spooler do Windows (RAW) ou portas seriais `COM`.
  - **Rede**: Suporte nativo a impressão via socket TCP/IP (porta 9100).
  - **Modo Resiliente**: Caso a impressora esteja desligada ou sem papel, o totem não trava o atendimento.

### 📦 Gestão de Acervo e Inventário
- Tabela paginada com busca em tempo real por título, autor, patrimônio ou código.
- Edição completa de dados de exemplares e alteração manual de capa (upload local ou busca online).
- **Importação de Planilhas Excel (.xlsx)**:
  - Processamento em segundo plano via `Isolate.run` (não trava a interface).
  - Mapeamento flexível de colunas, sanitização de valores numéricos e extração automática de autores.
- **Histórico do Livro**: Diálogo auditável que relaciona todos os alunos que já pegaram o exemplar emprestado, com datas de retirada e devolução.

### 👥 Gestão de Estudantes
- Cadastro, edição e desativação de estudantes.
- **Importador de Diários de Classe em PDF**:
  - Lê relatórios do SISAE diretamente de arquivos `.pdf` (`syncfusion_flutter_pdf`).
  - Extrai automaticamente o Nome e o R.M. do aluno, normalizando pontos e eliminando dados desnecessários.
  - Gravação em lote com deduplicação de RMs repetidos.
- **Histórico do Estudante**: Diálogo que exibe todos os livros já emprestados pelo aluno, status e datas de entrega.

---

## 🏗️ Arquitetura do Software

O projeto segue os princípios da **Clean Architecture** orientada a funcionalidades:

```text
lib/
├── core/                         # Camada de infraestrutura e utilitários globais
│   ├── constants/                # Cores SESI, tipografia OpenSans, constantes de API
│   ├── database/                 # Tabelas Drift/SQLite e migrações (AppDatabase)
│   ├── providers/                # Providers globais (Riverpod)
│   ├── router/                   # Roteamento declarativo com GoRouter
│   ├── security/                 # Hashing de senhas com SHA-256 e salt dinâmico
│   ├── services/                 # Impressão térmica (ESC/POS) e armazenamento local de capas
│   └── utils/                    # Listeners de scanner de código de barras e timeout
├── features/
│   ├── auth/                     # Autenticação de administradores da biblioteca
│   ├── kiosk/                    # Modo Totem: scanner, empréstimo, devolução e capas
│   ├── inventory/                # Catálogo de livros, edição e importação Excel
│   └── students/                 # Gestão de alunos, importação PDF/Excel e históricos
└── main.dart                     # Inicialização de dependências, SQLite e janela do app
```

### Principais Bibliotecas Utilizadas
| Pacote | Função |
| :--- | :--- |
| `hooks_riverpod` & `riverpod_annotation` | Gerenciamento de estado reativo com geração de código (`.g.dart`) |
| `drift` & `sqlite3_flutter_libs` | Banco de dados relacional SQLite de alto desempenho |
| `esc_pos_utils_plus` & `image` | Geração de bytes ESC/POS e rasterização monocromática do logotipo |
| `syncfusion_flutter_pdf` | Extração de texto e diários de classe em arquivos PDF |
| `flutter_excel` | Leitura e parsing de planilhas `.xlsx` em Isolates |
| `go_router` | Navegação declarativa com proteção de rotas |
| `window_manager` | Controle da janela em tela cheia (modo Kiosk desktop) |

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- **Flutter SDK**: versão 3.24 ou superior
- **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`
- **Windows**: Visual Studio com carga de trabalho "Desenvolvimento para desktop com C++"

### 1. Clonar e Instalar Dependências
```bash
git clone <url-do-repositorio>
cd biblioteca
flutter pub get
```

### 2. Gerar Código (Drift e Riverpod)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Executar em Modo de Desenvolvimento
- **No Linux**:
  ```bash
  flutter run -d linux
  ```
- **No Windows**:
  ```bash
  flutter run -d windows
  ```

### 4. Rodar Testes Automatizados
```bash
flutter test
```

---

## 🖨️ Configuração da Impressora Térmica

### No Linux
Para que a aplicação tenha permissão de gravar diretamente na porta USB sem necessidade de `sudo`:
```bash
# Adicione seu usuário ao grupo de impressoras 'lp'
sudo usermod -a -G lp $USER

# Ou conceda permissão de leitura/escrita na porta:
sudo chmod 666 /dev/usb/lp0
```

### No Windows
A impressora pode ser conectada via cabo USB ou instalada no Painel de Controle:
- Se instalada como impressora padrão com o driver da GPrinter (ou Generic Text/Only), a aplicação enviará comandos RAW diretamente para a fila de impressão.
- Pode também ser direcionada para portas seriais virtuais (ex: `COM3`).

---

## 📦 Compilação e Criação de Instalador Windows

### 1. Compilação Local com Inno Setup
1. Gere o executável de Release do Flutter:
   ```powershell
   flutter build windows --release
   ```
2. Abra o script [`windows/installer/installer.iss`](windows/installer/installer.iss) no **Inno Setup Compiler** e clique em **Compile** (ou use a linha de comando):
   ```powershell
   & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" windows\installer\installer.iss
   ```
3. O instalador final será gerado em:  
   `build/installer/BibliotecaSESI-Setup.exe`

### 2. Compilação Automática via GitHub Actions
O projeto possui um workflow configurado em [`.github/workflows/build-windows.yml`](.github/workflows/build-windows.yml) que compila automaticamente o instalador do Windows:
- **Disparo**: Ao realizar `push` na branch `main`, abrir `pull request` ou manualmente via **"Run workflow"** na aba Actions do GitHub.
- **Artefato**: O arquivo `BibliotecaSESI-Setup.exe` fica disponível para download na execução da Action.
- **Release Automática**: Ao criar e enviar uma tag de versão (ex: `git tag v1.0.0 && git push --tags`), a Action cria automaticamente uma Release no GitHub com o instalador anexado.

---

## 🔐 Acesso Administrativo Inicial

A aplicação já inicializa o banco com o primeiro usuário administrador pré-cadastrado:
- **E-mail**: `silvia.francisca@sesisp.org.br`
- **Senha Inicial**: `SenhaForte123`

*(A senha e os dados do perfil podem ser alterados a qualquer momento na área administrativa).*

---

## 📄 Licença

Uso restrito e institucional para a rede escolar **SESI São Paulo**.
