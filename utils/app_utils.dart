import 'dart:io'; 
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:conduit/conduit.dart';

abstract class AppUtils {
  const AppUtils._(); 

  static int getIdFromToken(String token) {
    try {
      final key = Platform.environment["SECRET_KEY"] ?? 'SECRET_KEY';
      final jwtClaim = verifyJwtHS256Signature(token, key);
      return int.parse(jwtClaim["id"].toString());

    }

    catch (e) {
      rethrow;
    }
  }
}