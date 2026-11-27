import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class MerchantActivityCard extends StatelessWidget {
  const MerchantActivityCard({
    super.key,
    required this.merchantId,
    required this.title,
    required this.imageUrl,
    required this.location,
    this.distanceLabel,
    this.onTap,
  });

  final String merchantId;
  final String title;
  final String? imageUrl;
  final String location;
  final String? distanceLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const double radius = 20.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap ?? _openPlaceDetail,
        child: SizedBox(
          height: 195,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: -50,
                child: Container(
                  height: 88,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF9FA7B6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (distanceLabel != null &&
                              distanceLabel!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.near_me_rounded,
                                    color: Colors.black87,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    distanceLabel!,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B27),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child:
                      imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                            imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _buildFallbackTitle(),
                          )
                          : _buildFallbackTitle(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPlaceDetail() {
    if (merchantId.trim().isEmpty) return;
    Get.toNamed(AppRoutes.PlaceDetail, arguments: {'merchantId': merchantId});
  }

  Widget _buildFallbackTitle() {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
