import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:get/get.dart';
import 'package:music_player_poc/services/song_handler.dart';
import 'package:music_player_poc/ui/screens/home.screen.dart';

SongHandler _songHandler = SongHandler();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _songHandler = await AudioService.init(
    builder: () => SongHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: "com.music.app",
      androidNotificationChannelName: "Music Player",
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightDynamic,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic,
            useMaterial3: true,
          ),
          home: HomeScreen(songHandler: _songHandler),
        );
      },
    );
  }
}
