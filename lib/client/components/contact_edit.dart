@HtmlImport("contact_edit.html")
library contacts.components.contact_edit;

import 'dart:async';
import 'dart:html';

import 'package:io_2016_contacts_demo/client/src/contact.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer/polymer.dart';

import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_checkbox.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/iron_label.dart';

import 'package:io_2016_contacts_demo/client/components/editor_for.dart';
import 'package:io_2016_contacts_demo/client/components/editor_templates/editor_for_string.dart';
import 'package:io_2016_contacts_demo/client/src/editor_implementation.dart';

///Uses [PaperInput], [PaperCheckbox], [PaperButton], [PaperCard], [IronLabel],
///[ScaffoldForEditor], [EditorForString]
@PolymerRegister('contact-edit')
class ContactEdit extends PolymerElement with EditorImplementation<Contact> {
  @Property(notify: true)
  bool open = false;
  @Property(notify: true) Contact value;

  ContactEdit.created() : super.created() ;
  factory ContactEdit () => new Element.tag('contact-edit');

  void ready() {
    _clear();
  }

  @reflectable
  void openAction([_, __]) {
    assert(!open);
    set('open', true);
  }

  @reflectable
  void saveAction([_, __]) {
    assert(open);
    fire('save', detail: value);
    _clear();
  }

  @reflectable
  void cancelAction([_, __]) {
    assert(open);
    _clear();
  }

  void _clear() {
    set('value', new Contact());
    set('open', false);
  }

  void upgradeElements(CustomEvent event) {
    window.console.log('Got an upgrade request (ContactEdit)!');
    Completer completion = event.detail;
  }

  Stream<Contact> get onValueChanged async* {
    await for (var event in on['value-changed']) {
      yield convertToDart(event).detail['value'];
    }
  }
}