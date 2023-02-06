import 'package:conduit/conduit.dart';
import 'dart:async'; 
import 'dart:io';

import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppTokenController extends Controller {
  @override
  FutureOr<RequestOrResponse?> handle (Request request) {
    try {
        //Получение токена через header-запрос
        final header = request.raw.headers.value(HttpHeaders.authorizationHeader); 
        //Из Header получаем token 
        final token = const AuthorizationBearerParser().parse(header);

        //Получение jwtClaim для проверки token 
        final jwtClaim = verifyJwtHS256Signature(token ?? "", "SECRET_KEY"); 
        //Валидируем наш token 
        jwtClaim.validate(); 
        return request; 
    }
    on JwtException
  }
}