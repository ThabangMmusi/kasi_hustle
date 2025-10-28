import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/usecases/application_usecases.dart';
import 'my_applications_event.dart';
import 'my_applications_state.dart';

class MyApplicationsBloc
    extends Bloc<MyApplicationsEvent, MyApplicationsState> {
  final GetMyApplicationsUseCase getMyApplicationsUseCase;
  final WithdrawApplicationUseCase withdrawApplicationUseCase;

  MyApplicationsBloc({
    required this.getMyApplicationsUseCase,
    required this.withdrawApplicationUseCase,
  }) : super(MyApplicationsInitial()) {
    on<LoadMyApplications>(_onLoadMyApplications);
    on<WithdrawMyApplication>(_onWithdrawMyApplication);
  }

  Future<void> _onLoadMyApplications(
    LoadMyApplications event,
    Emitter<MyApplicationsState> emit,
  ) async {
    emit(MyApplicationsLoading());
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        emit(MyApplicationsError('User not authenticated'));
        return;
      }

      final applications = await getMyApplicationsUseCase(userId);
      emit(MyApplicationsLoaded(applications: applications));
    } catch (e) {
      emit(MyApplicationsError('Failed to load applications: $e'));
    }
  }

  Future<void> _onWithdrawMyApplication(
    WithdrawMyApplication event,
    Emitter<MyApplicationsState> emit,
  ) async {
    if (state is MyApplicationsLoaded) {
      final currentState = state as MyApplicationsLoaded;
      try {
        await withdrawApplicationUseCase(event.applicationId);

        final updatedApplications = currentState.applications
            .where((app) => app.id != event.applicationId)
            .toList();
        emit(currentState.copyWith(applications: updatedApplications));
      } catch (e) {
        emit(MyApplicationsError('Failed to withdraw application: $e'));
      }
    }
  }
}
