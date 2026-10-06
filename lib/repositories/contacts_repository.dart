import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/registered_user_model.dart';
import '../core/services/contacts/contacts_service.dart';

class ContactsRepository {
  final ContactsService _contactsService = ContactsService();

  Future<bool> requestPermission() async {
    return await _contactsService.requestPermission();
  }

  Future<List<Contact>> getContacts() async {
    return await _contactsService.getContacts();
  }

  Future<List<RegisteredUserModel>> getRegisteredContacts(
      List<String> phoneNumbers,
      ) async {
    return await _contactsService.getRegisteredContacts(
      phoneNumbers,
    );
  }
}