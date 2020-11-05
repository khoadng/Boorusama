part of 'wiki_bloc.dart';

abstract class WikiEvent extends Equatable {
  const WikiEvent();

  @override
  List<Object> get props => [];
}

class WikiRequested extends WikiEvent {
  final String title;

  WikiRequested(this.title);
}
