@HtmlImport('contact_item.html')
library contacts.components.contact_item;

import 'package:io_2016_contacts_demo/client/src/contact.dart';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';

import 'package:polymer_elements/paper_input.dart';
import 'package:polymer_elements/paper_checkbox.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:polymer_elements/paper_card.dart';

/// Uses [PaperButton], [PaperInput], [PaperCheckbox], [PaperCard]

@PolymerRegister('contact-item')
class ContactItem extends PolymerElement {
  @Property() Contact contact;

  ContactItem.created() : super.created();

  @reflectable
  void removeAction([_,__]) {
    fire('removeContact', detail: contact);
  }
}
