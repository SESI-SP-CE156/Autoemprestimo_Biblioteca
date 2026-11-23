import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/barcode_scanner_listener.dart';
import '../../../../core/utils/idle_timeout_manager.dart';
import '../../../../core/widgets/sesi_header.dart';
import '../../application/kiosk_scanner_notifier.dart';
import '../widgets/book_info_card.dart';
import '../widgets/checkout_modal.dart';
import '../widgets/return_modal.dart';

class KioskScreen extends HookConsumerWidget {
  const KioskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerFocusNode = useFocusNode();
    final manualInputController = useTextEditingController();
    final isModalOpen = useState(false);

    void regainFocus() {
      if (!isModalOpen.value && !scannerFocusNode.hasFocus) {
        scannerFocusNode.requestFocus();
      }
    }

    // Automatically focus on start
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        regainFocus();
      });
      return null;
    }, []);

    void showSuccessFeedback(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        ),
      );
    }

    Future<void> openReturnModal(KioskScannerBookFound foundState) async {
      isModalOpen.value = true;

      final completed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ReturnModal(bookView: foundState.bookView),
      );

      isModalOpen.value = false;
      regainFocus();

      if (completed == true && context.mounted) {
        ref.read(kioskScannerNotifierProvider.notifier).reset();
        showSuccessFeedback('Livro devolvido com sucesso! Obrigado.');
      }
    }

    Future<void> openCheckoutModal(KioskScannerBookFound foundState) async {
      isModalOpen.value = true;

      final completed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => CheckoutModal(book: foundState.bookView.book),
      );

      isModalOpen.value = false;
      regainFocus();

      if (completed == true && context.mounted) {
        ref.read(kioskScannerNotifierProvider.notifier).reset();
        showSuccessFeedback('Empréstimo realizado com sucesso! Boa leitura.');
      }
    }

    Future<void> handleBarcode(String barcode) async {
      final notifier = ref.read(kioskScannerNotifierProvider.notifier);
      await notifier.onBarcodeScanned(barcode);

      final currentState = ref.read(kioskScannerNotifierProvider);
      if (currentState is KioskScannerBookFound && currentState.bookView.isBorrowed) {
        if (context.mounted) {
          openReturnModal(currentState);
        }
      }
    }

    final scannerState = ref.watch(kioskScannerNotifierProvider);

    return IdleTimeoutManager(
      enabled: scannerState is! KioskScannerInitial && !isModalOpen.value,
      timeout: const Duration(seconds: 40),
      onTimeout: () {
        ref.read(kioskScannerNotifierProvider.notifier).reset();
        regainFocus();
      },
      child: BarcodeScannerListener(
        focusNode: scannerFocusNode,
        autoFocus: true,
        onBarcodeScanned: (barcode) {
          if (!isModalOpen.value) {
            handleBarcode(barcode);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              SesiHeader(
                isAdminArea: false,
                onAdminButtonPressed: () {
                  context.push('/admin/login');
                },
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        switch (scannerState) {
                          KioskScannerInitial() => _buildIdlePrompt(
                              manualInputController: manualInputController,
                              onBarcodeSubmitted: handleBarcode,
                            ),
                          KioskScannerLoading() => const BookInfoCard(isLoading: true),
                          KioskScannerBookFound(:final bookView) => Column(
                              children: [
                                BookInfoCard(
                                  book: bookView.book,
                                  coverUrl: bookView.coverUrl,
                                  isLoading: false,
                                  onCheckoutPressed: () => openCheckoutModal(
                                    scannerState,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: () {
                                    ref.read(kioskScannerNotifierProvider.notifier).reset();
                                    regainFocus();
                                  },
                                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                                  label: const Text('Escanear outro exemplar'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          KioskScannerNotFound(:final barcode) => _buildNotFoundCard(
                              barcode: barcode,
                              onReset: () {
                                ref.read(kioskScannerNotifierProvider.notifier).reset();
                                regainFocus();
                              },
                            ),
                          KioskScannerError(:final message) => _buildErrorCard(
                              message: message,
                              onRetry: () {
                                ref.read(kioskScannerNotifierProvider.notifier).reset();
                                regainFocus();
                              },
                            ),
                        },
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomStatusIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdlePrompt({
    required TextEditingController manualInputController,
    required ValueChanged<String> onBarcodeSubmitted,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 720),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              size: 52,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Autoatendimento da Biblioteca',
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pegue o livro na prateleira e aponte o código de barras do exemplar para o leitor.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on_rounded, size: 20, color: AppColors.warning),
                const SizedBox(width: 10),
                Text(
                  'Leitor pronto: aponte o feixe vermelho para o código de barras',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 260,
                height: 42,
                child: TextField(
                  controller: manualInputController,
                  decoration: InputDecoration(
                    hintText: 'Digitar código manualmente',
                    hintStyle: AppTypography.bodySmall,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onSubmitted: (code) {
                    if (code.trim().isNotEmpty) {
                      onBarcodeSubmitted(code.trim());
                      manualInputController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final code = manualInputController.text.trim();
                  if (code.isNotEmpty) {
                    onBarcodeSubmitted(code);
                    manualInputController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Consultar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundCard({
    required String barcode,
    required VoidCallback onReset,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Exemplar Não Encontrado',
            style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'O código "$barcode" não está cadastrado no sistema da biblioteca.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            label: const Text('Escanear Outro Livro'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 56, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Aviso do Sistema',
            style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.circle, size: 10, color: AppColors.success),
          const SizedBox(width: 8),
          Text(
            'Totem Operacional',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.fiber_manual_record, size: 6, color: AppColors.border),
          const SizedBox(width: 10),
          const Icon(Icons.qr_code_scanner_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'Leitor de Código de Barras Ativo',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
