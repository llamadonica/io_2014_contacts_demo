import "dart:io";

import "package:redstone/redstone.dart" as app;
import "package:shelf_static/shelf_static.dart";
import "package:redstone_mapper/plugin.dart";
import 'package:io_2016_contacts_demo/server/services/couchdb_service.dart';
import "package:args/args.dart";

@app.Install(urlPrefix: "/services")
import "package:io_2016_contacts_demo/server/services/contact_service.dart";

main(List<String> args) {

  app.setupConsoleLog();

  //check environment variables
  var port = _getConfig("PORT", "8080");
  var dbUrl = _getConfig("MONGOHQ_URL", "http://localhost:5984/contacts");
  var web = _getConfig("WEB_FOLDER", "build/web");
  var supportDartium = _getConfig("SUPPORT_DARTIUM", "false");

  //configure server parameters
  var parser = new ArgParser();
  parser.addOption("port", defaultsTo: port,
      help: "The port number to use for the server");
  parser.addOption("db", defaultsTo: dbUrl,
      help: "MongoDB URL");
  parser.addFlag("dartium", defaultsTo: supportDartium == "true",
      help: "Enable Dartium support (not safe for production environment)");
  parser.addOption("web", defaultsTo: web,
      help: "Path to the web folder");
  parser.addFlag("help", negatable: false, defaultsTo: false, hide: true);

  var results = parser.parse(args);

  if (results["help"]) {
    print(parser.getUsage());
    return;
  }

  //check server parameters
  port = results["port"];
  dbUrl = results["db"];
  supportDartium = results["dartium"];
  web = results["web"];

  //start the database manager
  CouchDbManagerExperimental dbManager = new CouchDbManagerExperimental(dbUrl);
  app.addPlugin(getMapperPlugin(dbManager, "/services/.+"));

  //start the server
  app.setShelfHandler(createStaticHandler(web,
                      defaultDocument: "index.html",
                      serveFilesOutsidePath: true));
  app.start(port: int.parse(port));
}

_getConfig(String name, [defaultValue]) {
  var value = Platform.environment[name];
  if (value == null) {
    return defaultValue;
  }
  return value;
}
