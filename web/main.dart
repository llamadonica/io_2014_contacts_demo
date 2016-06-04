import "package:polymer/polymer.dart";
import "package:redstone_mapper/mapper_factory.dart";

//it's necessary to import every lib that contains encodable classes
import "package:io_2016_contacts_demo/client/src/contact.dart";
import "package:polymer_elements/paper_styles.dart";
import "package:io_2016_contacts_demo/client/components/app_element.dart";
import "package:io_2016_contacts_demo/client/components/remote_store_sync.dart";
import "package:io_2016_contacts_demo/client/components/template_factory.dart";
import 'package:di/di.dart';

///Uses [Contact], [PaperStyles], [AppElement], [RemoteStoreSync], [TemplateFactory]
main() async {
  bootstrapMapper();
  await initPolymer();
}