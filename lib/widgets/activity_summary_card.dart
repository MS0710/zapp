import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.startTime,
    required this.maxParticipants,
    required this.onTap,
    this.participantCount,
    this.backgroundColor = const Color(0xFF1C1C28),
  });

  final String title;
  final String? imageUrl;
  final String location;
  final DateTime? startTime;
  final int maxParticipants;
  final int? participantCount;
  final VoidCallback onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                color: Colors.grey.shade500,
                child:
                    imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => _buildImagePlaceholder(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return _buildImagePlaceholder(isLoading: true);
                          },
                        )
                        : _buildImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 5,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    _participantsText(),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    minFontSize: 5,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 116),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    location,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    minFontSize: 5,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    _formatDateTime(startTime),
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    minFontSize: 5,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _participantsText() {
    if (participantCount != null) {
      return '$participantCount/$maxParticipants';
    }

    if (maxParticipants > 0) {
      return '上限 $maxParticipants 人';
    }

    return '人數未定';
  }

  static String _formatDateTime(DateTime? d) {
    if (d == null) return '';
    final local = d.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y/$m/$day $hh:$mm';
  }

  Widget _buildImagePlaceholder({bool isLoading = false}) {
    return Container(
      color: Colors.grey.shade500,
      child: Center(
        child: Icon(
          isLoading ? Icons.downloading_rounded : Icons.image_outlined,
          color: Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}
