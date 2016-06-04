@HtmlImport('remote_store_sync.html')
library contacts.remote_store_sync;

import 'dart:async';
import 'dart:html';

import 'package:io_2016_contacts_demo/client/src/contact.dart';
import 'package:io_2016_contacts_demo/client/src/sync.dart';
import 'package:polymer/polymer.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:web_components/web_components.dart';

import 'package:uuid/uuid.dart';

@PolymerRegister('remote-store-sync')
class RemoteStoreSync extends PolymerElement implements Sync {

  final String basePath = _getBasePath(); //"http://localhost:8080/services/contact";

  static String _getBasePath() =>
    '//' + window.location.hostname + ':8080/services/contact';

  RemoteStoreSync.created()
      : super.created();

  Future<List<Contact>> load() =>
    HttpRequest.request("$basePath/all")
      .then((HttpRequest req) => decodeJson(req.response, Contact));

  Future<Contact> addContact(Contact contact) {
    contact.id = new Uuid().v1();
    return HttpRequest.request("$basePath/${contact.id}", method: "PUT",
        sendData: encodeJson(contact),
        requestHeaders: {"Content-type": "application/json"}).then((req) {
      return decodeJson(req.response, Contact);
    });
  }

  Future<bool> delete(Contact contact) =>
    HttpRequest.request("$basePath/${contact.id}",
        method: "DELETE",
        requestHeaders: {'If-Match': contact.rev}).then((HttpRequest req) => req.responseText == "true");

}
