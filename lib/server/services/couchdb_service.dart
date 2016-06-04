library couchdb_service;

import 'dart:async';
import 'dart:convert' as dart_convert;
import 'dart:io';
import 'dart:typed_data';

import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/database.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:connection_pool/connection_pool.dart';

import 'package:shelf/shelf.dart' as shelf;
import 'package:json_stream_parser/json_stream_parser.dart';
import 'package:uuid/uuid.dart';

import 'metadata.dart';
import 'dart:convert' as convert;

class CouchError {
  final int statusCode;
  final String reason;
  final String errorCode;

  CouchError(this.statusCode, this.errorCode, this.reason);
  String toString() => "CouchError($statusCode, $errorCode, $reason)";
}

class CouchDbService<T> {
  CouchDbConnection _couchDb = null;

  ///The name of the view used to retrieve values associated with this service
  final String viewName;

  ///The name of the view used to retrieve values associated with this service
  final String designDocumentName;

  ///The MongoDB connection wrapper
  CouchDbConnection get couchDb =>
      _couchDb != null ? _couchDb : app.request.attributes["dbConn"];

  ///The MongoDb connection
  HttpClient get innerConn => couchDb.innerConn;

  ///The MongoDB collection associated with this service
  //List get collection => couchDb.view(designDocumentName, viewName);

  /**
   * Creates a new MongoDB service.
   *
   * This service will use the database connection
   * associated with the current http request.
   */
  CouchDbService(this.designDocumentName, [this.viewName = 'all']);

  /**
   * Creates a new MongoDB service, using the provided
   * MongoDB connection.
   */
  CouchDbService.fromConnection(this._couchDb, this.designDocumentName,
      [this.viewName = "all"]);

  Future<String> insert(dynamic entity, {Map<String, dynamic> extraHeaders}) =>
      couchDb.insert(entity, extraHeaders: extraHeaders);

  /**
   * Wrapper for DbCollection.find().
   *
   * [selector] can be a Map, a SelectorBuilder,
   * or an encodable object.
   */
  Future<List<T>> view(
          {dynamic startkey,
          dynamic endkey,
          dynamic key,
          List keys,
          String startkeyDocid,
          String endkeyDocid,
          int limit,
          bool staleOk: false,
          bool updateAfterStaleRead: false,
          bool descending: false,
          int skip: 0,
          bool group: false,
          int groupLevel,
          bool reduce,
          bool includeDocs: false,
          bool inclusiveEnd: true,
          bool updateSeq: false,
          bool encodeKeyValuePair: false,
          bool encodeEntireResult: false,
          Map extraHeaders}) =>
      couchDb.view(designDocumentName, viewName, T,
          startkey: startkey,
          endkey: endkey,
          key: key,
          keys: keys,
          startkeyDocid: startkeyDocid,
          endkeyDocid: endkeyDocid,
          limit: limit,
          staleOk: staleOk,
          updateAfterStaleRead: updateAfterStaleRead,
          descending: descending,
          skip: skip,
          group: group,
          groupLevel: groupLevel,
          reduce: reduce,
          includeDocs: includeDocs,
          inclusiveEnd: inclusiveEnd,
          updateSeq: updateSeq,
          encodeKeyValuePair: encodeKeyValuePair,
          encodeEntireResult: encodeEntireResult,
          extraHeaders: extraHeaders);

  Future<String> remove(String id, String rev,
          {Map<String, dynamic> extraHeaders}) =>
      couchDb.remove(id, rev, extraHeaders: extraHeaders);
}

class CouchDbServiceExperimental<T> extends CouchDbService<T> {
  ///The MongoDB connection wrapper
  CouchDbConnectionExperimental get couchDb =>
      _couchDb != null ? _couchDb : app.request.attributes["dbConn"];

  CouchDbServiceExperimental(String designDocumentName, String viewName)
      : super(designDocumentName, viewName);

  CouchDbServiceExperimental.fromConnection(
      CouchDbConnectionExperimental _couchDb, String designDocumentName,
      [String viewName = "all"])
      : super.fromConnection(_couchDb, designDocumentName, viewName);

