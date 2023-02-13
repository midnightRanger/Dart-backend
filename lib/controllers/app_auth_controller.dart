import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/history.dart';
import 'package:dart_backend/utils/app_utils.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../model/model_response.dart';
import '../model/user.dart';


import '../utils/app_response.dart';

class AppAuthController extends ResourceController {
  AppAuthController(this.managedContext);

  final ManagedContext managedContext;

@Operation.post() 
Future<Response> signIn(@Bind.body() User user) async {
  if(user.password == null || user.userName == null) {
    return Response.badRequest(
      body: ModelResponse(message: 'Поля: password и username обязательны'));
  }

  try {
    final qFindUser = Query<User>(managedContext)..where((element) => element.userName).equalTo(user.userName)..
    returningProperties((element) => [
      element.id,
      element.salt,
      element.hashPassword, element.isActive],
      );

    //Получение первого элемента из списка
    final findUser = await qFindUser.fetchOne();

    if (findUser == null) {
      throw QueryException.input("Пользователь не найден", []);
    }

    if (!findUser.isActive!) {
    return Response.forbidden(
      body: ModelResponse(message: 'Ваш аккаунт заблокирован'));
    }
        

    // генерация хэша пароля для дальнейшей проверки
    final requestHashPassword = 
      generatePasswordHash(user.password ?? ' ', findUser.salt ?? ' ');

    // Проверка пароля 
    if (requestHashPassword == findUser.hashPassword) {
      //Обновления token пароля
      _updateTokens(findUser.id ?? -1, managedContext); 

      //Получаем данные пользователя 
      final newUser = 
        await managedContext.fetchObjectWithID<User>(findUser.id);
      
      var qHistoryAdd = Query<History>(managedContext)
          ..values.dateTime = DateTime.now()
          ..values.type = "Authorization"
          ..values.user?.id = findUser.id; 
      qHistoryAdd.insert(); 

      return Response.ok(ModelResponse(
        data: newUser!.backing.contents, 
        message: "Успешная авторизация!",
      ));
    }
        else {
          throw QueryException.input("Неверный пароль", []);
        } 
  }
      
    catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.userName == null || user.email == null) {
      return Response.badRequest(
        body: ModelResponse(message: "Одно из полей: password, username, email не заполнено"),
      );
    }

    //Генерация соли
    final salt = generateRandomSalt(); 
    //Генерация хэша пароля 
    final hashPassword = generatePasswordHash(user.password!, salt);

    try {
      late final int id; 

      //Создание транзакции 
      await managedContext.transaction((transaction) async {
        //Создание запроса для создания пользователя
        final qCreateUser = Query<User> (transaction)
          ..values.userName = user.userName
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;

          //Добавление пользователя в БД
          final createdUser = await qCreateUser.insert(); 

          //Сохранение пользовательского ID
          id = createdUser.id!;

          //Обновление токена
          _updateTokens(id,transaction);
      });

      //Получение пользовательских данных по ID 
      final userData = await managedContext.fetchObjectWithID<User>(id);

      var qHistoryAdd = Query<History>(managedContext)
          ..values.dateTime = DateTime.now()
          ..values.type = "Registration"
          ..values.user?.id = id; 
      qHistoryAdd.insert(); 

      return AppResponse.ok(body: userData!.backing.contents, 
        message: 'Пользователь успешно зарегистрировался'
      ); 
    }
    catch (e) {
      return AppResponse.serverError(e); 
    }
  } 

  @Operation.post('refresh')
  Future<Response> refreshToken(@Bind.path('refresh') String refreshToken) async {
    try {
      //Получение ID пользователя из jwt-токена
      final id = AppUtils.getIdFromToken(refreshToken);

      //Получение данных пользователя по его ID
      final user = await managedContext.fetchObjectWithID<User>(id);

      if(user!.refreshToken != refreshToken) {
        return Response.unauthorized(body: "Non-valid token"); 
      }

      //Обновление token
      _updateTokens(id, managedContext);

      return Response.ok(
        ModelResponse(data: user.backing.contents,
        message: "Token was updated")
      );

    }
    catch (e) {
      return AppResponse.serverError(e);
    }
  } 

  void _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, String> tokens = _getTokens(id);

    final qUpdateTokens = Query<User> (transaction)
          ..where((element) => element.id).equalTo(id)
          ..values.accessToken = tokens['access']
          ..values.refreshToken = tokens['refresh'];

    await qUpdateTokens.updateOne();

  }

  Map<String, String> _getTokens(int id) {
    //todo remove when release 
    final key = Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';
    final accessClaimSet = JwtClaim(
        maxAge: const Duration(hours: 1),
        otherClaims: {'id': id}
    ); 

    final refreshClaimSet = JwtClaim(
        otherClaims: {'id': id},
    );

    final tokens = <String, String>{}; 
    tokens['access'] = issueJwtHS256(accessClaimSet, key);
    tokens ['refresh'] = issueJwtHS256(refreshClaimSet, key);

    return tokens; 
  }
}