import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyJobsScreen extends StatefulWidget {
  const DailyJobsScreen({super.key});

  @override
  State<DailyJobsScreen> createState() => _DailyJobsScreenState();
}

class _DailyJobsScreenState extends State<DailyJobsScreen> {
  final List<String> _jobTitles = ['Job 1', 'Job 2', 'Job 3'];
  late List<bool> _jobCompletionStatus;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _jobCompletionStatus = List<bool>.filled(_jobTitles.length, false);
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadJobStatus();
  }

  void _loadJobStatus() {
    final String? lastResetDate = _prefs.getString('lastResetDate');
    final String currentDate = DateTime.now().toIso8601String().substring(
      0,
      10,
    );

    if (lastResetDate != currentDate) {
      setState(() {
        _jobCompletionStatus = List<bool>.filled(_jobTitles.length, false);
      });
      _prefs.setString('lastResetDate', currentDate);
      _saveJobStatus();
    } else {
      for (int i = 0; i < _jobTitles.length; i++) {
        setState(() {
          _jobCompletionStatus[i] =
              _prefs.getBool('job_${i}_completed') ?? false;
        });
      }
    }
  }

  void _saveJobStatus() {
    for (int i = 0; i < _jobTitles.length; i++) {
      _prefs.setBool('job_${i}_completed', _jobCompletionStatus[i]);
    }
  }

  void _toggleJobCompletion(int index) {
    setState(() {
      _jobCompletionStatus[index] = !_jobCompletionStatus[index];
    });
    _saveJobStatus();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daily Jobs ${DateTime.now().toIso8601String().substring(0, 10)}",
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth < 1200 ? screenWidth : screenWidth / 2,
          child: ListView.builder(
            itemCount: _jobTitles.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                elevation: 2.0,
                child: CheckboxListTile(
                  title: Text(
                    _jobTitles[index],
                    style: TextStyle(
                      decoration: _jobCompletionStatus[index]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: _jobCompletionStatus[index]
                          ? Colors.grey[600]
                          : Colors.black,
                    ),
                  ),
                  value: _jobCompletionStatus[index],
                  onChanged: (bool? newValue) {
                    _toggleJobCompletion(index);
                  },
                  activeColor: Colors.green,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
