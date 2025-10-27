import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==================== MODELS ====================

class JobData {
  final String title;
  final String description;
  final double budget;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> requiredSkills;

  JobData({
    required this.title,
    required this.description,
    required this.budget,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.requiredSkills,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'budget': budget,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'required_skills': requiredSkills,
      'status': 'open',
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}

// ==================== BLOC EVENTS ====================

abstract class CreateJobEvent {}

class SubmitJob extends CreateJobEvent {
  final JobData jobData;
  SubmitJob(this.jobData);
}

class GetCurrentLocation extends CreateJobEvent {}

class ResetForm extends CreateJobEvent {}

// ==================== BLOC STATES ====================

abstract class CreateJobState {}

class CreateJobInitial extends CreateJobState {}

class LocationLoading extends CreateJobState {}

class LocationLoaded extends CreateJobState {
  final String location;
  final double latitude;
  final double longitude;

  LocationLoaded({
    required this.location,
    required this.latitude,
    required this.longitude,
  });
}

class LocationError extends CreateJobState {
  final String message;
  LocationError(this.message);
}

class CreateJobSubmitting extends CreateJobState {}

class CreateJobSuccess extends CreateJobState {
  final String jobId;
  CreateJobSuccess(this.jobId);
}

class CreateJobError extends CreateJobState {
  final String message;
  CreateJobError(this.message);
}

// ==================== BLOC ====================

class CreateJobBloc extends Bloc<CreateJobEvent, CreateJobState> {
  CreateJobBloc() : super(CreateJobInitial()) {
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<SubmitJob>(_onSubmitJob);
    on<ResetForm>(_onResetForm);
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<CreateJobState> emit,
  ) async {
    emit(LocationLoading());
    try {
      // Simulate getting location from Geolocator
      await Future.delayed(const Duration(seconds: 2));

      // Mock location - Replace with actual Geolocator
      emit(
        LocationLoaded(
          location: 'Soweto, Gauteng',
          latitude: -26.2478,
          longitude: 27.8546,
        ),
      );
    } catch (e) {
      emit(
        LocationError(
          'Failed to get location. Please enable location services.',
        ),
      );
    }
  }

  Future<void> _onSubmitJob(
    SubmitJob event,
    Emitter<CreateJobState> emit,
  ) async {
    emit(CreateJobSubmitting());
    try {
      // Simulate submitting to Supabase
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful submission
      final jobId = 'job_${DateTime.now().millisecondsSinceEpoch}';
      emit(CreateJobSuccess(jobId));
    } catch (e) {
      emit(CreateJobError('Failed to post job. Please try again.'));
    }
  }

  void _onResetForm(ResetForm event, Emitter<CreateJobState> emit) {
    emit(CreateJobInitial());
  }
}

// ==================== CREATE JOB SCREEN ====================

class CreateJobScreen extends StatelessWidget {
  const CreateJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateJobBloc(),
      child: const CreateJobScreenContent(),
    );
  }
}

class CreateJobScreenContent extends StatefulWidget {
  const CreateJobScreenContent({super.key});

  @override
  State<CreateJobScreenContent> createState() => _CreateJobScreenContentState();
}

class _CreateJobScreenContentState extends State<CreateJobScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  final List<String> _availableSkills = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Gardening',
    'Tiling',
    'Roofing',
    'Welding',
    'Moving',
  ];

  final List<String> _selectedSkills = [];
  String? _location;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CreateJobBloc, CreateJobState>(
        listener: (context, state) {
          if (state is LocationLoaded) {
            setState(() {
              _location = state.location;
              _latitude = state.latitude;
              _longitude = state.longitude;
            });
          }

          if (state is CreateJobSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Job posted successfully! 🎉'),
                backgroundColor: Color(0xFFFFD700),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Reset form
            _formKey.currentState?.reset();
            _titleController.clear();
            _descriptionController.clear();
            _budgetController.clear();
            setState(() {
              _selectedSkills.clear();
              _location = null;
              _latitude = null;
              _longitude = null;
            });

            context.read<CreateJobBloc>().add(ResetForm());
          }

          if (state is CreateJobError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CreateJobSubmitting;
          final isLoadingLocation = state is LocationLoading;

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.black,
                elevation: 0,
                title: const Text(
                  'Post a Job',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Form Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFD700,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFFFFD700,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFFFFD700),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Post your job and connect with skilled hustlers in your area!',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Job Title
                        _buildSectionTitle('Job Title'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hint: 'e.g., Plumbing Repair Needed',
                            icon: Icons.work_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a job title';
                            }
                            if (value.length < 5) {
                              return 'Title must be at least 5 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Description
                        _buildSectionTitle('Description'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 5,
                          decoration: _inputDecoration(
                            hint: 'Describe the job in detail...',
                            icon: Icons.description_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            if (value.length < 20) {
                              return 'Description must be at least 20 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Budget
                        _buildSectionTitle('Budget (in Rands)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _budgetController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _inputDecoration(
                            hint: 'e.g., 500',
                            icon: Icons.attach_money,
                            prefix: 'R ',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a budget';
                            }
                            final budget = double.tryParse(value);
                            if (budget == null || budget <= 0) {
                              return 'Please enter a valid budget';
                            }
                            if (budget < 50) {
                              return 'Minimum budget is R50';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Location
                        _buildSectionTitle('Location'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _location != null
                                  ? const Color(
                                      0xFFFFD700,
                                    ).withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: _location != null
                                        ? const Color(0xFFFFD700)
                                        : Colors.white.withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _location ?? 'No location set',
                                      style: TextStyle(
                                        color: _location != null
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: isLoadingLocation
                                      ? null
                                      : () {
                                          context.read<CreateJobBloc>().add(
                                            GetCurrentLocation(),
                                          );
                                        },
                                  icon: isLoadingLocation
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Icon(Icons.my_location, size: 18),
                                  label: Text(
                                    isLoadingLocation
                                        ? 'Getting Location...'
                                        : _location != null
                                        ? 'Update Location'
                                        : 'Get Current Location',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD700),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Required Skills
                        _buildSectionTitle('Required Skills (Optional)'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select skills needed for this job:',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableSkills.map((skill) {
                                  final isSelected = _selectedSkills.contains(
                                    skill,
                                  );
                                  return FilterChip(
                                    label: Text(skill),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedSkills.add(skill);
                                        } else {
                                          _selectedSkills.remove(skill);
                                        }
                                      });
                                    },
                                    backgroundColor: const Color(0xFF2A2A2A),
                                    selectedColor: const Color(0xFFFFD700),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    checkmarkColor: Colors.black,
                                    side: BorderSide(
                                      color: isSelected
                                          ? const Color(0xFFFFD700)
                                          : Colors.white.withValues(alpha: 0.3),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (isSubmitting || _location == null)
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final jobData = JobData(
                                        title: _titleController.text.trim(),
                                        description: _descriptionController.text
                                            .trim(),
                                        budget: double.parse(
                                          _budgetController.text,
                                        ),
                                        location: _location!,
                                        latitude: _latitude!,
                                        longitude: _longitude!,
                                        requiredSkills: _selectedSkills,
                                      );

                                      context.read<CreateJobBloc>().add(
                                        SubmitJob(jobData),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.grey.withValues(
                                alpha: 0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.send, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Post Job',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        if (_location == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Please set your location to post a job',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
      prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
      prefixText: prefix,
      prefixStyle: const TextStyle(
        color: Color(0xFFFFD700),
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
