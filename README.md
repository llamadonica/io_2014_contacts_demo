This example is a fork of the [io_2014_contacts_demo](https://github.com/kevmoo/io_2014_contacts_demo) sample, modified to use the 
[Redstone.dart](http://redstonedart.org) framework and plugins. Instead of saving the data in the
user's browser, this sample uses a webservice built with Redstone, which store the data in a MongoDb instance.

### Building and running the application

Before running this example, be sure to have a [MongoDB](http://www.mongodb.org/) instance available in your environment. 
By default, the application will try to connect to a local MongoDB instance, and create/use a database named 
"contacts".

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

**Note:** The server accepts some configuration parameters. Run `dart bin/server.dart --help` for details.
 
Now open your browser and go to [http://localhost:8080/](http://localhost:8080/)
 
### Opening in Dart Editor
 
To import this application in [Dart Editor](https://www.dartlang.org/tools/editor/), 
go to `File -> Open Existing Folder...` and select the project folder.

To run it, you need to create two launch configurations: One to the server, and another to start the client in Dartium. 

Go to `Run -> Manage Launches`.

To create the server launcher:

* Create a new command-line launch
* Set *Dart Script* to *bin/server.dart*
* Set *Working Directory* to the project path
* Set *Script arguments* to *--dartium*
* Click on the *Apply* button

To create the client launcher:

* Create a new Dartium launch
* Change *Launch Target* to *URL*
* Set *URL* to *http://localhost:8080*
* Set *Source Location* to the project path
* Uncheck the *Use pub serve to serve the application* option
* Click on the *Apply* button

To test the application, start the server, and then the client.

## Deploying to Heroku

This application can easily be deployed to [Heroku](https://www.heroku.com/), using the new 
[cedar-14](https://blog.heroku.com/archives/2014/8/19/cedar-14-public-beta) stack, 
and the [Dart buildpack](https://github.com/igrigorik/heroku-buildpack-dart).

If you already have the [Heroku Toolbelt](https://toolbelt.heroku.com/) installed, just run the following commands
from the application root folder.

Create a Heroku application:

```
$ heroku create -s cedar-14
```

Configure a Dart SDK archive. The following link points to Dart SDK 1.7-dev.4.5, but you can get another version 
[here](https://www.dartlang.org/tools/download_archive/) (be sure to get a Linux 64-bit build):

```
$ heroku config:set DART_SDK_URL=https://storage.googleapis.com/dart-archive/channels/dev/release/41004/sdk/dartsdk-linux-x64-release.zip
```

Configure the Dart buildpack:

```
$ heroku config:add BUILDPACK_URL=https://github.com/igrigorik/heroku-buildpack-dart.git
```

Add a MongoDB database, with the [MongoHQ add-on](https://addons.heroku.com/mongohq):

```
$ heroku addons:add mongohq
```

And finally, push the application to Heroku:

```
$ git push heroku master
```

Heroku will build the application with `pub build`, and start the server with the command specified
in the [[Procfile]] file.