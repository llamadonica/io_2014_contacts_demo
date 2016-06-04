@HtmlImport('template_factory.html')

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;

import 'package:io_2016_contacts_demo/client/components/editor_templates/editor_for_string.dart';
import 'package:io_2016_contacts_demo/client/components/contact_edit.dart';
import 'package:io_2016_contacts_demo/client/src/editor_implementation.dart';

/**
 * A Polymer app-injector element.
 */
@PolymerRegister('template-factory')
class TemplateFactory extends PolymerElement {
  TemplateFactory.created() : super.created();

  EditorImplementation  getEditorFor(String type, [String templateName, Map options]) {
    if (templateName == null) {
      switch (type) {
        case 'String': return new EditorForString();
        case 'Contact': return new ContactEdit();
        default: throw new ArgumentError('There is no suitable editor for'
            ' $type');
      }
    }
    return null;
  }
}

class PropertyMetadata {
  final String type;
  final String templateName;
  final String label;
  final List<PropertyMetadata> properties;

  PropertyMetadata(this.type, this.templateName, this.label, this.properties);

}