  /**
   * Wrapper for DbCollection.find().
   *
   * [selector] can be a Map, a SelectorBuilder,
   * or an encodable object.
   */
  Future<shelf.Response> viewAsShelfResponse(
          {dynamic startkey,
          dynamic endkey,
          dynamic key,
          List keys,
          String startkeyDocid,
          String endkeyDocid,
          int limit,
          bool staleOk: false,
          bool updateAfterStaleRead: false,
          bool descending: false,
          int skip: 0,
          bool group: false,
          int groupLevel,
          bool reduce,
          bool includeDocs: false,
          bool inclusiveEnd: true,
          bool updateSeq: false,
          bool encodeKeyValuePair: false,
          bool encodeEntireResult: false,
          Map extraHeaders}) =>
      couchDb.viewAsShelfResponse(
          designDocumentName,
          viewName,
          startkey: startkey,
          endkey: endkey,
          key: key,
          keys: keys,
          startkeyDocid: startkeyDocid,
          endkeyDocid: endkeyDocid,
          limit: limit,
          staleOk: staleOk,
          updateAfterStaleRead: updateAfterStaleRead,
          descending: descending,
          skip: skip,
          group: group,
          groupLevel: groupLevel,
          reduce: reduce,
          includeDocs: includeDocs,
          inclusiveEnd: inclusiveEnd,
          updateSeq: updateSeq,
          extraHeaders: extraHeaders);

}

///Manage connections with a MongoDB instance
class CouchDbManager implements DatabaseManager<CouchDbConnection> {
  _CouchDbPool _pool;

  /**
   * Creates a new MongoDbManager
   *
   * [uri] a MongoDB uri, and [poolSize] is the number of connections
   * that will be created.
   *
   */
  CouchDbManager(String uri, {int poolSize: 3}) {
    _pool = new _CouchDbPool(uri, poolSize);
  }

  @override
  void closeConnection(CouchDbConnection connection, {error}) {
    //var invalidConn = error is ConnectionException;
    _pool.releaseConnection(connection._managedConn, markAsInvalid: false);
  }

  @override
  Future<CouchDbConnection> getConnection() {
    return _pool
        .getConnection()
        .then((managedConn) => new CouchDbConnection(managedConn, _pool.uri));
  }
}

///Manage connections with a MongoDB instance
class CouchDbManagerExperimental
    implements DatabaseManager<CouchDbConnectionExperimental> {
  _CouchDbPool _pool;

  /**
   * Creates a new MongoDbManager
   *
   * [uri] a MongoDB uri, and [poolSize] is the number of connections
   * that will be created.
   *
   */
  CouchDbManagerExperimental(String uri, {int poolSize: 3}) {
    _pool = new _CouchDbPool(uri, poolSize);
  }

  @override
  void closeConnection(CouchDbConnectionExperimental connection, {error}) {
    //var invalidConn = error is ConnectionException;
    _pool.releaseConnection(connection._managedConn, markAsInvalid: false);
  }

  @override
  Future<CouchDbConnectionExperimental> getConnection() {
    return _pool.getConnection().then((managedConn) =>
        new CouchDbConnectionExperimental(managedConn, _pool.uri));
  }
}

class CouchDbConnection {
  static const List<String> _couchPassThroughResponseHeaders = const <String>[
    'date',
    'content-length',
    'content-type',
    'cache-control',
    'date',
    'etag'
  ];
  static const List<String> _couchPassThroughRequestHeaders = const <String>[
    'if-none-match'
  ];

  final ManagedConnection<HttpClient> _managedConn;
  final String uri;

  final _jsonUtf8Encoder = new JsonUtf8Encoder();
  final _jsonUtf8Decoder = new JsonUtf8Decoder();

  HttpClient get innerConn => _managedConn.conn;

  CouchDbConnection(this._managedConn, this.uri);

