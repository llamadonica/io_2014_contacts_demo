library contact_service;

import "dart:async";
import "package:redstone/server.dart" as app;
import "package:redstone_mapper/plugin.dart";
import "package:redstone_mapper_mongo/service.dart";
import "package:mongo_dart/mongo_dart.dart";

import "package:io_2014_contacts_demo/client/contacts.dart";

@app.Group("/contact")
@Encode()
class ContactService extends MongoDbService<Contact> {

  ContactService() : super("contacts");

  @app.Route("/load")
  Future<List<Contact>> load() => find();

  @app.Route("/add", methods: const [app.POST])
  Future<Contact> add(@Decode() Contact contact) {
    contact.id = new ObjectId().toHexString();
    return insert(contact).then((_) => contact);
  }

  @app.Route("/delete/:id", methods: const [app.DELETE])
  Future<bool> delete(String id) =>
    remove(where.id(ObjectId.parse(id))).then((_) => true);

}