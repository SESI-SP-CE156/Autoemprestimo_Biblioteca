import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class BookCoverImage extends StatelessWidget {
  final String? coverUrl;
  final String title;
  final String? author;
  final double width;
  final double height;
  final double borderRadius;

  const BookCoverImage({
    super.key,
    required this.coverUrl,
    required this.title,
    this.author,
    this.width = 160,
    this.height = 230,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: coverUrl != null && coverUrl!.isNotEmpty
            ? _buildCoverImage(coverUrl!)
            : _buildFallbackCover(),
      ),
    );
  }

  Widget _buildCoverImage(String url) {
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null) {
            debugPrint('[Cover] ✅ Imagem de capa carregada e exibida na tela: $url');
          }
          return child;
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.surfaceVariant,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[Cover] ℹ️ Falha ao carregar imagem online ($url). Exibindo capa alternativa SESI.');
          return _buildFallbackCover();
        },
      );
    } else {
      final cleanPath = url.startsWith('file://') ? url.replaceFirst('file://', '') : url;
      final file = File(cleanPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('[Cover] ⚠️ Erro ao ler arquivo local da capa ($cleanPath). Exibindo capa alternativa SESI.');
            return _buildFallbackCover();
          },
        );
      }
      return _buildFallbackCover();
    }
  }

  Widget _buildFallbackCover() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxHeight < 160;
        final padding = isSmall ? 8.0 : 12.0;
        final iconSize = isSmall ? 22.0 : 36.0;
        final titleFontSize = isSmall ? 10.5 : 13.0;
        final authorFontSize = isSmall ? 9.0 : 11.0;
        final spacing = isSmall ? 4.0 : 8.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primaryLight.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: iconSize,
                color: Colors.white70,
              ),
              SizedBox(height: spacing),
              Flexible(
                child: Text(
                  title,
                  maxLines: isSmall ? 2 : 4,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    height: 1.2,
                  ),
                ),
              ),
              if (author != null && author!.trim().isNotEmpty && constraints.maxHeight >= 110) ...[
                SizedBox(height: spacing / 2),
                Flexible(
                  child: Text(
                    author!,
                    maxLines: isSmall ? 1 : 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: authorFontSize,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
