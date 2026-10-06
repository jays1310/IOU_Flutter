import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/registered_user_model.dart';
import '../repositories/contacts_repository.dart';

class ContactsProvider extends ChangeNotifier {
  final ContactsRepository _repository = ContactsRepository();

  bool _isLoading = false;
  bool _hasPermission = false;

  List<Contact> _contacts = [];
  List<RegisteredUserModel> _registeredUsers = [];
  final Set<String> _selectedContacts = {};
  String _searchQuery = "";

  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;

  List<Contact> get contacts {
    if (_searchQuery.isEmpty) {
      return _contacts;
    }

    return _contacts.where((contact) {
      return contact.displayName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<RegisteredUserModel> get registeredUsers => _registeredUsers;

  Set<String> get selectedContacts => _selectedContacts;

  bool get canCreateGroup => _selectedContacts.length >= 2;

  Future<void> loadContacts() async {
    try {
      debugPrint("loadContacts() called");

      _isLoading = true;
      notifyListeners();

      _hasPermission = await _repository.requestPermission();

      debugPrint("Permission after request = $_hasPermission");

      if (!_hasPermission) {
        debugPrint("Permission denied");
        _contacts = [];
        return;
      }

      _contacts = await _repository.getContacts();

      final phoneNumbers = _contacts.map((contact) {
        String phone = contact.phones.first.number;

        phone = phone.replaceAll(RegExp(r'\s+'), '');

        if (phone.startsWith('+91')) {
          phone = phone.substring(3);
        }

        if (phone.startsWith('91') && phone.length == 12) {
          phone = phone.substring(2);
        }

        return phone;
      }).toList();

      debugPrint("========== ALL PHONE NUMBERS ==========");

      for (final number in phoneNumbers) {
        debugPrint(number);
      }

      debugPrint("=======================================");

      _registeredUsers = await _repository.getRegisteredContacts(
        phoneNumbers,
      );

      debugPrint("========== REGISTERED USERS ==========");

      for (final user in _registeredUsers) {
        debugPrint(
          "${user.username} - ${user.phoneNumber}",
        );
      }

      debugPrint("======================================");

      debugPrint("Contacts loaded = ${_contacts.length}");

      _contacts.sort(
            (a, b) => a.displayName.compareTo(b.displayName),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(String contactId) {
    if (_selectedContacts.contains(contactId)) {
      _selectedContacts.remove(contactId);
    } else {
      _selectedContacts.add(contactId);
    }

    notifyListeners();
  }

  void searchContacts(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}