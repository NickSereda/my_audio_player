import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../cover_image_repository.dart';

part 'cover_image_event.dart';

part 'cover_image_state.dart';

class CoverImageBloc extends Bloc<CoverImageEvent, CoverImageState> {
  StreamSubscription<AudioProcessingState> _audioProcessingStateStream;

  CoverImageRepository _coverImageRepository = CoverImageRepository();

  CoverImageBloc() : super(CoverImageInitial());

  @override
  Future<void> close() {
    _audioProcessingStateStream?.cancel();
    return super.close();
  }

  @override
  void onChange(Change<CoverImageState> change) {
    print(change);
    super.onChange(change);
  }

  @override
  Stream<CoverImageState> mapEventToState(CoverImageEvent event) async* {
    if (event is InitCoverImageEvent) {
      // Checks if type is not network (as we fetch cover image only from assets)
      if (AudioService.currentMediaItem.id.startsWith("https://") ||
          AudioService.currentMediaItem.id.startsWith("http://") ||
          AudioService.currentMediaItem.id == null) {
        yield CoverImageNetworkState();
      } else {
        _audioProcessingStateStream = AudioService.playbackStateStream
            .map((state) => state.processingState)
            .distinct()
            .listen((processingState) {
          if (processingState == AudioProcessingState.skippingToNext ||
              processingState == AudioProcessingState.skippingToPrevious ||
              processingState == AudioProcessingState.skippingToQueueItem ||
              processingState == AudioProcessingState.ready) {
            add(ImageDataChangedEvent());
          }
        });
      }
      //yield CoverImageLoading();
    } else if (event is ImageDataChangedEvent) {
      String imageName = AudioService.currentMediaItem.title;

      // AudioService.customAction("setBackgroundImageToNull", imageName);

      yield CoverImageLoading();

      List<int> image = await _coverImageRepository.getImage().then((image) {
        _coverImageRepository.setBackgroundImage(image, imageName);
        return image;
      });

      if (image == null) {
        yield CoverImageFailure();
      } else {
        yield CoverImageLoaded(image: image);
      }
    } else if (event is ImageLoadingEvent) {
      yield CoverImageLoading();
    }
  }
}