  /// Get a view, and
  Future<List> view(String designDocumentName, String viewName, Type type,
      {dynamic startkey,
      dynamic endkey,
      dynamic key,
      List keys,
      String startkeyDocid,
      String endkeyDocid,
      int limit,
      bool staleOk,
      bool updateAfterStaleRead,
      bool descending,
      int skip,
      bool group,
      int groupLevel,
      bool reduce,
      bool includeDocs,
      bool inclusiveEnd,
      bool updateSeq,
      bool encodeKeyValuePair,
      bool encodeEntireResult,
      Map<String, dynamic> extraHeaders,
      bool groupByKeys: false}) async {
    final innerResponse = await _makeViewRequest(
        designDocumentName,
        viewName,
        startkey,
        endkey,
        key,
        keys,
        startkeyDocid,
        endkeyDocid,
        limit,
        staleOk,
        updateAfterStaleRead,
        descending,
        skip,
        group,
        groupLevel,
        reduce,
        includeDocs,
        inclusiveEnd,
        updateSeq,
        extraHeaders);
    final messageAsChunks = await innerResponse.toList();
    List<int> message;
    if (messageAsChunks.length == 1) {
      message = messageAsChunks[0];
    } else {
      int length = 0;
      for (var messageChunk in messageAsChunks) {
        length += messageChunk.length;
      }
      message = new Uint8List(length);
      int offset = 0;
      for (var messageChunk in messageAsChunks) {
        message.setRange(offset, offset + messageChunk.length, messageChunk);
        offset += messageChunk.length;
      }
    }
    final results = _jsonUtf8Decoder.convert(message);
    if (innerResponse.statusCode > 299) {
      throw new CouchError(
          innerResponse.statusCode, results['error'], results['reason']);
    }
    if (encodeEntireResult) {
      return _codec.decode(results, type);
    } else if (encodeKeyValuePair) {
      return _codec.decode(results['rows'], type);
    }
    return new List.from(
        results['rows']
            .map((Map result) => _codec.decode(result['value'], type)),
        growable: false);
  }

  /// Insert a new document, of whatever type.
  Future<String> insert(dynamic entity,
      {Map<String, dynamic> extraHeaders}) async {
    final HttpClientResponse innerResponse =
        await _makePutRequest(entity, extraHeaders);
    final messageAsChunks = await innerResponse.toList();
    List<int> message;
    if (messageAsChunks.length == 1) {
      message = messageAsChunks[0];
    } else {
      int length = 0;
      for (var messageChunk in messageAsChunks) {
        length += messageChunk.length;
      }
      message = new Uint8List(length);
      int offset = 0;
      for (var messageChunk in messageAsChunks) {
        message.setRange(offset, offset + messageChunk.length, messageChunk);
        offset += messageChunk.length;
      }
    }
    final results = _jsonUtf8Decoder.convert(message);
    if (innerResponse.statusCode > 299) {
      throw new CouchError(
          innerResponse.statusCode, results['error'], results['reason']);
    }
    return results['rev'];
  }

  Future save(dynamic entity, {Map<String, dynamic> extraHeaders}) {
    if (entity is! Map) {
      entity = _codec.encode(entity);
    }
    if (!entity.containsKey('_rev') || entity['_rev'] == null) {
      return new Future.error(
          new ArgumentError('Entities in CouchDB must have an rev.'));
    }
    //an insert is really the same call as a save
    return insert(entity, extraHeaders: extraHeaders);
  }

  Future<String> remove(String id, String rev,
      {Map<String, dynamic> extraHeaders}) async {
    final HttpClientResponse innerResponse =
        await _makeDeleteRequest(id, rev, extraHeaders);
    final messageAsChunks = await innerResponse.toList();
    List<int> message;
    if (messageAsChunks.length == 1) {
      message = messageAsChunks[0];
    } else {
      int length = 0;
      for (var messageChunk in messageAsChunks) {
        length += messageChunk.length;
      }
      message = new Uint8List(length);
      int offset = 0;
      for (var messageChunk in messageAsChunks) {
        message.setRange(offset, offset + messageChunk.length, messageChunk);
        offset += messageChunk.length;
      }
    }
    final results = _jsonUtf8Decoder.convert(message);
    if (innerResponse.statusCode > 299) {
      throw new CouchError(
          innerResponse.statusCode, results['error'], results['reason']);
    }
    return results['rev'];
  }

