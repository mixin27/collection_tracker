import 'package:drift/drift.dart';

import 'items_table.dart';
import 'tags_table.dart';

@DataClassName('ItemTagData')
class ItemTags extends Table {
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {itemId, tagId};
}
