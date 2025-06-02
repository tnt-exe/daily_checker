import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String name;
  bool status;

  Job({required this.id, required this.name, this.status = false});

  factory Job.fromDocument(DocumentSnapshot doc) {
    return Job(
      id: doc.id,
      name: doc['name'] as String,
      status: doc['status'] as bool? ?? false,
    );
  }
}

class JobsService {
  JobsService._internal();
  static final JobsService _instance = JobsService._internal();
  factory JobsService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Job> _jobs = [];

  Future<List<Job>> getJobs() async {
    if (_jobs.isNotEmpty) {
      return _jobs;
    }

    final QuerySnapshot snapshot = await _firestore.collection('jobs').get();
    if (snapshot.docs.isEmpty) {
      throw Exception('No jobs found in the database.');
    }

    _jobs = snapshot.docs.map((doc) => Job.fromDocument(doc)).toList();
    return _jobs;
  }

  Future<void> updateJobStatus(String jobId, bool newStatus) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'status': newStatus,
    });
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      _jobs[index].status = newStatus;
    }
  }

  Future<void> resetJobsStatus() async {
    final WriteBatch batch = _firestore.batch();
    for (final job in _jobs) {
      final jobRef = _firestore.collection('jobs').doc(job.id);
      batch.update(jobRef, {'status': false});
      job.status = false;
    }
    await batch.commit();
  }

  Future<void> resetJobList() async {
    _jobs.clear();
    final QuerySnapshot snapshot = await _firestore.collection('jobs').get();
    if (snapshot.docs.isEmpty) {
      throw Exception('No jobs found in the database.');
    }
    _jobs = snapshot.docs.map((doc) => Job.fromDocument(doc)).toList();
  }
}
