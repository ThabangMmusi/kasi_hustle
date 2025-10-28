import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/widgets/job_card.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

class PostedJobsList extends StatelessWidget {
  final List<Job> postedJobs;

  const PostedJobsList({super.key, required this.postedJobs});

  @override
  Widget build(BuildContext context) {
    if (postedJobs.isEmpty) {
      return const Center(child: Text('You have not posted any jobs yet.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(Insets.lg),
      itemCount: postedJobs.length,
      itemBuilder: (context, index) {
        return JobCard(job: postedJobs[index]);
      },
    );
  }
}
