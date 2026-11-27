import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/activity.dart';
import '../models/activity_detail.dart';

/*class GroupSignupCard extends StatelessWidget {
  final ActivityItem item;
  final String actionLabel;

  /// 外部傳入：按「參加」要做什麼
  final Future<void> Function()? onActionTap;

  const GroupSignupCard({
    super.key,
    required this.item,
    this.actionLabel = '參加',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 120,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: widget.item.imageUrl != null &&
                                    widget.item.imageUrl!.trim().isNotEmpty
                                ? Image.network(
                                    widget.item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Container(color: Colors.grey[300]);
                                    },
                                  )
                                : Container(color: Colors.grey[300]),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: _circleIconButton(
                              icon: Icons.close,
                              onTap: () => Get.back(),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _circleIconButton(
                              icon: Icons.more_horiz,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      color: const Color(0xFF1C1C28),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  minFontSize: 10,
                                  maxLines: 1,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AutoSizeText(
                                    _formatDate(item.startTime),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                    minFontSize: 5,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(width: 8),
                                  AutoSizeText(
                                    item.location,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                    minFontSize: 5,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      '人數: ${item.participantCount}/${item.maxParticipants}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      minFontSize: 10,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    AutoSizeText(
                                      '備註: ${item.remarks.isNotEmpty ? item.remarks : '—'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      minFontSize: 10,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),

                              _actionButton(
                                actionLabel,
                                onTap: () async {
                                  if (onActionTap != null) {
                                    await onActionTap!();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _actionButton(String label, {VoidCallback? onTap}) {
    final deleteKeywords = ['刪除活動', '取消參加'];
    final isDelete = deleteKeywords.contains(label);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF9CA3AF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDelete) ...[
              Image.asset(
                'assets/images/join.png',
                width: 25,
                height: 25,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isDelete ? Colors.red : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime? d) {
    if (d == null) return '';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y/$m/$day';
  }
}*/
class GroupSignupCard extends StatefulWidget {
  final ActivityItem item;

  /// 外部傳入：按鈕文字（參加 / 等待審核 / 已加入 / 被拒絕）
  final String actionLabel;

  /// 外部傳入：按「參加」要做什麼（若為 null 代表不可點）
  final Future<void> Function()? onActionTap;

  /// ✅ 活動詳情（由 getActivityDetail 拿到），用於「展開」顯示完整資料
  final ActivityDetail? detail;

  const GroupSignupCard({
    super.key,
    required this.item,
    this.actionLabel = '參加',
    this.onActionTap,
    this.detail,
  });

  @override
  State<GroupSignupCard> createState() => _GroupSignupCardState();
}

