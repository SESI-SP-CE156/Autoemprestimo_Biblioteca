import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import '../../features/students/domain/models/student_segment.dart';

class LoanReceipt {
  final String alunoNome;
  final String alunoRmRa;
  final String livroTitulo;
  final String livroCodigoExemplar;
  final String? livroIsbn;
  final DateTime dataEmprestimo;
  final DateTime dataDevolucaoPrevista;
  final int activeLoansCount;
  final int maxAllowedLoans;
  final StudentSegment? segmento;

  const LoanReceipt({
    required this.alunoNome,
    required this.alunoRmRa,
    required this.livroTitulo,
    required this.livroCodigoExemplar,
    this.livroIsbn,
    required this.dataEmprestimo,
    required this.dataDevolucaoPrevista,
    required this.activeLoansCount,
    this.maxAllowedLoans = 4,
    this.segmento,
  });
}

class ReturnReceipt {
  final String alunoNome;
  final String alunoRmRa;
  final String livroTitulo;
  final String livroCodigoExemplar;
  final String? livroIsbn;
  final DateTime dataEmprestimo;
  final DateTime dataDevolucaoEfetiva;
  final DateTime dataDevolucaoPrevista;
  final int activeLoansRemaining;
  final int maxAllowedLoans;
  final StudentSegment? segmento;

  const ReturnReceipt({
    required this.alunoNome,
    required this.alunoRmRa,
    required this.livroTitulo,
    required this.livroCodigoExemplar,
    this.livroIsbn,
    required this.dataEmprestimo,
    required this.dataDevolucaoEfetiva,
    required this.dataDevolucaoPrevista,
    required this.activeLoansRemaining,
    this.maxAllowedLoans = 4,
    this.segmento,
  });
}

class ReceiptPrintResult {
  final bool success;
  final String message;

  const ReceiptPrintResult({required this.success, required this.message});
}

/// Sanitizes text by removing diacritics to ensure clean printing on ESC/POS thermal printers
String _removeDiacritics(String text) {
  var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
  var withoutDia = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';

  var result = text;
  for (int i = 0; i < withDia.length; i++) {
    result = result.replaceAll(withDia[i], withoutDia[i]);
  }
  return result;
}