  Future<HttpClientResponse> _makePutRequest(
      dynamic entity, Map<String, dynamic> extraHeaders) async {
    final baseUri = Uri.parse(uri);
    final pathSegments = baseUri.pathSegments.toList();
    if (entity is! Map) {
      entity = _codec.encode(entity);
    }
    final id = entity['_id'];
    if (id == null) {
      throw new ArgumentError('Entities in CouchDB must have an id');
    }
    if (entity.containsKey('_rev') && entity['_rev'] == null) {
      entity.remove('_rev');
    }
    pathSegments.addAll([id]);
    final putUri = baseUri.replace(pathSegments: pathSegments);
    final List<int> payload = _jsonUtf8Encoder.convert(entity);
    final request = await innerConn.putUrl(putUri);
    if (extraHeaders != null) {
      extraHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
    }
    request.headers.add('Content-Length', payload.length);
    request.headers.add('Content-Type', 'application/json; charset=utf-8');
    request.add(payload);
    return await request.close();
  }

  Future<HttpClientResponse> _makeViewRequest(
      String designDocumentName,
      String viewName,
      startkey,
      endkey,
      key,
      List keys,
      String startkeyDocid,
      String endkeyDocid,
      int limit,
      bool staleOk,
      bool updateAfterStaleRead,
      bool descending,
      int skip,
      bool group,
      int groupLevel,
      bool reduce,
      bool includeDocs,
      bool inclusiveEnd,
      bool updateSeq,
      Map<String, dynamic> extraHeaders,
      {List<String> passThruRequestHeaders : const []}) async {
    final request = await innerConn.getUrl(_buildViewQueryUrl(
        designDocumentName, viewName,
        startkey: startkey,
        endkey: endkey,
        key: key,
        keys: keys,
        startkeyDocid: startkeyDocid,
        endkeyDocid: endkeyDocid,
        limit: limit,
        staleOk: staleOk,
        updateAfterStaleRead: updateAfterStaleRead,
        descending: descending,
        skip: skip,
        group: group,
        groupLevel: groupLevel,
        reduce: reduce,
        includeDocs: includeDocs,
        inclusiveEnd: inclusiveEnd,
        updateSeq: updateSeq));
    for (var header in passThruRequestHeaders) {
      if (app.request.headers.containsKey(header)) {
        request.headers.set(header, app.request.headers[header]);
      }
    }
    if (extraHeaders != null) {
      extraHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
    }
    final innerResponse = await request.close();
    return innerResponse;
  }

  Future<HttpClientResponse> _makeDeleteRequest(
      String id, String revision, Map<String, dynamic> extraHeaders) async {
    final baseUri = Uri.parse(uri);
    final pathSegments = baseUri.pathSegments.toList();
    pathSegments.addAll([id]);
    final putUri = baseUri.replace(pathSegments: pathSegments);
    final request = await innerConn.deleteUrl(putUri);
    if (extraHeaders != null) {
      extraHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
    }
    request.headers.add('If-Match', revision);
    final innerResponse = await request.close();
    return innerResponse;
  }

