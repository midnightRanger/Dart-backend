import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/author.dart';
import 'package:dart_backend/model/user.dart';

import 'category.dart'; 


class History extends ManagedObject<_History> implements _History {}

class _History {
  @primaryKey
  int? id; 
 
  String? type; 
  DateTime? dateTime; //дата создания
 
  @Relate(#historyList, isRequired: true, onDelete: DeleteRule.cascade)
  User? user; //Создаем связь с моделью User
}