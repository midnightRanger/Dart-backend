import 'dart:io';
import 'package:dart_backend/controllers/app_auth_controller.dart';
import 'package:dart_backend/controllers/app_post_controller.dart';
import 'package:dart_backend/controllers/app_user_controller.dart';

import 'controllers/app_token_controller.dart';
import 'model/author.dart'; 
import 'model/post.dart';
import 'model/user.dart'; 
import 'model/category.dart'; 

import 'package:conduit/conduit.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext; 

  @override 
  Future prepare () {
    final persisentStore = _initDatabase(); 

    managedContext = ManagedContext(
      ManagedDataModel.fromCurrentMirrorSystem(), persisentStore);
      return super.prepare(); 
  }

  @override 
  Controller get entryPoint => Router()
      ..route('token/[:refresh]').link(() => AppAuthController(managedContext),
      ) 
      ..route('user')
            .link(AppTokenController.new)!
            .link(() => AppUserController(managedContext),)
            
      ..route('post/[:id]')
              .link(AppTokenController.new)! 
              .link(() => AppPostController(managedContext));


  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres'; 
    final password = Platform.environment['DB_PASSWORD'] ?? '123'; 
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1'; 
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432'); 
    final databaseName = Platform.environment['DB_NAME'] ?? 'dart_backend'; 

    return PostgreSQLPersistentStore(username, password, host, port, databaseName); 
  }

}
 