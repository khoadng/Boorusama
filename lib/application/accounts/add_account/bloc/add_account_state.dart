part of 'add_account_bloc.dart';

abstract class AddAccountState extends Equatable {
  const AddAccountState();

  @override
  List<Object> get props => [];
}

class AddAccountInitial extends AddAccountState {}

class AddAccountProcessing extends AddAccountState {}

class AddAccountDone extends AddAccountState {}
