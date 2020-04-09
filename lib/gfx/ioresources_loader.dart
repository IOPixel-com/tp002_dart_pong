import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/sprite.dart' as flame;

import 'package:flutter/services.dart';

typedef IOResourceLoadedCB = void Function(String, dynamic);

enum IOResourceStatus { REQUESTED, LOADED }
enum IOResourceType { TEXT, IMAGE, SPRITE }

class IOResource {
  IOResourceType type;
  IOResourceStatus status;
  dynamic content;

  IOResource(this.type) : status = IOResourceStatus.REQUESTED;
}

class IOResourceRequest {
  IOResourceType type;
  String resourceName;
  IOResourceLoadedCB cb;

  IOResourceRequest(this.resourceName, this.type, [this.cb]);
}

class IOResourcesLoader {
  var _mutex = false;
  var _loaded = false;
  var _bundle = rootBundle;

  var requests = List<IOResourceRequest>();
  var newRequests = List<IOResourceRequest>();

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

  void update() {
    if (_mutex) return;
    _mutex = true;
    _update();
  }

  void _update() async {
    var requestsNotCompleted = List<IOResourceRequest>();
    // loop over requests
    requests.addAll(newRequests);
    newRequests.clear();
    for (var req in requests) {
      // look into resources
      var rsc = loadedResources[req.resourceName];
      if (rsc != null && rsc.status == IOResourceStatus.LOADED) {
        req.cb(req.resourceName, rsc.content);
      } else if (rsc != null) {
        requestsNotCompleted.add(req);
      } else {
        // create a resource
        var rsc = IOResource(req.type);
        loadedResources[req.resourceName] = rsc;
        requestsNotCompleted.add(req);
      }
    }
    requests = requestsNotCompleted;
    // load resources
    for (var entry in loadedResources.entries) {
      if (entry.value.status != IOResourceStatus.LOADED) {
        // load rsc
        if (entry.value.type == IOResourceType.TEXT) {
          entry.value.content = await _fetchTextToMemory(entry.key);
          entry.value.status = IOResourceStatus.LOADED;
        } else if (entry.value.type == IOResourceType.SPRITE) {
          entry.value.content = await flame.Sprite.loadSprite(entry.key);
          entry.value.status = IOResourceStatus.LOADED;
        } else if (entry.value.type == IOResourceType.IMAGE) {
          entry.value.content = await _fetchToMemory('images', entry.key);
          entry.value.status = IOResourceStatus.LOADED;
        }
      }
    }
    _mutex = false;
  }

  void requestImage(String filename, [IOResourceLoadedCB cb]) {
    newRequests.add(IOResourceRequest(filename, IOResourceType.IMAGE, cb));
  }

  void requestSprite(String filename, [IOResourceLoadedCB cb]) {
    newRequests.add(IOResourceRequest(filename, IOResourceType.SPRITE, cb));
  }

  void requestText(String filename, [IOResourceLoadedCB cb]) {
    newRequests.add(IOResourceRequest(filename, IOResourceType.TEXT, cb));
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
    if (newRequests.length > 0 || requests.length > 0) {
      return false;
    }
    for (var v in loadedResources.values) {
      if (v.status == IOResourceStatus.LOADED) continue;
      _loaded = false;
      return;
    }
    _loaded = true;
  }
}
