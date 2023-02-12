import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration14 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("_User", "isActive", (c) {c.defaultValue = "true";c.isNullable = true;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    