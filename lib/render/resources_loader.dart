import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/sprite.dart' as flame;

import 'package:flutter/services.dart';

typedef IOResourceLoadedCB = void Function(String);

enum IOResourceStatus { REQUESTED, LOADED }
enum IOResourceType { TEXT, IMAGE, SPRITE }

class IOResource {
  IOResourceType type = IOResourceType.IMAGE;
  IOResourceStatus status = IOResourceStatus.REQUESTED;
  ui.Image image;
  flame.Sprite sprite;
  String text;
}

class IOResourcesLoader {
  var _loaded = false;
  var _bundle = rootBundle;

  Map<String, IOResource> loadedResources = {};

  bool get loaded {
    if (!_loaded) {
      _checkStatus();
    }
    return _loaded;
  }

  void clear(String fileName) {
    loadedResources.remove(fileName);
  }

  void clearCache() {
    loadedResources.clear();
  }

  Future<IOResource> loadTexture(String fileName,
      [IOResourceLoadedCB cb]) async {
    if (!loadedResources.containsKey(fileName)) {
      _loaded = false;
      var rsc = IOResource();
      loadedResources[fileName] = rsc;
      loadedResources[fileName].image =
          await _fetchToMemory('images', fileName);
      loadedResources[fileName].status = IOResourceStatus.LOADED;
      _checkStatus();
      if (cb != null) {
        cb(fileName);
      }
    }
    return loadedResources[fileName];
  }

  Future<IOResource> loadSprite(String fileName,
      [IOResourceLoadedCB cb]) async {
    if (!loadedResources.containsKey(fileName)) {
      _loaded = false;
      var rsc = IOResource();
      loadedResources[fileName] = rsc;
      loadedResources[fileName].sprite =
          await flame.Sprite.loadSprite(fileName);
      loadedResources[fileName].type = IOResourceType.SPRITE;
      loadedResources[fileName].status = IOResourceStatus.LOADED;
      _checkStatus();
      if (cb != null) {
        cb(fileName);
      }
    }
    return loadedResources[fileName];
  }

  Future<IOResource> loadText(String fileName, [IOResourceLoadedCB cb]) async {
    if (!loadedResources.containsKey(fileName)) {
      _loaded = false;
      var rsc = IOResource();
      loadedResources[fileName] = rsc;
      loadedResources[fileName].text = await _fetchTextToMemory(fileName);
      loadedResources[fileName].type = IOResourceType.TEXT;
      loadedResources[fileName].status = IOResourceStatus.LOADED;
      _checkStatus();
      if (cb != null) {
        cb(fileName);
      }
    }
    return loadedResources[fileName];
  }

  Future<ui.Image> _fetchToMemory(String prefix, String name) async {
    final ByteData data = await _bundle.load('assets/$prefix/$name');
    final Uint8List bytes = Uint8List.view(data.buffer);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (image) => completer.complete(image));
    return completer.future;
  }

  Future<String> _fetchTextToMemory(String name) async {
    return _bundle.loadString('assets/$name');
  }

  _checkStatus() {
    for (var v in loadedResources.values) {
      if (v.status == IOResourceStatus.LOADED) continue;
      _loaded = false;
      return;
    }
    _loaded = true;
  }
}