class ThermalPrinterService {
  /// Appends standard SESI institutional header (Logo or text fallback)
  static Future<void> _appendHeader(
    List<int> bytes,
    Generator generator, {
    img.Image? logoImage,
    bool includeLogo = true,
  }) async {
    var printedLogo = false;
    if (includeLogo) {
      img.Image? resolvedImage = logoImage;
      if (resolvedImage == null) {
        try {
          final byteData = await rootBundle.load('assets/images/sesi_logo_thermal.png');
          final rawBytes = byteData.buffer.asUint8List();
          resolvedImage = img.decodeImage(rawBytes);
        } catch (e) {
          debugPrint('[ThermalPrinterService] Logo asset not loaded or headless environment: $e');
        }
      }

      if (resolvedImage != null) {
        // esc_pos_utils_plus requires image width to be a multiple of 8 to avoid fixed-length list exception
        if (resolvedImage.width % 8 != 0) {
          final adjustedWidth = (resolvedImage.width ~/ 8) * 8;
          if (adjustedWidth > 0) {
            resolvedImage = img.copyResize(resolvedImage, width: adjustedWidth);
          }
        }
        bytes.addAll(generator.imageRaster(resolvedImage, align: PosAlign.center));
        bytes.addAll(generator.emptyLines(1));
        printedLogo = true;
      }
    }

    if (!printedLogo) {
      bytes.addAll(generator.text(
        _removeDiacritics('SESI SAO PAULO'),
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      ));
    }
    bytes.addAll(generator.text(
      _removeDiacritics('CENTRO EDUCACIONAL SESI 156'),
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    bytes.addAll(generator.text(
      _removeDiacritics('BIBLIOTECA ESCOLAR PAULO R. MERLIN'),
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(generator.hr());
  }

  /// Generates the raw ESC/POS byte sequence for an 80mm thermal loan receipt
  static Future<List<int>> generateReceiptBytes(
    LoanReceipt receipt, {
    img.Image? logoImage,
    bool includeLogo = true,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final List<int> bytes = [];

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateOnlyFormat = DateFormat('dd/MM/yyyy');
    final diasPrazo = receipt.dataDevolucaoPrevista.difference(receipt.dataEmprestimo).inDays;

    // Reset printer
    bytes.addAll(generator.reset());

    // --- Header ---
    await _appendHeader(bytes, generator, logoImage: logoImage, includeLogo: includeLogo);

    // --- Title ---
    bytes.addAll(generator.text(
      _removeDiacritics('COMPROVANTE DE EMPRESTIMO DE LIVRO'),
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    bytes.addAll(generator.text(
      'Emissao: ${dateFormat.format(receipt.dataEmprestimo)}',
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(generator.hr());

    // --- Student Details ---
    bytes.addAll(generator.text(
      'DADOS DO ESTUDANTE:',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text('Aluno: ${_removeDiacritics(receipt.alunoNome)}'));
    bytes.addAll(generator.text('RM/RA: ${receipt.alunoRmRa}'));
    bytes.addAll(generator.hr());

    // --- Book Details ---
    bytes.addAll(generator.text(
      'DADOS DO LIVRO:',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text(
      'Titulo: ${_removeDiacritics(receipt.livroTitulo)}',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text('Exemplar: ${receipt.livroCodigoExemplar}'));
    if (receipt.livroIsbn != null && receipt.livroIsbn!.trim().isNotEmpty) {
      bytes.addAll(generator.text('ISBN: ${receipt.livroIsbn!.trim()}'));
    }
    bytes.addAll(generator.hr());

    // --- Loan & Due Date ---
    bytes.addAll(generator.text(
      'PRAZO DE DEVOLUCAO:',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text(
      'Data Emprestimo: ${dateFormat.format(receipt.dataEmprestimo)}',
    ));
    bytes.addAll(generator.text(
      'DEVOLVER ATE: ${dateOnlyFormat.format(receipt.dataDevolucaoPrevista)} ($diasPrazo DIAS)',
      styles: const PosStyles(
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    ));
    bytes.addAll(generator.hr());

    // --- Summary & Notice ---
    bytes.addAll(generator.text(
      'Emprestimos Ativos: ${receipt.activeLoansCount} de ${receipt.maxAllowedLoans} livro(s)',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.feed(1));
    bytes.addAll(generator.text(
      _removeDiacritics('Cuide bem deste livro! Em caso de extravio ou dano, procure a equipe da biblioteca.'),
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(generator.feed(2));

    // Cut paper (Partial cut with feed)
    bytes.addAll(generator.cut());

    return bytes;
  }

  /// Generates the raw ESC/POS byte sequence for an 80mm thermal return receipt
  static Future<List<int>> generateReturnReceiptBytes(
    ReturnReceipt receipt, {
    img.Image? logoImage,
    bool includeLogo = true,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final List<int> bytes = [];

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateOnlyFormat = DateFormat('dd/MM/yyyy');

    // Reset printer
    bytes.addAll(generator.reset());

    // --- Header ---
    await _appendHeader(bytes, generator, logoImage: logoImage, includeLogo: includeLogo);

    // --- Title ---
    bytes.addAll(generator.text(
      _removeDiacritics('COMPROVANTE DE DEVOLUCAO DE LIVRO'),
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    bytes.addAll(generator.text(
      'Emissao: ${dateFormat.format(receipt.dataDevolucaoEfetiva)}',
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(generator.hr());

    // --- Student Details ---
    bytes.addAll(generator.text(
      'DADOS DO ESTUDANTE:',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text(
      _removeDiacritics('Nome:     ${receipt.alunoNome}'),
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text(
      'RM/RA:    ${receipt.alunoRmRa}',
    ));
    bytes.addAll(generator.hr());

    // --- Book Details ---
    bytes.addAll(generator.text(
      'DADOS DO LIVRO DEVOLVIDO:',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text(
      _removeDiacritics('Titulo:   ${receipt.livroTitulo}'),
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text(
      'Exemplar: ${receipt.livroCodigoExemplar}',
    ));
    if (receipt.livroIsbn != null && receipt.livroIsbn!.trim().isNotEmpty) {
      bytes.addAll(generator.text(
        'ISBN:     ${receipt.livroIsbn!.trim()}',
      ));
    }
    bytes.addAll(generator.hr());

    // --- Return Period & Dates ---
    bytes.addAll(generator.text(
      'PRAZO DE DEVOLUCAO:',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text(
      'Data Emprestimo:        ${dateFormat.format(receipt.dataEmprestimo)}',
    ));
    bytes.addAll(generator.text(
      'Data Devolucao:         ${dateFormat.format(receipt.dataDevolucaoEfetiva)}',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text(
      'Devolucao Estimada:     ${dateOnlyFormat.format(receipt.dataDevolucaoPrevista)}',
    ));

    // Calculate delay/punctuality
    final bool isLate = receipt.dataDevolucaoEfetiva.isAfter(receipt.dataDevolucaoPrevista);
    if (isLate) {
      final daysLate = receipt.dataDevolucaoEfetiva.difference(receipt.dataDevolucaoPrevista).inDays;
      final displayDays = daysLate <= 0 ? 1 : daysLate;
      bytes.addAll(generator.text(
        _removeDiacritics('[!] Devolvido com atraso ($displayDays dia(s))'),
        styles: const PosStyles(bold: true),
      ));
    } else {
      bytes.addAll(generator.text(
        _removeDiacritics('[OK] Devolucao realizada no prazo previsto'),
        styles: const PosStyles(bold: true),
      ));
    }
    bytes.addAll(generator.hr());

    // --- Active Loans Remaining ---
    bytes.addAll(generator.text(
      'EMPRESTIMOS ATIVOS:',
      styles: const PosStyles(bold: true),
    ));
    bytes.addAll(generator.text(
      'Livros restantes em posse: ${receipt.activeLoansRemaining} de ${receipt.maxAllowedLoans} permitidos',
    ));
    if (receipt.activeLoansRemaining == 0) {
      bytes.addAll(generator.text(
        _removeDiacritics('Situacao: NENHUM LIVRO PENDENTE'),
        styles: const PosStyles(bold: true),
      ));
    } else {
      bytes.addAll(generator.text(
        _removeDiacritics('Situacao: ${receipt.activeLoansRemaining} exemplar(es) pendente(s)'),
      ));
    }
    bytes.addAll(generator.hr());

    // --- Footer Notice ---
    bytes.addAll(generator.text(
      _removeDiacritics('Exemplar devolvido e reintegrado ao acervo.'),
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(generator.text(
      _removeDiacritics('Obrigado por preservar nossos livros!'),
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ));
    bytes.addAll(generator.feed(2));

    // Cut paper (Partial cut with feed)
    bytes.addAll(generator.cut());

    return bytes;
  }

  /// Sends receipt bytes to the thermal printer via TCP Network, Linux USB node or Windows Spooler
  static Future<ReceiptPrintResult> _sendBytesToPrinter({
    required List<int> bytes,
    String? printerPathOrName,
    String? networkIp,
    int networkPort = 9100,
  }) async {
    // 1. Network TCP/IP printing (supported on both Linux & Windows)
    if (networkIp != null && networkIp.trim().isNotEmpty) {
      try {
        final socket = await Socket.connect(
          networkIp.trim(),
          networkPort,
          timeout: const Duration(seconds: 3),
        );
        socket.add(bytes);
        await socket.flush();
        await socket.close();
        return const ReceiptPrintResult(
          success: true,
          message: 'Comprovante impresso com sucesso via rede.',
        );
      } catch (e) {
        debugPrint('[ThermalPrinterService] Falha ao imprimir via rede TCP: $e');
      }
    }

    // 2. Linux OS: direct USB character device (/dev/usb/lp0, etc.)
    if (Platform.isLinux) {
      final devicePath = printerPathOrName ?? '/dev/usb/lp0';
      final deviceFile = File(devicePath);

      if (deviceFile.existsSync()) {
        try {
          await deviceFile.writeAsBytes(bytes);
          return ReceiptPrintResult(
            success: true,
            message: 'Comprovante impresso com sucesso em $devicePath.',
          );
        } on PathAccessException catch (e) {
          debugPrint('[ThermalPrinterService] 🔒 Permissão negada ao acessar $devicePath: $e');
          return const ReceiptPrintResult(
            success: false,
            message:
                'Impressora detectada em /dev/usb/lp0, mas o Linux requer permissão no grupo lp. Execute: sudo usermod -a -G lp \$USER ou sudo chmod 666 /dev/usb/lp0',
          );
        } catch (e) {
          debugPrint('[ThermalPrinterService] Erro ao gravar em $devicePath: $e');
        }
      }

      // Alternative on Linux: check alternative nodes (/dev/usb/lp1)
      for (final altNode in ['/dev/usb/lp1', '/dev/usb/lp2', '/dev/lp0']) {
        final altFile = File(altNode);
        if (altFile.existsSync()) {
          try {
            await altFile.writeAsBytes(bytes);
            return ReceiptPrintResult(
              success: true,
              message: 'Comprovante impresso com sucesso em $altNode.',
            );
          } catch (_) {}
        }
      }

      // Fallback: try CUPS lp command
      try {
        final tempFile = File('${Directory.systemTemp.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.bin');
        await tempFile.writeAsBytes(bytes);
        final res = await Process.run('lp', ['-o', 'raw', tempFile.path]);
        await tempFile.delete().catchError((_) => tempFile);
        if (res.exitCode == 0) {
          return const ReceiptPrintResult(
            success: true,
            message: 'Comprovante enviado ao spooler CUPS com sucesso.',
          );
        }
      } catch (_) {}
    }

    // 3. Windows OS: Windows Print Spooler RAW or virtual COM/USB port
    if (Platform.isWindows) {
      // A) If a COM/Serial port is provided (e.g. COM3)
      if (printerPathOrName != null && printerPathOrName.toUpperCase().startsWith('COM')) {
        try {
          final comFile = File(printerPathOrName);
          await comFile.writeAsBytes(bytes);
          return ReceiptPrintResult(
            success: true,
            message: 'Comprovante impresso com sucesso na porta $printerPathOrName.',
          );
        } catch (e) {
          debugPrint('[ThermalPrinterService] Falha na porta $printerPathOrName: $e');
        }
      }

      // B) Windows Spooler RAW printing via temporary file & PowerShell / CMD
      try {
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}\\receipt_${DateTime.now().millisecondsSinceEpoch}.bin');
        await tempFile.writeAsBytes(bytes);

        // Find Gprinter or default printer in Windows if not explicitly named
        String printerTarget = printerPathOrName ?? '';
        if (printerTarget.isEmpty) {
          final detectScript =
              r'Get-CimInstance Win32_Printer | Where-Object { $_.Name -like "*Gprinter*" -or $_.Name -like "*POS*" -or $_.Name -like "*80*" -or $_.Default -eq $true } | Select-Object -ExpandProperty Name -First 1';
          final detectResult = await Process.run('powershell', ['-Command', detectScript]);
          if (detectResult.exitCode == 0 && detectResult.stdout.toString().trim().isNotEmpty) {
            printerTarget = detectResult.stdout.toString().trim();
          }
        }

        if (printerTarget.isNotEmpty) {
          final printCmd = 'cmd /c copy /b "${tempFile.path}" "\\\\127.0.0.1\\$printerTarget"';
          final printResult = await Process.run('powershell', ['-Command', printCmd]);
          await tempFile.delete().catchError((_) => tempFile);

          if (printResult.exitCode == 0) {
            return ReceiptPrintResult(
              success: true,
              message: 'Comprovante enviado para a impressora Windows "$printerTarget".',
            );
          }
        }
      } catch (e) {
        debugPrint('[ThermalPrinterService] Erro ao imprimir no Windows: $e');
      }
    }

    // If no physical printer could be reached, log simulated success to prevent blocking kiosk flow
    debugPrint('[ThermalPrinterService] ⚠️ Impressora física não localizada ou offline. Comprovante gerado com sucesso em memória.');
    return const ReceiptPrintResult(
      success: false,
      message: 'Impressora física não localizada ou offline. Operação registrada com sucesso!',
    );
  }

  /// Sends the loan receipt to the printer
  static Future<ReceiptPrintResult> printReceipt({
    required LoanReceipt receipt,
    String? printerPathOrName,
    String? networkIp,
    int networkPort = 9100,
    img.Image? logoImage,
  }) async {
    try {
      final bytes = await generateReceiptBytes(receipt, logoImage: logoImage);
      return _sendBytesToPrinter(
        bytes: bytes,
        printerPathOrName: printerPathOrName,
        networkIp: networkIp,
        networkPort: networkPort,
      );
    } catch (e, stack) {
      debugPrint('[ThermalPrinterService] Erro inesperado ao emitir comprovante: $e\n$stack');
      return ReceiptPrintResult(
        success: false,
        message: 'Erro ao emitir comprovante: $e',
      );
    }
  }

  /// Sends the return receipt to the printer
  static Future<ReceiptPrintResult> printReturnReceipt({
    required ReturnReceipt receipt,
    String? printerPathOrName,
    String? networkIp,
    int networkPort = 9100,
    img.Image? logoImage,
  }) async {
    try {
      final bytes = await generateReturnReceiptBytes(receipt, logoImage: logoImage);
      return _sendBytesToPrinter(
        bytes: bytes,
        printerPathOrName: printerPathOrName,
        networkIp: networkIp,
        networkPort: networkPort,
      );
    } catch (e, stack) {
      debugPrint('[ThermalPrinterService] Erro inesperado ao emitir comprovante de devolucao: $e\n$stack');
      return ReceiptPrintResult(
        success: false,
        message: 'Erro ao emitir comprovante de devolução: $e',
      );
    }
  }
}
