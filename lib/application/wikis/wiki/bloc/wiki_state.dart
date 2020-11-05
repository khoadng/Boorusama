part of 'wiki_bloc.dart';

abstract class WikiState extends Equatable {
  const WikiState();

  @override
  List<Object> get props => [];
}

class WikiInitial extends WikiState {}

class WikiLoading extends WikiState {}

class WikiFetched extends WikiState {
  final Wiki wiki;

  WikiFetched(this.wiki);
}
