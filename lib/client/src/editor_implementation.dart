library contacts.editor_implementation;

import 'dart:async';

import 'package:polymer/polymer.dart';

abstract class EditorImplementation<T> implements PolymerElement {
  T get value;
  void set value(T newValue);
  Stream<T> get onValueChanged;
}