import 'dart:io';
import 'package:dart_backend/controllers/app_auth_controller.dart';
import 'package:dart_backend/controllers/app_category_controller.dart';
import 'package:dart_backend/controllers/app_history_controller.dart';
import 'package:dart_backend/controllers/app_post_controller.dart';
import 'package:dart_backend/controllers/app_user_controller.dart';

import 'controllers/app_postaction_controller.dart';
import 'controllers/app_token_controller.dart';
import 'model/author.dart'; 
import 'model/post.dart';
import 'model/user.dart'; 
import 'model/category.dart';
import 'model/history.dart';  

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
              .link(() => AppPostController(managedContext),)
      ..route('postaction/[:id]')
              .link(AppTokenController.new)!
              .link(() => AppPostActionController(managedContext))
      ..route('history/[:id]')
              .link(AppTokenController.new)!
              .link(() => AppHistoryController(managedContext))
      ..route('category/[:id]')
              .link(AppTokenController.new)!
              .link(() => AppCategoryController(managedContext));

               
               
        
  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres'; 
    final password = Platform.environment['DB_PASSWORD'] ?? '123'; 
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1'; 
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5432'); 
    final databaseName = Platform.environment['DB_NAME'] ?? 'dart_backend'; 

    return PostgreSQLPersistentStore(username, password, host, port, databaseName); 
  }

}
 