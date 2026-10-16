import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  debugPrint('Admin App background message: ${message.messageId}');
}

class PushNotificationService {
  final ApiClient _apiClient = locator<ApiClient>();
  final NavigationService _navigationService = locator<NavigationService>();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'voltspare_admin_notifications',
    'VoltSpare Admin Notifications',
    description: 'Notifications for new orders, rare part messages, and support tickets',
    importance: Importance.max,
    playSound: true,
  );

  bool _initialized = false;
  String? _currentToken;

  String? get currentToken => _currentToken;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }
      } catch (e) {
        debugPrint('Firebase initialize note: $e');
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('Admin FCM Authorization: ${settings.authorizationStatus}');

      if (!kIsWeb) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);

        const initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const initializationSettingsDarwin = DarwinInitializationSettings();
        const initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

        await _localNotifications.initialize(
          settings: initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            if (response.payload != null) {
              try {
                final data =
                    jsonDecode(response.payload!) as Map<String, dynamic>;
                _handleNotificationTap(data);
              } catch (_) {}
            }
          },
        );
      }

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Admin App foreground message: ${message.notification?.title}');
        final notification = message.notification;
        final android = message.notification?.android;

        if (notification != null && !kIsWeb) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Admin App opened from background: ${message.data}');
        _handleNotificationTap(message.data);
      });

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('Admin App opened from terminated: ${initialMessage.data}');
        Future.delayed(const Duration(milliseconds: 600), () {
          _handleNotificationTap(initialMessage.data);
        });
      }

      await syncTokenWithBackend();

      messaging.onTokenRefresh.listen((newToken) {
        debugPrint('Admin App FCM token refreshed: $newToken');
        _currentToken = newToken;
        registerTokenWithBackend(newToken);
      });

      _initialized = true;
    } catch (e) {
      debugPrint('Admin PushNotificationService initialize error: $e');
    }
  }

  Future<void> syncTokenWithBackend() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _currentToken = token;
        await registerTokenWithBackend(token);
      }
    } catch (e) {
      debugPrint('Admin FCM getToken error: $e');
    }
  }

  Future<void> registerTokenWithBackend(String token) async {
    try {
      String platform = 'web';
      if (!kIsWeb) {
        if (Platform.isIOS) {
          platform = 'ios';
        } else if (Platform.isAndroid) {
          platform = 'android';
        }
      }

      await _apiClient.post(
        '${ApiEndpoints.notifications}/device-token',
        data: {
          'token': token,
          'app': 'admin',
          'platform': platform,
          'deviceModel': kIsWeb ? 'Web Browser' : Platform.operatingSystem,
        },
      );
      debugPrint('✅ Admin FCM token registered with backend.');
    } catch (e) {
      debugPrint('Admin FCM token register failed: $e');
    }
  }

  Future<void> removeTokenOnLogout() async {
    try {
      if (_currentToken != null) {
        await _apiClient.post(
          '${ApiEndpoints.notifications}/device-token/deactivate',
          data: {'token': _currentToken},
        );
      }
      await FirebaseMessaging.instance.deleteToken();
      _currentToken = null;
      debugPrint('✅ Admin FCM token removed on logout.');
    } catch (e) {
      debugPrint('Admin FCM token remove failed: $e');
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('Navigating for admin notification: $data');
    final type = data['type'];
    switch (type) {
      case 'rare_product_chat':
        final requestId = data['requestId'] ?? data['conversationId'];
        if (requestId != null && requestId.toString().isNotEmpty) {
          _navigationService.navigateTo(
            Routes.adminRareRequestChatView,
            arguments: AdminRareRequestChatViewArguments(requestId: requestId.toString()),
          );
        } else {
          _navigationService.navigateTo(Routes.adminRareRequestsView);
        }
        break;
      case 'order_status':
      case 'new_order':
        _navigationService.navigateTo(Routes.adminOrdersView);
        break;
      default:
        break;
    }
  }
}
