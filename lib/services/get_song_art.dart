import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

Future<Uri?> getSongArt(
    {required int id,
    required ArtworkType type,
    required int quality,
    required int size}) async {
  try {
    final OnAudioQuery onAudioQuery = OnAudioQuery();

    final Uint8List? data = await onAudioQuery.queryArtwork(
      id,
      type,
      quality: quality,
      format: ArtworkFormat.JPEG,
      size: size,
    );

    Uri? art;

    if (data != null) {
      final Directory tempDir = Directory.systemTemp;
      final File file = File('${tempDir.path}/$id-artwork.jpg');
      await file.writeAsBytes(data);
      art = file.uri;
    }
    return art;
  } catch (e) {
    debugPrint("Erreur récupération de l'artwork: $e");
    return null;
  }
}
