part of 'cover_image_bloc.dart';

abstract class CoverImageState extends Equatable {
  const CoverImageState();
}

class CoverImageInitial extends CoverImageState {

  @override
  List<Object> get props => [];
}

class CoverImageLoading extends CoverImageState {

  @override
  List<Object> get props => [];
}

class CoverImageLoaded extends CoverImageState {
  final List<int> image;

  CoverImageLoaded({this.image});

  @override
  List<Object> get props => [image];
}

class CoverImageFailure extends CoverImageState {

  @override
  List<Object> get props => [];
}


class CoverImageNetworkState extends CoverImageState {

  @override
  List<Object> get props => [];
}