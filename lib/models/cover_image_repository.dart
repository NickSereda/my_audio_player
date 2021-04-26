import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:dart_tags/dart_tags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';


import 'package:equatable/equatable.dart';

class AudioMetaModel {
  final String path;
  final String title;
  final String artist;
  final List<int> image;
  //final Uint8List image;
  // final String image;

  const AudioMetaModel({this.path, this.title, this.artist, this.image});

}


class CoverImageRepository {

  Future<List<int>> getImage() async {

    final filePath = AudioService.currentMediaItem.id.replaceAll(RegExp('asset:///'), '');

    final ByteData bytes = await rootBundle.load(filePath);

    final AudioMetaModel meta = await compute(
      _getAlbumCoverIsolate,
      bytes,
    ).catchError((e) => null);
    if (meta == null) {
      return null;
    } else {
      return meta.image;
    }
  }

  static Future<AudioMetaModel> _getAlbumCoverIsolate(ByteData bytes) async {
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

      // Set path and send to AudioService (to show backgroundImage)

    }

    return AudioMetaModel(
      path: null,
      // title: title,
      // artist: artist,
      image: image,
    );
  }

  Future<void> setBackgroundImage(List<int> image, String imageName) async {

    String dir = (await getTemporaryDirectory()).path;

    var im = File('$dir/image$imageName.jpg');

    im.writeAsBytes(image).then((value) {
      final path = value.absolute.path;

      print("PTH: $path");

      AudioService.customAction("loadBackgroundImage", 'file:///$path');
    });

  }

}