  Uri _buildViewQueryUrl(String designDocumentName, String viewName,
      {dynamic startkey,
      dynamic endkey,
      dynamic key,
      List keys,
      String startkeyDocid,
      String endkeyDocid,
      int limit,
      bool staleOk: false,
      bool updateAfterStaleRead: false,
      bool descending: false,
      int skip: 0,
      bool group: false,
      int groupLevel,
      bool reduce,
      bool includeDocs: false,
      bool inclusiveEnd: true,
      bool updateSeq: false}) {
    final baseUri = Uri.parse(uri);
    final pathSegments = baseUri.pathSegments.toList();
    pathSegments.addAll(['_design', designDocumentName, '_view', viewName]);
    final queryParameters = <String, String>{};
    if (startkey != null) {
      final startkeyJson = _encodeQueryParameterAsJson(startkey);
      queryParameters['startkey'] = startkeyJson;
    }
    if (endkey != null) {
      final endkeyJson = _encodeQueryParameterAsJson(endkey);
      queryParameters['endkey'] = endkeyJson;
    }
    if (limit != null) {
      queryParameters['limit'] = limit.toString();
    }
    if (key != null) {
      queryParameters['key'] = _encodeQueryParameterAsJson(endkey);
    }
    if (keys != null) {
      queryParameters['keys'] = jsonCodec.encode(keys);
    }
    if (startkeyDocid != null) {
      queryParameters['startkey_docid'] = startkeyDocid;
    }
    if (endkeyDocid != null) {
      queryParameters['endkey_docid'] = endkeyDocid;
    }
    if (staleOk && updateAfterStaleRead) {
      queryParameters['stale'] = 'update_after';
    } else if (staleOk) {
      queryParameters['stale'] = 'ok';
    }
    if (descending) {
      queryParameters['descending'] = 'true';
    }
    if (skip != 0) {
      queryParameters['skip'] = skip.toString();
    }
    if (group) {
      queryParameters['group'] = 'true';
    }
    if (groupLevel != null) {
      queryParameters['group_level'] = groupLevel.toString();
    }
    if (reduce != null) {
      queryParameters['reduce'] = reduce.toString();
    }
    if (includeDocs) {
      queryParameters['include_docs'] = 'true';
    }
    if (!inclusiveEnd) {
      queryParameters['inclusive_end'] = 'false';
    }
    if (updateSeq) {
      queryParameters['update_seq'] = 'true';
    }
    return baseUri.replace(
        pathSegments: pathSegments, queryParameters: queryParameters);
  }

  _encodeQueryParameterAsJson(endkey) {
    var endkeyJson;

    if (endkey is String || endkey is num) {
      endkeyJson = endkey.toString();
    } else if (endkey is DateTime) {
      endkeyJson = new Iso8601Codec().encode(endkey);
    } else {
      endkeyJson = _codec.encode(endkey);
    }
    return endkeyJson;
  }
}

class CouchDbConnectionExperimental extends CouchDbConnection {
  CouchDbConnectionExperimental(
      ManagedConnection<HttpClient> managedConn, String uri)
      : super(managedConn, uri);

  /// Insert a new row producing a shelf response.
  Future<shelf.Response> insertAsShelfResponse(dynamic entity,
      {Map<String, dynamic> extraHeaders,
      List<String> allowableHeaders:
          CouchDbConnection._couchPassThroughResponseHeaders}) async {
    final HttpClientResponse innerResponse =
        await _makePutRequest(entity, extraHeaders);
    final responseHeaders = <String, String>{};
    innerResponse.headers.forEach((key, value) {
      if (allowableHeaders.contains(key.toLowerCase()))
        responseHeaders[key] = value[0];
    });

    final body = (() async* {
      // TODO: format the response just like it needs to be formatted
      // for a proper insert statement.
      await for (var data in innerResponse) {
        yield data;
      }
    })();

    return new shelf.Response(innerResponse.statusCode,
        headers: responseHeaders, body: body);
  }

