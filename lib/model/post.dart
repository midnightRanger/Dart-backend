import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/author.dart';

import 'category.dart'; 


class Post extends ManagedObject<_Post> implements _Post {}

class _Post {
  @primaryKey
  int? id; //Номер заметки

  String? name; //Название заметки
  String? content; //Содержание заметки
  DateTime? creationDate; //дата создания
  DateTime? lastUpdating; //дата последнего изменения 


  //Аннотация для связи (#переменная с которой хотим сделать связь; обязательна ли эта связь; что делать при удалении записи)
  @Relate(#postList, isRequired: true, onDelete: DeleteRule.cascade)
  Author? author; //Создаем связь с моделью Author

  @Relate(#postList, isRequired: true, onDelete: DeleteRule.cascade)
  Category? category; 

  @Column(nullable: true, defaultValue: "true")
  bool? status; 
  
}