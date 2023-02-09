import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration10 extends Migration { 
  @override
  Future upgrade() async {
   		database.deleteColumn("_Post", "categoryId");
		database.addColumn("_Category", SchemaColumn.relationship("author", ManagedPropertyType.bigInteger, relatedTableName: "_Author", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    