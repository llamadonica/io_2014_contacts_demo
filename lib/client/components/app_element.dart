@HtmlImport('app_element.html')
library contacts.components.app_element;

import 'dart:async';
import 'dart:html';

import 'package:io_2016_contacts_demo/client/src/app.dart';
import 'package:io_2016_contacts_demo/client/src/sync.dart';

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_input.dart';

import 'package:io_2016_contacts_demo/client/components/remote_store_sync.dart';
import 'package:io_2016_contacts_demo/client/components/contact_edit.dart';
import 'package:io_2016_contacts_demo/client/components/contact_item.dart';

import 'package:io_2016_contacts_demo/client/components/editor_templates/editor_for_string.dart';
import 'package:io_2016_contacts_demo/client/contacts.dart';

import 'package:io_2016_contacts_demo/client/module.dart' as module;

///Uses [ContactEdit], [ContactItem], [EditorForString]
@PolymerRegister('app-element')
class AppElement extends PolymerElement {
  @Property() String syncId;
  @Property() final List<Contact> contacts = new List<Contact>();
  Sync _sync;

  bool _loading;


  AppElement.created() : super.created() {
    //
    // Listen for removeContact event and remove the associated contact
    //
    on['removeContact'].listen((event) {
      var contact = convertToDart(event).detail as Contact;

      if (_sync == null) return;

      _removeContact(contact);
    });
    window.console.log(evil_singleton.injector.get(String));
  }

  @reflectable
  void saveHandler([CustomEvent event, __]) {
    var contact = event.detail as Contact;
    window.console.log(contact);

    _addContact(contact);
  }

  void ready() {
    (() async {
      assert(_sync == null);
      if (syncId == null) return;
      _sync = (Polymer.dom(document) as PolymerDom).querySelector(
          '#$syncId') as Sync;
      _reload();
    })();
  }



  void _reload() {
    _sync.load().then(_onLoad);
  }

  void _addContact(Contact contact) {
    assert(!contacts.contains(contact));

    // TODO: error handling
    _sync.addContact(contact).then((savedContact) {
      this.add('contacts', savedContact);
    });
  }

  void _removeContact(Contact contact) {
    assert(contacts.contains(contact));
    var removed = this.removeItem('contacts', contact);
    assert(removed);
    _sync.delete(contact).then((removed) {
      print("removed okay? $removed");
    });
  }

  void _onLoad(List<Contact> value) {
    try {
      _loading = true;
      clear('contacts');
      addAll('contacts', value);
    } finally {
      _loading = false;
    }
  }
}
