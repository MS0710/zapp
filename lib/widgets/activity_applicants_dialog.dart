// widgets/activity_applicants_dialog.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/activity_applicant.dart';
import '../services/activity_service.dart';
import '../utils/log_utils.dart';

class ActivityApplicantsDialog extends StatefulWidget {
  final int activityId;
  final String title;

  const ActivityApplicantsDialog({
    super.key,
    required this.activityId,
    required this.title,
  });

  @override
  State<ActivityApplicantsDialog> createState() => _ActivityApplicantsDialogState();
}

class _ActivityApplicantsDialogState extends State<ActivityApplicantsDialog> {
  final ActivityService _service = Get.find<ActivityService>();

  bool _loading = true;
  String? _error;
  ActivityApplicantsResponse? _res;

  String _filter = 'pending'; // pending / joined / rejected
  bool _reviewing = false;
  String? _reviewingUserId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _service.getActivityApplicants(activityId: widget.activityId);

      logger.logDebug('[ApplicantsDialog] loaded, count=${res.data.length} '
          'summary=${res.summary?.pending}/${res.summary?.joined}/${res.summary?.rejected}');

      setState(() {
        _res = res;
        _loading = false;
      });
    } catch (e, st) {
      logger.logError('[ApplicantsDialog] load failed: $e');
      logger.logError(st.toString());
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _review({
    required ActivityApplicantItem a,
    required String action, // 'approve' | 'reject'
  }) async
  {
    final uid = a.userId;
    if (uid.isEmpty) {
      Get.snackbar('失敗', '找不到 user_id', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() {
      _reviewing = true;
      _reviewingUserId = uid;
    });

    try {
      final msg = await _service.reviewParticipant(
        activityId: widget.activityId,
        userId: uid,
        action: action,
      );

      Get.snackbar('成功', msg, snackPosition: SnackPosition.BOTTOM);

      // 刷新名單（包含 summary 也會更新）
      await _load();
    } catch (e, st) {
      logger.logError('[ApplicantsDialog] review failed: $e');
      logger.logError(st.toString());

      Get.snackbar(
        '操作失敗',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _reviewing = false;
          _reviewingUserId = null;
        });
      }
    }
  }

  void _confirmReject(ActivityApplicantItem a) {
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C28),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '確認拒絕',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '確定要拒絕這位參與者嗎？\n此動作無法復原。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _smallActionBtn(
                        label: '取消',
                        enabled: true,
                        filled: false,
                        onTap: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _smallActionBtn(
                        label: '拒絕',
                        enabled: true,
                        filled: true,
                        onTap: () {
                          Get.back(); // 關 confirm dialog
                          _review(a: a, action: 'reject');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
    );
  }

  List<ActivityApplicantItem> get _filtered {
    final list = _res?.data ?? const <ActivityApplicantItem>[];
    return list.where((a) => a.status == _filter).toList();
  }

  static const Color cardBg = Color(0xFF1C1C28);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
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
                    // ===== Header =====
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Row(
                        children: [
                          _circleIconButton(
                            icon: Icons.close,
                            onTap: () => Get.back(),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AutoSizeText(
                              '報名名單',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              minFontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _circleIconButton(
                            icon: Icons.refresh,
                            onTap: _load,
                          ),
                        ],
                      ),
                    ),

                    // 活動標題
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          minFontSize: 10,
                        ),
                      ),
                    ),

                    // ===== Body =====
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(18),
                        child: CircularProgressIndicator(),
                      )
                    else if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            _pill(
                              label: '重試',
                              active: true,
                              onTap: _load,
                            ),
                          ],
                        ),
                      )
                    else
                      _buildContent(),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final s = _res?.summary;
    final pending = s?.pending ?? 0;
    final joined = s?.joined ?? 0;
    final rejected = s?.rejected ?? 0;

    final list = _filtered;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // summary + filter pills
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  '待審 $pending  ·  已加入 $joined  ·  已拒絕 $rejected',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 1,
                  minFontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: _pill(
                  label: '待審',
                  active: _filter == 'pending',
                  onTap: () => setState(() => _filter = 'pending'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _pill(
                  label: '已加入',
                  active: _filter == 'joined',
                  onTap: () => setState(() => _filter = 'joined'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _pill(
                  label: '已拒絕',
                  active: _filter == 'rejected',
                  onTap: () => setState(() => _filter = 'rejected'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // list
        Container(
          constraints: const BoxConstraints(maxHeight: 360),
          child: list.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '目前沒有資料',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _applicantRow(list[i]),
          ),
        ),
      ],
    );
  }

  Widget _applicantRow(ActivityApplicantItem a) {
    final p = a.profile;
    final nick = (p?.nickname ?? '').isNotEmpty ? p!.nickname : '（未設定暱稱）';
    final fullName = (p?.fullName ?? '').trim();
    final joinedAt = _fmt(a.joinedAt);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(12),
              image: (p?.avatarUrl != null && (p!.avatarUrl!).isNotEmpty)
                  ? DecorationImage(image: NetworkImage(p.avatarUrl!), fit: BoxFit.cover)
                  : null,
            ),
          ),
          const SizedBox(width: 10),

          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nick,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fullName.isNotEmpty)
                  Text(
                    fullName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (joinedAt.isNotEmpty)
                  Text(
                    joinedAt,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // pending → 同意/拒絕；其他狀態 → badge
          if (a.status == 'pending')
            _pendingActions(a)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _statusLabel(a.status),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pendingActions(ActivityApplicantItem a) {
    final uid = a.userId;
    final isBusy = _reviewing && _reviewingUserId == uid;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _smallActionBtn(
          label: isBusy ? '處理中…' : '同意',
          enabled: !isBusy,
          onTap: () => _review(a: a, action: 'approve'),
          filled: true,
        ),
        const SizedBox(width: 8),
        _smallActionBtn(
          label: '拒絕',
          enabled: !isBusy,
          onTap: () => _confirmReject(a),
          filled: false,
        ),
      ],
    );
  }

  Widget _smallActionBtn({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    required bool filled,
  })
  {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: filled ? Colors.black : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending':
        return '待審';
      case 'joined':
        return '已加入';
      case 'rejected':
        return '已拒絕';
      default:
        return s;
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return '';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$y/$m/$day $hh:$mm';
    // 你也可以只顯示日期：return '$y/$m/$day';
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  })
  {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _pill({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
