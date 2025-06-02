import 'package:daily_checker/data/days_service.dart';
import 'package:daily_checker/data/jobs_service.dart';
import 'package:daily_checker/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';

class DailyJobsScreen extends StatefulWidget {
  const DailyJobsScreen({super.key});

  @override
  State<DailyJobsScreen> createState() => _DailyJobsScreenState();
}

class _DailyJobsScreenState extends State<DailyJobsScreen> {
  bool _dataLoaded = false;
  final jobService = JobsService();
  final dayService = DaysService();
  List<Job> _jobList = [];

  @override
  void initState() {
    super.initState();
    _loadJobDataAndResetStatus();
  }

  Future<void> _loadJobDataAndResetStatus() async {
    try {
      final DateTime jobDay = await dayService.getJobDay();
      final DateTime today = DateUtils.dateOnly(DateTime.now());

      _jobList = await jobService.getJobs();
      if (jobDay.isBefore(today)) {
        await jobService.resetJobsStatus();
        await dayService.resetJobDay();
      } else {
        await jobService.resetJobList();
      }
      _jobList = await jobService.getJobs();

      setState(() {
        _dataLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading/resetting job data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      setState(() {
        _dataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: !_dataLoaded
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                width: screenWidth < 1200 ? screenWidth : screenWidth * 0.4,
                child: ListView.builder(
                  itemCount: _jobList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      color: Colors.grey[900],
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: CheckboxListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        title: Text(
                          _jobList[index].name,
                          style: TextStyle(
                            decoration: _jobList[index].status
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: _jobList[index].status
                                ? Colors.grey[600]
                                : Colors.white,
                          ),
                        ),
                        value: _jobList[index].status,
                        onChanged: (bool? newValue) async {
                          if (newValue != null) {
                            await jobService.updateJobStatus(
                              _jobList[index].id,
                              newValue,
                            );
                            setState(() {});
                          }
                        },
                        activeColor: Colors.green,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _loadJobDataAndResetStatus();
        },
        tooltip: 'Refresh Job List',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
