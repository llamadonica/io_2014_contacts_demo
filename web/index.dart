import "package:polymer/polymer.dart";
import "package:redstone_mapper/mapper_factory.dart";

//it's necessary to import every lib that contains encodable classes
import "package:io_2014_contacts_demo/client/contacts.dart";

main() {
  bootstrapMapper();
  initPolymer();
}