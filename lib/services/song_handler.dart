import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class SongHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
//Création de l'instance du lecteur audio avec le package juste_audio
  final AudioPlayer audioPlayer = AudioPlayer();

  /// Fonction qui permet de creer la source audio à partir l'item
  UriAudioSource _createAudioSource(MediaItem item) {
    return ProgressiveAudioSource(Uri.parse(item.id));
  }

  ///Ecoute le changement de l'index la music en cours  puis mise à jour du media item
  void _listenCurrentSongIndexChanges() {
    audioPlayer.currentIndexStream.listen(
      (index) {
        final playlist = queue.value;
        if (index == null || playlist.isEmpty) {
          return;
        }
        mediaItem.add(playlist[index]);
      },
    );
  }

  /// Broadcast de la lecture en arrière plans reçus PlaybackEvent
  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (audioPlayer.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed
        }[audioPlayer.processingState]!,
        playing: audioPlayer.playing,
        updatePosition: audioPlayer.position,
        bufferedPosition: audioPlayer.bufferedPosition,
        speed: audioPlayer.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  ///Fonction qui permet d'initialisé la music et de set up le player
  Future<void> initSongs(List<MediaItem> songs) async {
    audioPlayer.playbackEventStream.listen(_broadcastState);

    final audioSource = songs.map(_createAudioSource).toList();

    await audioPlayer
        .setAudioSource(ConcatenatingAudioSource(children: audioSource));
    queue.value.clear();
    queue.value.addAll(songs);
    queue.add(queue.value);

    _listenCurrentSongIndexChanges();

    audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  ///Fonction qui permet de jouer de la music en arrière plans
  @override
  Future<void> play() => audioPlayer.play();

  ///Fonction qui permet de mettre pause de la music en arrière plans
  @override
  Future<void> pause() => audioPlayer.pause();

  ///Fonction qui permet de changer la position de la music en arrière plans
  @override
  Future<void> seek(Duration position) => audioPlayer.seek(position);

  ///Fonction qui permet de changer la music en arrière plans
  @override
  Future<void> skipToQueueItem(int index) async {
    await audioPlayer.seek(Duration.zero, index: index);
    play();
  }

  ///Fonction qui permet de jouer la music suivante
  @override
  Future<void> skipToNext() => audioPlayer.seekToNext();

  ///Fonction qui permet de jouer la music précédente
  @override
  Future<void> skipToPrevious() => audioPlayer.seekToPrevious();
}
