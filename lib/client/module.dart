library module;

import 'package:di/di.dart';

final _module = new Module()
    ..bind(String, toValue: "Hello world!");

final injector = new ModuleInjector([_module]);