class _GroupSignupCardState extends State<GroupSignupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasDetail = widget.detail != null;
    final imageUrl = (widget.detail?.imageUrl != null &&
            widget.detail!.imageUrl!.trim().isNotEmpty)
        ? widget.detail!.imageUrl!
        : widget.item.imageUrl;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 120,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: imageUrl != null && imageUrl.trim().isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Container(color: Colors.grey[300]);
                                    },
                                  )
                                : Container(color: Colors.grey[300]),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: _circleIconButton(
                              icon: Icons.close,
                              onTap: () => Get.back(),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _circleIconButton(
                              icon: Icons.more_horiz,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color(0xFF1C1C28),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          // ===== 標題列 + 展開按鈕 =====
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  widget.item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  minFontSize: 10,
                                  maxLines: 1,
                                ),
                              ),
                              if (hasDetail) ...[
                                const SizedBox(width: 8),
                                _expandButton(
                                  label: _expanded ? '收合' : '展開',
                                  onTap: () => setState(() => _expanded = !_expanded),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ===== 日期 + 地點 =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AutoSizeText(
                                _formatDateTime(widget.detail?.startTime ?? widget.item.startTime),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                minFontSize: 5,
                                maxLines: 1,
                              ),
                              const SizedBox(width: 8),
                              AutoSizeText(
                                widget.item.location,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                minFontSize: 5,
                                maxLines: 1,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ===== 人數/備註 + 參加按鈕 =====
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      '人數: ${widget.item.participantCount}/${widget.item.maxParticipants}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      minFontSize: 10,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    AutoSizeText(
                                      '備註: ${widget.item.remarks.isNotEmpty ? widget.item.remarks : '—'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      minFontSize: 10,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),

                              _actionButton(
                                widget.actionLabel,
                                onTap: widget.onActionTap == null
                                    ? null
                                    : () async {
                                  await widget.onActionTap!();
                                },
                              ),
                            ],
                          ),

                          // ===== 展開內容：會員友善 + 可上下滑 =====
                          if (_expanded && hasDetail) ...[
                            const SizedBox(height: 12),
                            _detailBlock(widget.detail!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // 展開內容：會員友善資訊
  // =========================
  Widget _detailBlock(ActivityDetail d) {
    final remarks = (d.remarks ?? '').trim();

    String myStatusText(String? s) {
      switch (s) {
        case 'pending':
          return '等待審核';
        case 'joined':
          return '已加入';
        case 'rejected':
          return '被拒絕';
        default:
          return '尚未申請';
      }
    }

    final hostName = _hostDisplayName(d);
    final joined = d.participants.where((p) => p.status == 'joined').toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 260),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 我的狀態（若你覺得不想顯示可刪掉這段）
              Row(
                children: [
                  const Icon(
                      Icons.info_outline, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '我的狀態：${myStatusText(d.myStatus)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 主辦人（沒值 -> 主辦人 + people icon）
              Row(
                children: [
                  _peopleAvatar(
                      url: d.host.avatarUrl, fallbackIcon: Icons.groups),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hostName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 活動說明（用標題+段落，不用「說明：xxx」工程格式）
              if (d.description
                  .trim()
                  .isNotEmpty) ...[
                const Text(
                  '活動說明',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  d.description.trim(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 備註（detail）

              if (remarks.isNotEmpty) ...[
                const Text(
                  '備註',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  remarks,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 已加入名單（只顯示 joined）
              Row(
                children: [
                  const Text(
                    '已加入',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${joined.length})',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (joined.isEmpty)
                const Text(
                  '目前還沒有人加入',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                )
              else
                ...List.generate(joined.length, (i) {
                  final p = joined[i];
                  final name = _participantDisplayName(p, i + 1);
                  final joinedAt = _fmtJoinTime(p.joinedAt);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        _peopleAvatar(url: p.user?.avatarUrl,
                            fallbackIcon: Icons.person),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          joinedAt,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  String _hostDisplayName(ActivityDetail d) {
    final nick = d.host.nickname.trim();
    final full = (d.host.fullName ?? '').trim();

    if (nick.isNotEmpty && full.isNotEmpty) return '$nick（$full）';
    if (nick.isNotEmpty) return nick;
    if (full.isNotEmpty) return full;
    return '主辦人';
  }

  String _participantDisplayName(ActivityParticipant p, int index) {
    final nick = (p.user?.nickname ?? '').trim();
    if (nick.isNotEmpty) return nick;
    return '參與人$index';
  }

  String _fmtJoinTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y/$m/$d $hh:$mm';
  }

  Widget _peopleAvatar({required String? url, required IconData fallbackIcon}) {
    final hasUrl = (url != null && url.trim().isNotEmpty);

    if (hasUrl) {
      return ClipOval(
        child: Image.network(
          url!,
          width: 34,
          height: 34,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(fallbackIcon),
        ),
      );
    }
    return _fallbackAvatar(fallbackIcon);
  }

  Widget _fallbackAvatar(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Icon(icon, color: Colors.white70, size: 18),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _expandButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String label, {VoidCallback? onTap}) {
    final deleteKeywords = ['刪除活動', '取消參加'];
    final isDelete = deleteKeywords.contains(label);

    final disabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF9CA3AF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDelete) ...[
                Image.asset(
                  'assets/images/join.png',
                  width: 25,
                  height: 25,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isDelete ? Colors.red : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime? d) {
    if (d == null) return '';
    final local = d.toLocal(); // ✅ 把 11:00Z 轉成台灣時間
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y/$m/$day $hh:$mm';
  }
}
