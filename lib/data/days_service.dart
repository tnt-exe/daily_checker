import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DaysService {
  DaysService._internal();
  static final DaysService _instance = DaysService._internal();
  factory DaysService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DateTime> getJobDay() async {
    final QuerySnapshot daySnapshot = await _firestore
        .collection('day')
        .limit(1)
        .get();

    if (daySnapshot.docs.isEmpty) {
      final DateTime today = DateUtils.dateOnly(
        DateTime.now(),
      ).add(const Duration(hours: 3));

      await _firestore.collection('day').add({'today': today});
      return today;
    } else {
      final DateTime jobDate = (daySnapshot.docs.first['today'] as Timestamp)
          .toDate();
      return jobDate;
    }
  }

  Future<void> resetJobDay() async {
    final QuerySnapshot daySnapshot = await _firestore.collection('day').get();

    final DateTime today = DateUtils.dateOnly(
      DateTime.now(),
    ).add(const Duration(hours: 3));

    await _firestore.collection('day').doc(daySnapshot.docs.first.id).update({
      'today': today,
    });
  }

  DateTime getToday() {
    final DateTime today = DateTime.now();
    late DateTime day;

    if (today.hour < 3) {
      day = DateUtils.dateOnly(
        today,
      ).subtract(const Duration(days: 1)).add(const Duration(hours: 3));
    } else {
      day = DateUtils.dateOnly(today).add(const Duration(hours: 3));
    }

    return day;
  }
}
