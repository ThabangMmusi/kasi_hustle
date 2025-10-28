import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/application.dart';
import '../../domain/usecases/application_usecases.dart';

part 'received_applications_event.dart';
part 'received_applications_state.dart';

class ReceivedApplicationsBloc
    extends Bloc<ReceivedApplicationsEvent, ReceivedApplicationsState> {
  final GetReceivedApplicationsUseCase getReceivedApplicationsUseCase;
  final UpdateApplicationStatusUseCase updateApplicationStatusUseCase;

  ReceivedApplicationsBloc({
    required this.getReceivedApplicationsUseCase,
    required this.updateApplicationStatusUseCase,
  }) : super(ReceivedApplicationsInitial()) {
    on<LoadReceivedApplications>(_onLoadReceivedApplications);
    on<RejectApplicationEvent>(_onRejectApplication);
    on<AcceptApplicationEvent>(_onAcceptApplication);
  }

  Future<void> _onLoadReceivedApplications(
    LoadReceivedApplications event,
    Emitter<ReceivedApplicationsState> emit,
  ) async {
    emit(ReceivedApplicationsLoading());
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        emit(ReceivedApplicationsError('User not authenticated'));
        return;
      }

      final applications = await getReceivedApplicationsUseCase(userId);
      emit(ReceivedApplicationsLoaded(applications: applications));
    } catch (e) {
      emit(ReceivedApplicationsError('Failed to load applications: $e'));
    }
  }

  Future<void> _onRejectApplication(
    RejectApplicationEvent event,
    Emitter<ReceivedApplicationsState> emit,
  ) async {
    if (state is ReceivedApplicationsLoaded) {
      final currentState = state as ReceivedApplicationsLoaded;
      try {
        await updateApplicationStatusUseCase(event.applicationId, 'rejected');

        final updatedApplications = currentState.applications
            .map(
              (app) => app.id == event.applicationId
                  ? Application(
                      id: app.id,
                      jobId: app.jobId,
                      jobTitle: app.jobTitle,
                      jobDescription: app.jobDescription,
                      budget: app.budget,
                      location: app.location,
                      latitude: app.latitude,
                      longitude: app.longitude,
                      applicantId: app.applicantId,
                      applicantName: app.applicantName,
                      message: app.message,
                      status: 'rejected',
                      appliedAt: app.appliedAt,
                      jobOwnerId: app.jobOwnerId,
                      jobOwnerName: app.jobOwnerName,
                    )
                  : app,
            )
            .toList();
        emit(currentState.copyWith(applications: updatedApplications));
      } catch (e) {
        emit(ReceivedApplicationsError('Failed to reject application: $e'));
      }
    }
  }

  Future<void> _onAcceptApplication(
    AcceptApplicationEvent event,
    Emitter<ReceivedApplicationsState> emit,
  ) async {
    if (state is ReceivedApplicationsLoaded) {
      final currentState = state as ReceivedApplicationsLoaded;
      try {
        await updateApplicationStatusUseCase(event.applicationId, 'accepted');

        final updatedApplications = currentState.applications
            .map(
              (app) => app.id == event.applicationId
                  ? Application(
                      id: app.id,
                      jobId: app.jobId,
                      jobTitle: app.jobTitle,
                      jobDescription: app.jobDescription,
                      budget: app.budget,
                      location: app.location,
                      applicantId: app.applicantId,
                      applicantName: app.applicantName,
                      message: app.message,
                      status: 'accepted',
                      appliedAt: app.appliedAt,
                      jobOwnerId: app.jobOwnerId,
                      latitude: app.latitude,
                      longitude: app.longitude,
                      jobOwnerName: app.jobOwnerName,
                    )
                  : app,
            )
            .toList();
        emit(currentState.copyWith(applications: updatedApplications));
      } catch (e) {
        emit(ReceivedApplicationsError('Failed to accept application: $e'));
      }
    }
  }
}
