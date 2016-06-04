library contacts.contact;

import "package:redstone_mapper/mapper.dart";
import "package:io_2016_contacts_demo/server/services/metadata.dart";

import "package:jsproxyize/jsproxyize.dart";

@jsProxyize class Contact {

  @PolymerReflectable() @Id() String id;
  @PolymerReflectable() @Rev() String rev;
  @PolymerReflectable() @Field() String name;
  @PolymerReflectable() @Field() String notes;
  @PolymerReflectable() @Field() bool important;
  @PolymerReflectable() @Field() String get type => 'contact';

  Contact([this.name, this.notes, this.important, this.id]);
}
