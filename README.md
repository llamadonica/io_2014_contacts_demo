This example is a fork of the [io_2014_contacts_demo](https://github.com/kevmoo/io_2014_contacts_demo) sample, modified to use the 
[Redstone.dart](http://redstonedart.org) framework and plugins. Instead of saving the data in the
user's browser, this sample uses a webservice built with Redstone, which store the data in a MongoDb instance.

### Building and running the application

Before running this example, be sure to have a [MongoDB](http://www.mongodb.org/) instance available in your environment. 
By default, the application will try to connect to a local MongoDB instance, and create/use a database named 
"contacts". Take a look at the `bin/server.dart` file to change these settings.

If you are using Ubuntu, or other Debian based linux distribution, you can just do the following to install MongoDB:

```
$ sudo apt-get install mongodb
```

You can clone this repository using the git tool, or download it as 
a [zip file](https://github.com/luizmineo/io_2014_contacts_demo/archive/master.zip)

```
$ git clone https://github.com/luizmineo/io_2014_contacts_demo.git
```

To build the code, use the `pub run` command to invoke the [Grinder](https://pub.dartlang.org/packages/grinder) build system:

```
$ pub run grinder:grind all
```

It will invoke the `tool/grind.dart` script, which will produce a `build` directory that can be deployed on your server. To test it, you can execute 
the `bin/server.dart` script from the `build` folder:
 
```
$ cd build
$ dart bin/server.dart
```
 
Now open your browser and go to http://localhost:8080/
 
### Opening in Dart Editor
 
To import this application in [Dart Editor](https://www.dartlang.org/tools/editor/), 
go to `File -> Open Existing Folder...` and select the project folder.

To run it, you need to create two launch configurations: One to the server, and another to start the client in Dartium. 

Go to `Run -> Manage Launches`.

To create the server launcher:

* Create a new command-line launch
* Set *Dart Script* to *bin/server.dart*
* Set *Working Directory* to the project path
* Click on the *Apply* button

To create the client launcher:

* Create a new Dartium launch
* Change *Launch Target* to *URL*
* Set *URL* to *http://localhost:8080*
* Set *Source Location* to the project path
* Uncheck the *Use pub serve to serve the application* option
* Click on the *Apply* button

To test the application, start the server, and then the client.
