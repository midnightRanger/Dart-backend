import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/author.dart';
import 'package:dart_backend/model/post.dart'; 

class Category extends ManagedObject<_Category> implements _Category {}

class _Category {
  @primaryKey
  int? id; 
  String? categoryName;  
  
  //При помощи класса ManagedSet
  ManagedSet<Post>? postList; 

  @Relate(#categoryList, isRequired: true, onDelete: DeleteRule.cascade)
  Author? author;
}