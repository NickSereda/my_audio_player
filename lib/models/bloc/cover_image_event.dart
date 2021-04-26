part of 'cover_image_bloc.dart';

@immutable
abstract class CoverImageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitCoverImageEvent extends CoverImageEvent {
  InitCoverImageEvent();

  @override
  List<Object> get props => [];
}

class ImageLoadingEvent extends CoverImageEvent {
  ImageLoadingEvent();

  @override
  List<Object> get props => [];
}

class ImageDataChangedEvent extends CoverImageEvent {
  ImageDataChangedEvent();

  @override
  List<Object> get props => [];
}
