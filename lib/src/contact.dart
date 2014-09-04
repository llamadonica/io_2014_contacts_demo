library contacts.contact;

import "package:redstone_mapper/mapper.dart";

class Contact {

  @Field() int id;
  @Field() String name;
  @Field() String notes;
  @Field() bool important;

  Contact([this.name, this.notes, this.important, this.id]);

}
