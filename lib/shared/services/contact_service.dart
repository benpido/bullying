import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/contact_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para gestionar contactos localmente (SharedPreferences)
/// y sincronizarlos con Firestore.
class ContactService {
  // Clave para almacenar la lista de contactos en SharedPreferences
  static const String _contactsKey = 'contacts';

  // Instancia de Firestore inyectable para facilitar pruebas unitarias
  final FirebaseFirestore _firestore;

  ContactService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Guarda la lista de contactos en SharedPreferences.
  /// Utiliza `toJson()` de `ContactModel` para serializar.
  Future<void> setContacts(List<ContactModel> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> contactsJson = contacts
          .map((c) => json.encode(c.toJson()))
          .toList();
      await prefs.setStringList(_contactsKey, contactsJson);
    } catch (e) {
      // Loguear el error para diagnóstico
      print('Error al guardar contactos: \$e');
      rethrow;
    }
  }

  /// Recupera los contactos de SharedPreferences.
  /// Devuelve lista vacía si ocurre un error o no hay datos.
  Future<List<ContactModel>> getContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? listJson = prefs.getStringList(_contactsKey);
      if (listJson == null) return [];
      return listJson
          .map((item) => ContactModel.fromJson(json.decode(item)))
          .toList();
    } catch (e) {
      print('Error al cargar contactos: \$e');
      return [];
    }
  }

  /// Sincroniza los contactos desde Firestore para el usuario [uid]
  /// y actualiza el almacenamiento local.
  Future<void> syncFromBackend(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .get();

      final contacts = snapshot.docs
          .map((doc) => ContactModel.fromJson(doc.data()))
          .toList();

      await setContacts(contacts);
    } catch (e) {
      print('Error al sincronizar contactos: \$e');
      // Opcional: reintentar o notificar al usuario
    }
  }
}
