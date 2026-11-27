// lib/utils/log_utils.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// 初始化一次全局日志
void initLogging({Level level = Level.ALL}) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((rec) {
    // 这里用 debugPrint 输出，也会收到所有 info/warning/error
    debugPrint('${rec.level.name}: ${rec.loggerName}: ${rec.message}');
  });
}

/// 将任意对象转成漂亮的 JSON 字符串
String toPrettyJson(Object? data) {
  try {
    final obj = data is String ? json.decode(data) : data;
    return const JsonEncoder.withIndent('  ').convert(obj);
  } catch (_) {
    return data.toString();
  }
}

/// 给所有 Object 加上 logger 和两种输出方法
/// logPretty('Fetch Vendor data', map);
/// logger.info('Fetch Vendor data =${map}');
extension LogExtension on Object {
  /// 默认 logger，用类名或 runtimeType 作为 loggerName
  Logger get logger => Logger(runtimeType.toString());

  /// 普通一行 info
  void logInfo(String msg) => logger.info(msg);

  /// 普通一行 debug
  void logDebug(String msg) => logger.fine(msg);

  /// 普通一行 warning
  void logWarn(String msg) => logger.warning(msg);

  /// 普通一行 error
  void logError(String msg) => logger.severe(msg);

  /// 美化 JSON 的 info 输出
  void logPretty(String title, Object? data) {
    if (logger.isLoggable(Level.INFO)) {
      final pretty = toPrettyJson(data);
      debugPrint('▶️ $title:\n$pretty', wrapWidth: 2048);
      //logger.info('$title — see pretty JSON above');
    }
  }
}