  /// Request a view, returning a shelf stream that is just as though the
  /// mapper had produced it.
  ///
  /// This allows you to pass through some extra options and take advantage
  /// of CouchDBs Etag response, but it's only suitable when you don't need to
  /// do any server side work on the response.
  Future<shelf.Response> viewAsShelfResponse(
      String designDocumentName, String viewName,
      {dynamic startkey,
      dynamic endkey,
      dynamic key,
      List keys,
      String startkeyDocid,
      String endkeyDocid,
      int limit,
      bool staleOk: false,
      bool updateAfterStaleRead: false,
      bool descending: false,
      int skip: 0,
      bool group: false,
      int groupLevel,
      bool reduce,
      bool includeDocs: false,
      bool inclusiveEnd: true,
      bool updateSeq: false,
      Map<String, dynamic> extraHeaders: const {},
      List<String> allowableHeaders: CouchDbConnection._couchPassThroughResponseHeaders,
      bool groupByKeys: false}) async {
    final bodyController = new StreamController<Uint8List>();
    final reconstitutionSink =
    _jsonUtf8Encoder.startChunkedConversion(bodyController);

    final trimSink = new _JsonListenerSink(new _JsonStreamTrimmer(reconstitutionSink));
    final conversion = _jsonUtf8Decoder.startChunkedConversion(trimSink);

    final innerResponse = await _makeViewRequest(
        designDocumentName,
        viewName,
        startkey,
        endkey,
        key,
        keys,
        startkeyDocid,
        endkeyDocid,
        limit,
        staleOk,
        updateAfterStaleRead,
        descending,
        skip,
        group,
        groupLevel,
        reduce,
        includeDocs,
        inclusiveEnd,
        updateSeq,
        extraHeaders//,
        //passThruRequestHeaders: ['if-none-match']
    );
    final responseHeaders = <String, String>{};
    innerResponse.headers.forEach((key, value) {
      if (allowableHeaders.contains(key.toLowerCase()))
        responseHeaders[key] = value[0];
    });
    innerResponse.listen((chunk) => conversion.add(chunk),
        onDone: () => conversion.close(),
        onError: (error, stacktrace) =>
            bodyController.addError(error, stacktrace));
    return new shelf.Response(innerResponse.statusCode,
        headers: responseHeaders, body: bodyController.stream);
  }
}

class _JsonListenerSink extends JsonListenerSink {
  final _FilteringJsonListener _target;
  _JsonListenerSink(_FilteringJsonListener target) :
    super(target),
    _target = target;

  @override
  void add(List<JsonListenerEvent> data) {
    super.add(data);
    _target.flushStream();
  }

  @override
  void close() {
    _target.close();
  }
}

abstract class _FilteringJsonListener extends JsonListener {
  void flushStream();
  void close();
}

class _JsonStreamTrimmer extends _FilteringJsonListener {
  static const int _BEFORE_ROWS = 0;
  static const int _BEFORE_ROWS_CHECK_KEY = 1;
  static const int _BEFORE_ROWS_SKIP_VALUE = 2;
  static const int _ROW_BEFORE_VALUE = 3;
  static const int _ROW_AFTER_VALUE = 4;
  static const int _BEFORE_ROW_BEGIN_ARRAY = 5;
  static const int _AFTER_ROWS = 6;
  static const int _IN_ROW_SKIP_VALUE = 7;
  static const int _IN_ROW_BEFORE_VALUE_OBJECT = 8;
  static const int _BETWEEN_ROWS = 9;

  static const int _ROW_BEGIN_ARRAY = 17;
  static const int _COMMA_BETWEEN_ROWS = 18;
  static const int _ROW_VALUE = 19;

  static const int _ROW_END_ARRAY = 21;


  final convert.ChunkedConversionSink<List<JsonListenerEvent>> _sink;
  int _level = 0;
  int _phase = _BEFORE_ROWS;
  List<JsonListenerEvent> _queuedEvents = [];

  _JsonStreamTrimmer(this._sink);

  void flushStream() {
    _sink.add(_queuedEvents);
    _queuedEvents = [];
  }

  void emit(JsonListenerEvent event) {
    _queuedEvents.add(event);
  }

