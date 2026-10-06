import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../models/registered_user_model.dart';
import '../../constants/api_constants.dart';

class ContactsService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<bool> requestPermission() async {
    final granted = await FlutterContacts.requestPermission(
      readonly: true,
    );

    debugPrint("Granted = $granted");

    return granted;
  }

  Future<List<Contact>> getContacts() async {
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    return contacts.where((contact) {
      return contact.phones.isNotEmpty;
    }).toList();
  }

  Future<List<RegisteredUserModel>> getRegisteredContacts(
      List<String> phoneNumbers,
      ) async {
    final response = await _dio.post(
      '/api/contacts/registered',
      data: {
        "phoneNumbers": phoneNumbers,
      },
    );

    return (response.data as List)
        .map(
          (user) => RegisteredUserModel.fromJson(user),
    )
        .toList();
  }
}