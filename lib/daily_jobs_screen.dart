import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DailyJobsScreen extends StatefulWidget {
  const DailyJobsScreen({super.key});

  @override
  State<DailyJobsScreen> createState() => _DailyJobsScreenState();
}

class _DailyJobsScreenState extends State<DailyJobsScreen> {
  List<Map<String, dynamic>> _jobList = [];
  bool _dataLoaded = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadJobDataAndResetStatus();
  }

  Future<void> _loadJobDataAndResetStatus() async {
    final CollectionReference jobsCollection = _firestore.collection('jobs');
    final QuerySnapshot daySnapshot = await _firestore.collection('day').get();

    try {
      final QuerySnapshot jobSnapshot = await jobsCollection.get();

      if (jobSnapshot.docs.isNotEmpty) {
        _jobList = jobSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'] as String,
            'status': doc['status'] as bool,
          };
        }).toList();

        final DateTime today = _getOnlyDate(DateTime.now());
        if (daySnapshot.docs.isEmpty) {
          await _firestore.collection('day').add({
            'today': today.toIso8601String().substring(0, 10),
          });
        } else {
          final DateTime jobDate = _getOnlyDate(
            DateTime.parse(daySnapshot.docs.first['today'] as String),
          );

          if (jobDate.isBefore(today)) {
            debugPrint("Resetting job status for a new day");

            await _firestore
                .collection('day')
                .doc(daySnapshot.docs.first.id)
                .update({'today': today.toIso8601String().substring(0, 10)});

            final WriteBatch batch = _firestore.batch();
            for (final job in _jobList) {
              final docRef = jobsCollection.doc(job['id'] as String);
              job['status'] = false;
              batch.update(docRef, {'status': false});
            }
            await batch.commit();
          }
        }
      }

      setState(() {
        _dataLoaded = true;
      });
    } catch (e) {
      debugPrint("Error loading/resetting job data: $e");
      setState(() {
        _dataLoaded = true;
      });
    }
  }

  DateTime _getOnlyDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  Future<void> _updateJobStatus(String jobId, bool newStatus) async {
    final DocumentReference jobDocRef = _firestore
        .collection('jobs')
        .doc(jobId);

    try {
      await jobDocRef.update({'status': newStatus});

      final index = _jobList.indexWhere((job) => job['id'] as String == jobId);
      if (index != -1) {
        setState(() {
          _jobList[index]['status'] = newStatus;
        });
      }
    } catch (e) {
      debugPrint("Error updating job status: $e");
    }
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
      body: !_dataLoaded
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                width: screenWidth < 1200 ? screenWidth : screenWidth / 2,
                child: ListView.builder(
                  itemCount: _jobList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      elevation: 2.0,
                      child: CheckboxListTile(
                        title: Text(
                          _jobList[index]['name'] as String,
                          style: TextStyle(
                            decoration: _jobList[index]['status'] as bool
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: _jobList[index]['status'] as bool
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                        value: _jobList[index]['status'] as bool,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            _updateJobStatus(
                              _jobList[index]['id'] as String,
                              newValue,
                            );
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
    );
  }
}
