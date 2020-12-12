import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    final currentEvent = event.toString();
    final index = currentEvent.indexOf('(');
    if (index > 0) {
      print('EVENT: ${currentEvent.substring(0, index)}');
    } else {
      print('EVENT: $event');
    }
    super.onEvent(bloc, event);
  }

  @override
  onTransition(Bloc bloc, Transition transition) {
    final currentState = transition.currentState.toString();
    final nextState = transition.nextState.toString();
    final indexCurrent = currentState.indexOf('(');
    final indexNext = nextState.indexOf('(');
    if (indexNext > 0 && indexCurrent > 0) {
      print(
          'TRANSITION: [${currentState.substring(0, indexCurrent)}] => [${nextState.substring(0, indexNext)}]');
    } else {
      print('TRANSITION: [$currentState] => [$nextState]');
    }
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print('ERROR: $error');
    super.onError(cubit, error, stackTrace);
  }
}
