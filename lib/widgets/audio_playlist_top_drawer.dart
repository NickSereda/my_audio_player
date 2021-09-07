// import 'package:audio_widgets/src/audio_playlist_widget.dart';
// import 'package:flutter/material.dart';
//
// /// An animated expanding playlist widget.
// ///
// /// [showPlaylistAnimationController] controls the expand/collapse animation.
// class AudioPlaylistTopDrawer extends StatelessWidget {
//   /// Creates an animated playlist widget.
//   ///
//   /// Use [showPlaylistAnimationController] to control the expand/collapse
//   /// animation.
//   const AudioPlaylistTopDrawer({
//     Key key,
//  //   @required this.audioPlayer,
//     @required this.showPlaylistAnimationController,
//   //  @required this.playlist,
//     this.nowPlayingIndex,
//   }) : super(key: key);
//
// //  final AssetsAudioPlayer audioPlayer;
//
//   /// An [AnimationController] for showing the playlist list view.
//   final AnimationController showPlaylistAnimationController;
//
//   //final ReadingPlaylist playlist;
//
//   /// Index of the currently playing track in the playlist.
//   final int nowPlayingIndex;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return SizeTransition(
//       sizeFactor: CurvedAnimation(
//         curve: Curves.fastOutSlowIn,
//         parent: showPlaylistAnimationController,
//       ),
//       child: Material(
//         color: theme.colorScheme.background,
//         child: AudioPlaylistWidget(
//          // audioPlayer: audioPlayer,
//           showPlaylistAnimationController: showPlaylistAnimationController,
//           // playlist: playlist,
//           // nowPlayingIndex: nowPlayingIndex,
//         ),
//       ),
//     );
//   }
// }
