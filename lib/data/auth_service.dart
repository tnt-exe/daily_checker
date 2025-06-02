import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isCorrectPasscode(String passcode) async {
    final QuerySnapshot passcodeSnapshot = await _firestore
        .collection('passcode')
        .limit(1)
        .get();

    if (passcodeSnapshot.docs.isEmpty) {
      throw Exception('No passcode set in the database.');
    }

    final String storedPasscode = passcodeSnapshot.docs.first['passcode'];
    return storedPasscode == passcode;
  }
}
