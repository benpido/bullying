import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact_model.dart';
import 'contact_service.dart';

/// Service encapsulating Firestore user related operations.
class UserService {
  final FirebaseFirestore _firestore;
  final ContactService _contactService;

  UserService({FirebaseFirestore? firestore, ContactService? contactService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _contactService = contactService ?? ContactService();

  /// Loads the user document applying retries and falling back to cache when
  /// offline. Returns `null` when no cached data is available.
  Future<DocumentSnapshot<Map<String, dynamic>>?> loadUserDocument(
    String uid,
  ) async {
    const maxRetries = 3;
    var delay = const Duration(seconds: 1);

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await _firestore
            .collection('users')
            .doc(uid)
            .get(const GetOptions(source: Source.server));
      } on FirebaseException catch (e) {
        if (e.code != 'unavailable') rethrow;
      }
      await Future.delayed(delay);
      delay *= 2;
    }

    try {
      return await _firestore
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.cache));
    } on FirebaseException {
      return null;
    }
  }

  /// Updates or adds the admin contact locally based on the user document.
  Future<void> syncAdminContact(Map<String, dynamic> data) async {
    final name = data['adminName'] as String?;
    final phone = data['adminPhone'] as String?;
    if (name == null || phone == null) return;

    final contacts = await _contactService.getContacts();
    final admin = ContactModel(name: name, phoneNumber: phone);
    final index = contacts.indexWhere((c) => c.phoneNumber == phone);
    if (index >= 0) {
      contacts[index] = admin;
    } else {
      contacts.add(admin);
    }
    await _contactService.setContacts(contacts);
  }
}
