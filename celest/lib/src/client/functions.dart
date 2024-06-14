// Generated by Celest. This file should not be modified manually, but
// it can be checked into version control.
// ignore_for_file: type=lint, unused_local_variable, unnecessary_cast, unnecessary_import

library; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _$convert;

import 'package:celest/celest.dart';
import 'package:celest_backend/exceptions/bad_name_exception.dart'
    as _$bad_name_exception;
import 'package:celest_backend/models/person.dart' as _$person;
import 'package:celest_core/src/exception/cloud_exception.dart';
import 'package:celest_core/src/exception/serialization_exception.dart';

import '../../client.dart';

class CelestFunctions {
  final greeting = CelestFunctionsGreeting();
}

class CelestFunctionsGreeting {
  Never _throwError({
    required int $statusCode,
    required Map<String, Object?> $body,
  }) {
    final $error = ($body['error'] as Map<String, Object?>);
    final $code = ($error['code'] as String);
    final $details = ($error['details'] as Map<String, Object?>?);
    switch ($code) {
      case r'BadRequestException':
        throw Serializers.instance.deserialize<BadRequestException>($details);
      case r'UnauthorizedException':
        throw Serializers.instance.deserialize<UnauthorizedException>($details);
      case r'InternalServerError':
        throw Serializers.instance.deserialize<InternalServerError>($details);
      case r'SerializationException':
        throw Serializers.instance
            .deserialize<SerializationException>($details);
      case r'BadNameException':
        throw Serializers.instance
            .deserialize<_$bad_name_exception.BadNameException>($details);
      case _:
        switch ($statusCode) {
          case 400:
            throw BadRequestException($code);
          case _:
            throw InternalServerError($code);
        }
    }
  }

  /// Says hello to a [person].
  Future<String> sayHello({required _$person.Person person}) async {
    final $response = await celest.httpClient.post(
      celest.baseUri.resolve('/greeting/say-hello'),
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: _$convert.jsonEncode(
          {r'person': Serializers.instance.serialize<_$person.Person>(person)}),
    );
    final $body =
        (_$convert.jsonDecode($response.body) as Map<String, Object?>);
    if ($response.statusCode != 200) {
      _throwError(
        $statusCode: $response.statusCode,
        $body: $body,
      );
    }
    return ($body['response'] as String);
  }
}