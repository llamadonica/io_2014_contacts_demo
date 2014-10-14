import "dart:io";

import "package:redstone/server.dart" as app;
import "package:shelf_static/shelf_static.dart";
import "package:redstone_mapper/plugin.dart";
import "package:redstone_mapper_mongo/manager.dart";
import "package:args/args.dart";

@app.Install(urlPrefix: "/services")
import "package:io_2014_contacts_demo/server/services/contact_service.dart";

main(List<String> args) {

  app.setupConsoleLog();

  //check environment variables
  var port = _getConfig("PORT", "8080");
  var dbUrl = _getConfig("MONGOHQ_URL", "mongodb://localhost/contacts");
  var supportDartium = false;
  var web;

  //configure server parameters
  var parser = new ArgParser();
  parser.addOption("port", defaultsTo: port,
      help: "The port number to use for the server");
  parser.addOption("db", defaultsTo: dbUrl,
      help: "MongoDB URL");
  parser.addFlag("dartium", defaultsTo: false,
      help: "Enable Dartium support (not safe for production environment)");
  parser.addOption("web", defaultsTo: "web",
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
  MongoDbManager dbManager = new MongoDbManager(dbUrl);
  app.addPlugin(getMapperPlugin(dbManager, "/services/.+"));

  //start the server
  app.setShelfHandler(createStaticHandler(web,
                      defaultDocument: "index.html",
                      serveFilesOutsidePath: supportDartium));
  app.start(port: int.parse(port));
}

_getConfig(String name, [defaultValue]) {
  var value = Platform.environment[name];
  if (value == null) {
    return defaultValue;
  }
  return value;
}

