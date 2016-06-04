library contact_service;

import "dart:async";
import "package:redstone/redstone.dart" as app;
import "package:redstone_mapper/plugin.dart";
import "package:redstone_mapper_mongo/service.dart";
import "package:mongo_dart/mongo_dart.dart";

import "package:io_2016_contacts_demo/client/contacts.dart";
import 'package:shelf/shelf.dart' as shelf;

import 'package:io_2016_contacts_demo/server/services/couchdb_service.dart';
import 'package:uuid/uuid.dart';

@app.Group("/contact")
@Encode()
class ContactService extends CouchDbServiceExperimental<Contact> {
  @app.Interceptor(r"/.*", chainIdx: 1)
  handleCORS() async {
    if (app.request.method != "OPTIONS") {
      await app.chain.next();
      return app.response.change(headers: {"Access-Control-Allow-Origin": "*"});
    }
    return app.response.change(headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST,GET,DELETE",
      "Access-Control-Allow-Headers": "Content-Type"
    });
  }

  ContactService() : super("contacts", "all");

  @app.Route("/all")
  Future<shelf.Response> load() => viewAsShelfResponse();

  @app.Route("/:id", methods: const [app.PUT])
  Future<Contact> add(String id, @Decode() Contact contact) async {
    contact.id = id;
    contact.rev = await this.insert(contact);
    return contact;
  }

  @app.Route("/:id", methods: const [app.DELETE])
  Future<bool> delete(String id) {
    var rev = app.request.headers['If-Match'];
    return remove(id, rev).then((_) => true);
  }
}
