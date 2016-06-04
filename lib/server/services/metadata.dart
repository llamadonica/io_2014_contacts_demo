library couchdb_metadata;

import 'package:redstone_mapper/mapper.dart';

class Id extends Field {
  const Id() : super(model: '_id', view: '_id');
}
class Rev extends Field {
  const Rev() : super(model: '_rev', view: '_rev');
}
