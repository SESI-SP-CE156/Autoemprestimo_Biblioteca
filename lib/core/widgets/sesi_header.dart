import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class SesiHeader extends StatefulWidget {
  final bool isAdminArea;
  final VoidCallback? onAdminButtonPressed;

  const SesiHeader({
    super.key,
    this.isAdminArea = false,
    this.onAdminButtonPressed,
  });

  @override
  State<SesiHeader> createState() => _SesiHeaderState();
}

class _SesiHeaderState extends State<SesiHeader> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final timeFormat = DateFormat('HH:mm');

    String formattedDate;
    try {
      formattedDate = dateFormat.format(_currentTime);
      // Capitalize first letter
      formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
    } catch (_) {
      formattedDate = '${_currentTime.day}/${_currentTime.month}/${_currentTime.year}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // SESI Brand Logo
          SvgPicture.asset(
            'assets/vectors/sesi-logo.svg',
            height: 38,
            placeholderBuilder: (_) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'SESI',
                style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Container(height: 32, width: 1.5, color: AppColors.divider),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BIBLIOTECA ESCOLAR',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                widget.isAdminArea ? 'Painel Administrativo' : 'Totem de Autoatendimento',
                style: AppTypography.bodySmall.copyWith(
                  color: widget.isAdminArea ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Date & Time
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                formattedDate,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 14),
              Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                timeFormat.format(_currentTime),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Action button
          if (widget.onAdminButtonPressed != null)
            ElevatedButton.icon(
              onPressed: widget.onAdminButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isAdminArea ? AppColors.surfaceVariant : Colors.white,
                foregroundColor: widget.isAdminArea ? AppColors.textPrimary : AppColors.primary,
                elevation: 0,
                side: BorderSide(
                  color: widget.isAdminArea ? AppColors.border : AppColors.primary,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(
                widget.isAdminArea ? Icons.home_rounded : Icons.admin_panel_settings_rounded,
                size: 18,
              ),
              label: Text(
                widget.isAdminArea ? 'Voltar ao Totem' : 'Área do Bibliotecário',
                style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
