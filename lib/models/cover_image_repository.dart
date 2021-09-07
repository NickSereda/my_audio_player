import 'dart:io';
import 'dart:typed_data';

import 'package:dart_tags/dart_tags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_audio_player/models/bloc/player_cubit.dart';
import 'package:path_provider/path_provider.dart';

/// Repository for getting cover image of the audio file.
///
/// Used in [PlayerCubit].
class CoverImageRepository {
  Future<List<int>> getImage({@required String id}) async {
    final filePath = id.replaceAll(RegExp('asset:///'), '');

    final ByteData bytes = await rootBundle.load(filePath);

    final imageData = await compute(
      _getAlbumCoverIsolate,
      bytes,
    ).catchError((e) => null);
    if (imageData == null) {
      return null;
    } else {
      return imageData;
    }
  }

  static Future<List<int>> _getAlbumCoverIsolate(ByteData bytes) async {
    final TagProcessor tagProcessor = TagProcessor();
    final List<Tag> meta = await tagProcessor.getTagsFromByteData(
      bytes,
      [TagType.id3v2],
    );
    if (meta == null) return null;
    // final String title = meta[0].tags['title'] ?? 'Untitled';
    // final String artist = meta[0].tags['artist'] ?? '';
    final AttachedPicture attachedPicture =
        (meta[0].tags['picture'] as Map).values.first;
    List<int> image;
    if (attachedPicture != null) {
      image = Uint8List.fromList(attachedPicture.imageData);
    }

    return image;
  }

  Future<void> setBackgroundImage(
      {List<int> image,
      String imageName,
      PlayerCubit activePlayerCubit}) async {
    final String dir = (await getTemporaryDirectory()).path;

    final File im = File('$dir/image$imageName.jpg');

    im.writeAsBytes(image).then((value) {
      final path = value.absolute.path;

      activePlayerCubit.loadBackgroundImage('file:///$path');
    });
  }
}
