library contacts.contact;

import "package:redstone_mapper/mapper.dart";
import "package:redstone_mapper_mongo/metadata.dart";

class Contact {

  @Id() String id;
  @Field() String name;
  @Field() String notes;
  @Field() bool important;

  Contact([this.name, this.notes, this.important, this.id]);

}
