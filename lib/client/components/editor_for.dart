@HtmlImport('editor_for.html')

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;

import 'package:io_2016_contacts_demo/client/components/template_factory.dart';
import 'package:io_2016_contacts_demo/client/src/editor_implementation.dart';
/**
 * A Polymer editor-for element.
 */
@PolymerRegister('editor-for')
class ScaffoldForEditor extends PolymerElement with EditorImplementation<String> {
  @Property(notify: true, observer: 'valueChanged') dynamic value;
  @Property() String type;

  EditorImplementation _proxy;

  dynamic _debounceCeiling = null;
  dynamic _debounceFloor = null;

  ScaffoldForEditor.created() : super.created() {
  }

  void ready() {
    (() async {
      var injector = (Polymer.dom(document) as PolymerDom).querySelector(
          '#injector')
      as TemplateFactory;
      _proxy = injector.getEditorFor(type);
      this.attributes.forEach((attr, value) {
        _proxy.attributes[attr] = value;
      });
      _proxy.value = value;
      this.insertBefore(_proxy, null);
      _proxy.onValueChanged.listen((value) {
        if (_debounceFloor != null && value == _debounceFloor) {
          _debounceFloor = null;
          return;
        }
        _debounceCeiling = value;
        set('value', value);
      });
    })();
  }

  @reflectable
  void valueChanged (newValue, [_, __, ___]) {
    if (_debounceCeiling != null && newValue == _debounceCeiling) {
      _debounceCeiling = null;
      return;
    } else if (_proxy == null) {
      return;
    }
    _debounceFloor = newValue;
    _proxy.set('value', newValue);
  }
}