  @override beginArray({JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
    _level += 1;
    if (_phase == _ROW_BEGIN_ARRAY) {
      _phase = _ROW_BEFORE_VALUE;
    }
  }

  @override endArray({JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
    _level -= 1;
    if (_phase == _ROW_BEFORE_VALUE && _level == 1) {
      emit(event);
      _phase = _AFTER_ROWS;
    }
  }

  @override beginObject({JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
    _level += 1;
    if (_phase == _BEFORE_ROWS && _level == 1) {
      _phase = _BEFORE_ROWS_CHECK_KEY;
    }
  }

  @override endObject({JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
    _level -= 1;
    if (_phase == _BETWEEN_ROWS) {
      _phase = _COMMA_BETWEEN_ROWS;
    } else if (_phase == _ROW_VALUE && _level == 3) {
      _phase = _BETWEEN_ROWS;
    }
  }

  @override arrayElement({JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
    if (_phase == _COMMA_BETWEEN_ROWS) {
      _phase = _ROW_BEFORE_VALUE;
    }
  }

  @override handleString(String key, {JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
    if (_phase == _BEFORE_ROWS_CHECK_KEY && key == 'rows') {
      _phase = _BEFORE_ROW_BEGIN_ARRAY;
    } else if (_phase == _BEFORE_ROWS_CHECK_KEY) {
      _phase = _BEFORE_ROWS_SKIP_VALUE;
    } else if (_phase == _ROW_BEFORE_VALUE && key == 'value') {
      _phase = _IN_ROW_BEFORE_VALUE_OBJECT;
    } else if (_phase == _ROW_BEFORE_VALUE) {
      _phase = _IN_ROW_SKIP_VALUE;
    }
  }

  @override handleNull({JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
  }

  @override handleBool(bool value, {JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
  }

  @override handleNumber(num value, {JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
  }

  @override propertyName({JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
    if (_phase == _BEFORE_ROW_BEGIN_ARRAY) {
      _phase = _ROW_BEGIN_ARRAY;
    } else if (_phase == _IN_ROW_BEFORE_VALUE_OBJECT) {
      _phase = _ROW_VALUE;
    }
  }
  @override propertyValue({JsonListenerEvent event}) {
    if (_phase >= 16) emit(event);
    if (_phase == _BEFORE_ROWS_SKIP_VALUE && _level == 1) {
      _phase = _BEFORE_ROWS_CHECK_KEY;
    } else if (_phase == _IN_ROW_SKIP_VALUE && _level == 3) {
      _phase = _ROW_BEFORE_VALUE;
    }
  }

  void close() => _sink.close();
}

class _CouchDbPool extends ConnectionPool<HttpClient> {
  String uri;

  _CouchDbPool(String this.uri, int poolSize) : super(poolSize);

  @override
  void closeConnection(HttpClient conn) {
    conn.close();
  }

  @override
  Future<HttpClient> openNewConnection() async {
    var conn = new HttpClient();
    //We don't need to open until we make the actual request.
    return conn;
  }
}

GenericTypeCodec _codec = new GenericTypeCodec(
    fieldDecoder: _fieldDecoder, fieldEncoder: _fieldEncoder);

GenericTypeCodec _updtCodec =
    new GenericTypeCodec(fieldEncoder: _updtFieldEncoder);

FieldDecoder _fieldDecoder =
    (Object data, String fieldName, Field fieldInfo, List metadata) {
  String name = fieldInfo.model;
  if (name == null) {
    name = fieldName;
  }
  var value = (data as Map)[name];
  return value;
};

FieldEncoder _fieldEncoder =
    (Map data, String fieldName, Field fieldInfo, List metadata, Object value) {
  String name = fieldInfo.model;
  if (name == null) {
    name = fieldName;
  }
  // Id and rev don't need to be handled specially.
  data[name] = value;
};

FieldEncoder _updtFieldEncoder =
    (Map data, String fieldName, Field fieldInfo, List metadata, Object value) {
  if (value == null) {
    return;
  }
  String name = fieldInfo.model;
  if (name == null) {
    name = fieldName;
  }
  Map set = data[r'$set'];
  if (set == null) {
    set = {};
    data[r'$set'] = set;
  }
  if (value is Map) {
    (value[r"$set"] as Map).forEach((k, v) {
      set["${name}.${k}"] = v;
    });
  } else {
    set[name] = value;
  }
};

typedef void AddFunc<T>(T data);
typedef void CloseFunc();

class FuncSink<T> extends Sink<T> {
  final AddFunc<T> _add;
  final CloseFunc _close;

  FuncSink(this._add, {CloseFunc onClose: _defaultClose}) : _close = onClose;

  static void _defaultClose() {}

  @override
  void add(T data) => _add(data);

  @override
  void close() => _close();
}
