import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to load and persist administrator contact information.
class AdminService {
  final FirebaseFirestore _firestore;
  AdminService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches the administrator contact info from `admins/<uid>`.
  Future<Map<String, dynamic>?> loadContactInfo(String uid) async {
    final doc = await _firestore.collection('admins').doc(uid).get();
    return doc.data();
  }

  /// Saves the admin contact info to [SharedPreferences].
  Future<void> saveContactInfo(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adminName', data['name'] as String? ?? '');
    await prefs.setString('adminPhone', data['phone'] as String? ?? '');
    await prefs.setString('adminEmail', data['email'] as String? ?? '');
  }

  /// Loads the saved admin contact info from [SharedPreferences].
  Future<Map<String, String>> getSavedContactInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('adminName') ?? '',
      'phone': prefs.getString('adminPhone') ?? '',
      'email': prefs.getString('adminEmail') ?? '',
    };
  }
}
