@HtmlImport('editor_for_string.html')

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:io_2016_contacts_demo/client/src/editor_implementation.dart';

/**
 * A Polymer editor-for-string element.
 */
@PolymerRegister('editor-for-string')
class EditorForString extends PolymerElement with EditorImplementation<String> {
  @Property(notify: true) String value;
  @Property() String label;

  Stream<String> get onValueChanged async* {
    await for (var event in on['value-changed']) {
      yield convertToDart(event).detail['value'];
    }
  }

  EditorForString.created() : super.created();
  factory EditorForString () => new Element.tag('editor-for-string');

  void ready() {
    window.console.log('Hello dart!');
  }

}
