import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/home/presentation/widgets/job_card.dart';

// Dummy BLoC
abstract class BusinessHomeEvent {}
class LoadPostedJobs extends BusinessHomeEvent {}

abstract class BusinessHomeState {}
class BusinessHomeLoading extends BusinessHomeState {}
class BusinessHomeError extends BusinessHomeState {
  final String message;
  BusinessHomeError(this.message);
}
class BusinessHomeLoaded extends BusinessHomeState {
  final List<Job> postedJobs;
  BusinessHomeLoaded(this.postedJobs);
}

class BusinessHomeBloc extends Bloc<BusinessHomeEvent, BusinessHomeState> {
  BusinessHomeBloc() : super(BusinessHomeLoading()) {
    on<LoadPostedJobs>((event, emit) async {
      emit(BusinessHomeLoading());
      await Future.delayed(const Duration(seconds: 1));
      emit(BusinessHomeLoaded([
        Job(id: '1', title: 'Plumber Needed Urgently', description: 'Leaking pipe in the kitchen.', location: 'Pimville, Soweto', latitude: -26.26, longitude: 27.85, budget: 800, createdBy: 'me', createdAt: DateTime.now().subtract(const Duration(days: 2)), status: 'open'),
        Job(id: '2', title: 'Electrician for new wiring', description: 'Complete house wiring.', location: 'Diepkloof, Soweto', latitude: -26.25, longitude: 27.9, budget: 5000, createdBy: 'me', createdAt: DateTime.now().subtract(const Duration(days: 5)), status: 'closed'),
      ]));
    });
  }
}

class BusinessHomeScreen extends StatelessWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BusinessHomeBloc()..add(LoadPostedJobs()),
      child: const BusinessHomeScreenContent(),
    );
  }
}

class BusinessHomeScreenContent extends StatelessWidget {
  const BusinessHomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: UiText(text: 'My Job Posts', style: TextStyles.titleLarge),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<BusinessHomeBloc, BusinessHomeState>(
        builder: (context, state) {
          if (state is BusinessHomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BusinessHomeError) {
            return Center(child: Text(state.message));
          }
          if (state is BusinessHomeLoaded) {
            if (state.postedJobs.isEmpty) {
              return const Center(child: Text('You have not posted any jobs yet.'));
            }
            return ListView.builder(
              padding: EdgeInsets.all(Insets.lg),
              itemCount: state.postedJobs.length,
              itemBuilder: (context, index) {
                return JobCard(job: state.postedJobs[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to post job screen
        },
        label: const UiText(text: 'Post a Job'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}