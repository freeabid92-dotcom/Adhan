import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../main.dart';

class AzanService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  static const String azanAssetPath = 'assets/audio/azan_makkah.mp3';
  static const String azanFajrAssetPath = 'assets/audio/azan_fajr.mp3';

  Future<void> init() async {
    tzdata.initializeTimeZones();
  }

  Future<void> playAzanNow({bool isFajr = false}) async {
    isPlaying = true;
    notifyListeners();
    await _player.setAsset(isFajr ? azanFajrAssetPath : azanAssetPath);
    await _player.play();
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        isPlaying = false;
        notifyListeners();
      }
    });
  }

  Future<void> stop() async {
    await _player.stop();
    isPlaying = false;
    notifyListeners();
  }

  Future<void> scheduleAzanNotifications(
      Map<String, DateTime> prayerTimes) async {
    await flutterLocalNotificationsPlugin.cancelAll();

    int notifId = 0;
    for (final entry in prayerTimes.entries) {
      if (entry.key == 'sunrise') continue;
      final time = entry.value;
      if (time.isBefore(DateTime.now())) continue;

      final isFajr = entry.key == 'fajr';
      final androidDetails = AndroidNotificationDetails(
        'azan_channel',
        'إشعارات الأذان',
        channelDescription: 'تنبيه صوتي عند دخول وقت كل صلاة',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound(
            isFajr ? 'azan_fajr' : 'azan_makkah'),
        playSound: true,
      );
      final iosDetails = DarwinNotificationDetails(
        sound: isFajr ? 'azan_fajr.aiff' : 'azan_makkah.aiff',
        presentSound: true,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notifId++,
        'حان الآن وقت صلاة ${_prayerNameArabic(entry.key)}',
        'الله أكبر، الله أكبر',
        tz.TZDateTime.from(time, tz.local),
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    }
  }

  String _prayerNameArabic(String key) {
    const names = {
      'fajr': 'الفجر',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
    };
    return names[key] ?? key;
  }
}
