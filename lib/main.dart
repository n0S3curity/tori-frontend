import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';

/// Background FCM handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init — on web, explicit FirebaseOptions are required.
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: firebaseApiKey,
          authDomain: firebaseAuthDomain,
          projectId: firebaseProjectId,
          storageBucket: firebaseStorageBucket,
          messagingSenderId: firebaseMessagingSenderId,
          appId: firebaseAppId,
        ),
      );
    } else {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  } catch (e) {
    debugPrint('[Firebase] Skipping init: $e');
  }

  runApp(
    const ProviderScope(
      child: ToriApp(),
    ),
  );
}
