library contacts.app;

import 'package:observe/observe.dart';
import 'contact.dart';
import 'sync.dart';

import "package:polymer/polymer.dart";

class App extends JsProxy {
  final Sync _sync;
  final List<Contact> contacts = new List<Contact>();

  bool _loading = false;

  App({Sync sync})
      : _sync = (sync == null) ? new Sync() : sync {
    reload();
  }

  void reload() {
    _sync.load().then(_onLoad);
  }

  void add(Contact contact) {
    assert(!contacts.contains(contact));

    // TODO: error handling
    _sync.addContact(contact).then((savedContact) {
      contacts.add(contact);
    });
  }

  void remove(Contact contact) {
    assert(contacts.contains(contact));
    var removed = contacts.remove(contact);
    assert(removed);
    _sync.delete(contact).then((removed) {
      print("removed okay? $removed");
    });
  }

  void _onLoad(List<Contact> value) {
    try {
      _loading = true;
      contacts.clear();
      contacts.addAll(value);
    } finally {
      _loading = false;
    }
  }
}
