import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/models/scanned_book_view.dart';
import '../domain/repositories/kiosk_repository.dart';

part 'kiosk_scanner_notifier.g.dart';

sealed class KioskScannerState {
  const KioskScannerState();
}

class KioskScannerInitial extends KioskScannerState {
  const KioskScannerInitial();
}

class KioskScannerLoading extends KioskScannerState {
  final String barcode;
  const KioskScannerLoading(this.barcode);
}

class KioskScannerBookFound extends KioskScannerState {
  final ScannedBookView bookView;
  const KioskScannerBookFound(this.bookView);
}

class KioskScannerNotFound extends KioskScannerState {
  final String barcode;
  const KioskScannerNotFound(this.barcode);
}

class KioskScannerError extends KioskScannerState {
  final String message;
  const KioskScannerError(this.message);
}

@riverpod
class KioskScannerNotifier extends _$KioskScannerNotifier {
  @override
  KioskScannerState build() => const KioskScannerInitial();

  KioskRepository get _repository => ref.read(kioskRepositoryProvider);

  Future<void> onBarcodeScanned(String barcode) async {
    final cleanCode = barcode.trim();
    if (cleanCode.isEmpty) return;

    state = KioskScannerLoading(cleanCode);

    try {
      final bookView = await _repository.getBookByBarcode(cleanCode);
      if (bookView == null) {
        state = KioskScannerNotFound(cleanCode);
      } else {
        state = KioskScannerBookFound(bookView);
      }
    } catch (e) {
      state = KioskScannerError('Erro ao buscar exemplar: $e');
    }
  }

  void reset() {
    state = const KioskScannerInitial();
  }
}

// Alias for convenience and backward compatibility
final kioskScannerNotifierProvider = kioskScannerProvider;
