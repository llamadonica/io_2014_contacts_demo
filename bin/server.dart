import "package:redstone/server.dart" as app;
import "package:shelf_static/shelf_static.dart";
import "package:redstone_mapper/plugin.dart";
import "package:redstone_mapper_mongo/manager.dart";

@app.Install(urlPrefix: "/services")
import "package:io_2014_contacts_demo/server/services/contact_service.dart";

main() {

  app.setupConsoleLog();

  MongoDbManager dbManager = new MongoDbManager("mongodb://localhost/contacts");
  app.addPlugin(getMapperPlugin(dbManager, "/services/.+"));

  app.setShelfHandler(createStaticHandler("web",
                      defaultDocument: "index.html",
                      serveFilesOutsidePath: true));
  app.start();
}