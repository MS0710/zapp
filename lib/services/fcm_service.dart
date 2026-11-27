import 'dart:convert';

import 'package:firebase_core/firebase_core.dart'
    show Firebase, FirebaseException;
import 'package:firebase_messaging/firebase_messaging.dart'
    show
        FirebaseMessaging,
        NotificationSettings,
        RemoteMessage;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapp/firebase_options.dart';

final Logger _logger = Logger('FCMService');

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  _logger.info(
    'Handling a background message: ${message.messageId}, '
    'title: ${message.notification?.title}, body: ${message.notification?.body}',
  );
}

class FCMService {
  FCMService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl =
      'https://qxauaoytegxmrmtxdjqk.supabase.co/functions/v1';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final http.Client _client;

  bool _initialized = false;
  String? _lastRegisteredToken;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      _logger.info('FCM permission status: ${settings.authorizationStatus}');

      _messaging.onTokenRefresh.listen((newToken) async {
        _logger.info('FCM token refreshed: $newToken');
        if (_hasSession) {
          await _uploadTokenToBackend(newToken);
        } else {
          _logger.info('Token refreshed before login; backend registration skipped.');
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.info(
          'Foreground message received: ${message.messageId}, '
          'title: ${message.notification?.title}, body: ${message.notification?.body}',
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final activityId = message.data['activity_id'];
        final action = message.data['action'];
        _logger.info(
          'Notification opened from background: ${message.messageId}, '
          'activity_id: $activityId, action: $action, data: ${message.data}',
        );
      });

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _logger.info(
          'App opened from terminated state by notification: '
          '${initialMessage.messageId}, data: ${initialMessage.data}',
        );
      }
    } catch (error, stackTrace) {
      _logger.warning('FCM init skipped: $error', error, stackTrace);
    }
  }

  bool get _hasSession {
    final jwtToken = _supabase.auth.currentSession?.accessToken;
    return jwtToken != null && jwtToken.isNotEmpty;
  }

  Future<void> registerFcmToken() async {
    if (!_hasSession) {
      _logger.info('No session token yet; registerFcmToken skipped.');
      return;
    }

    final token = await _getAvailableFcmToken();
    if (token == null || token.isEmpty) return;
    await _uploadTokenToBackend(token);
  }

  Future<void> clearOnLogout() async {
    _lastRegisteredToken = null;

    try {
      await _messaging.deleteToken();
      _logger.info('FCM token deleted on logout.');
    } on FirebaseException catch (error, stackTrace) {
      _logger.info('FCM token delete skipped: ${error.code}');
      _logger.fine('FCM token delete exception details', error, stackTrace);
    } catch (error, stackTrace) {
      _logger.info('FCM token delete skipped: $error');
      _logger.fine('FCM token delete exception details', error, stackTrace);
    }
  }

  Future<String?> _getAvailableFcmToken() async {
    if (!kIsWeb) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          _logger.info('APNS token is not available yet; skipping FCM token fetch.');
          return null;
        }
        _logger.info('APNS token: $apnsToken');
      } on FirebaseException catch (error, stackTrace) {
        _logger.info('APNS token unavailable: ${error.code}');
        _logger.fine('APNS token exception details', error, stackTrace);
        return null;
      } catch (error, stackTrace) {
        _logger.info('APNS token unavailable: $error');
        _logger.fine('APNS token exception details', error, stackTrace);
        return null;
      }
    }

    try {
      final token = await _messaging.getToken();
      _logger.info('FCM token: $token');
      return token;
    } on FirebaseException catch (error, stackTrace) {
      _logger.info('FCM token unavailable: ${error.code}');
      _logger.fine('FCM token exception details', error, stackTrace);
      return null;
    } catch (error, stackTrace) {
      _logger.info('FCM token unavailable: $error');
      _logger.fine('FCM token exception details', error, stackTrace);
      return null;
    }
  }

  Future<void> _uploadTokenToBackend(String token) async {
    if (_lastRegisteredToken == token) {
      _logger.info('FCM token already registered; skipping duplicate upload.');
      return;
    }

    final jwtToken = _supabase.auth.currentSession?.accessToken;
    if (jwtToken == null || jwtToken.isEmpty) {
      _logger.info('No session token yet; postponing FCM registration.');
      return;
    }

    final uri = Uri.parse('$_baseUrl/register-fcm-token');
    final headers = <String, String>{
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode(<String, String>{'fcm_token': token});

    try {
      final response = await _client.post(uri, headers: headers, body: body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _lastRegisteredToken = token;
        _logger.info('FCM token registered successfully.');
        return;
      }

      _logger.warning(
        'FCM token registration failed: ${response.statusCode} ${response.body}',
      );
    } catch (error, stackTrace) {
      _logger.warning(
        'FCM token registration request failed: $error',
        error,
        stackTrace,
      );
    }
  }
}
