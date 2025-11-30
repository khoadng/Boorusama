// Dart imports:
import 'dart:async';
import 'dart:js_interop';

// Package imports:
import 'package:web/web.dart' as web;

class IndexedDbStore {
  IndexedDbStore({
    required this.dbName,
    required this.storeName,
    this.version = 1,
  });

  final String dbName;
  final String storeName;
  final int version;

  web.IDBDatabase? _db;

  Future<void> initialize({
    List<IndexConfig>? indexes,
    bool autoIncrement = true,
  }) async {
    final request = web.window.indexedDB.open(dbName, version);

    request.onupgradeneeded = (web.IDBVersionChangeEvent event) {
      if (event.target case final web.IDBOpenDBRequest target) {
        if (target.result case final web.IDBDatabase db) {
          if (!db.objectStoreNames.contains(storeName)) {
            final objectStore = db.createObjectStore(
              storeName,
              web.IDBObjectStoreParameters(autoIncrement: autoIncrement),
            );

            if (indexes != null) {
              for (final index in indexes) {
                objectStore.createIndex(
                  index.name,
                  index.keyPath.length == 1
                      ? index.keyPath.first.toJS
                      : index.keyPath.map((k) => k.toJS).toList().toJS,
                  web.IDBIndexParameters(unique: index.unique),
                );
              }
            }
          }
        }
      }
    }.toJS;

    _db = await _promiseToFuture<web.IDBDatabase>(request);
  }

  JSAny _toJsKey(Object key) => switch (key) {
    final List list => list.map((e) => e.toString().toJS).toList().toJS,
    _ => key.toString().toJS,
  };

  Future<Map<Object?, Object?>?> get(Object key) async {
    if (_db == null) return null;

    final transaction = _db!.transaction(storeName.toJS, 'readonly');
    final objectStore = transaction.objectStore(storeName);
    final request = objectStore.get(_toJsKey(key));

    final result = await _promiseToFuture<JSAny?>(request);
    return result.dartify() as Map<Object?, Object?>?;
  }

  /// Get a value by index.
  Future<Map<Object?, Object?>?> getByIndex(
    String indexName,
    Object key,
  ) async {
    if (_db == null) return null;

    final transaction = _db!.transaction(storeName.toJS, 'readonly');
    final objectStore = transaction.objectStore(storeName);
    final index = objectStore.index(indexName);
    final request = index.get(_toJsKey(key));

    final result = await _promiseToFuture<JSAny?>(request);
    return result.dartify() as Map<Object?, Object?>?;
  }

  /// Get all values from the store, optionally sorted by an index.
  Future<List<Map<Object?, Object?>>> getAll({
    String? indexName,
    String direction = 'next',
  }) async {
    if (_db == null) return [];

    final transaction = _db!.transaction(storeName.toJS, 'readonly');
    final objectStore = transaction.objectStore(storeName);

    final web.IDBRequest request;
    if (indexName != null) {
      final index = objectStore.index(indexName);
      request = index.openCursor(null, direction);
    } else {
      request = objectStore.openCursor(null, direction);
    }

    final items = <Map<Object?, Object?>>[];
    await for (final cursor in _cursorStream(request)) {
      if (cursor.value.dartify() case final Map<Object?, Object?> value) {
        items.add(value);
      }
    }

    return items;
  }

  /// Add a new value to the store.
  Future<void> add(Map<String, Object> value) async {
    if (_db == null) return;

    final transaction = _db!.transaction(storeName.toJS, 'readwrite');
    final objectStore = transaction.objectStore(storeName);
    objectStore.add(value.jsify());

    await _transactionComplete(transaction);
  }

  /// Update an existing value in the store.
  Future<void> put(Map<String, Object> value, Object key) async {
    if (_db == null) return;

    final transaction = _db!.transaction(storeName.toJS, 'readwrite');
    final objectStore = transaction.objectStore(storeName);
    objectStore.put(value.jsify(), _toJsKey(key));

    await _transactionComplete(transaction);
  }

  /// Delete a value by key.
  Future<void> delete(Object key) async {
    if (_db == null) return;

    final transaction = _db!.transaction(storeName.toJS, 'readwrite');
    final objectStore = transaction.objectStore(storeName);
    objectStore.delete(_toJsKey(key));

    await _transactionComplete(transaction);
  }

  /// Clear all values from the store.
  Future<void> clear() async {
    if (_db == null) return;

    final transaction = _db!.transaction(storeName.toJS, 'readwrite');
    final objectStore = transaction.objectStore(storeName);
    objectStore.clear();

    await _transactionComplete(transaction);
  }

  /// Find the primary key for a value using an index.
  Future<Object?> findKey(String indexName, Object indexKey) async {
    if (_db == null) return null;

    final transaction = _db!.transaction(storeName.toJS, 'readonly');
    final objectStore = transaction.objectStore(storeName);
    final index = objectStore.index(indexName);
    final request = index.openCursor(_toJsKey(indexKey));

    final cursor = await _waitForCursor(request);
    return cursor?.primaryKey;
  }

  Future<T> _promiseToFuture<T extends JSAny?>(web.IDBRequest request) {
    final completer = Completer<T>();

    request.onsuccess = (web.Event event) {
      if (event.target case final web.IDBRequest target) {
        if (target.result case final T result) {
          completer.complete(result);
        }
      }
    }.toJS;

    request.onerror = (web.Event event) {
      final error = switch (event.target) {
        final web.IDBRequest target => target.error,
        _ => null,
      };
      completer.completeError(Exception('IndexedDB error: $error'));
    }.toJS;

    return completer.future;
  }

  Stream<web.IDBCursorWithValue> _cursorStream(web.IDBRequest request) async* {
    while (true) {
      final cursor = await _waitForCursor(request);
      if (cursor == null) break;
      yield cursor;
      cursor.continue_();
    }
  }

  Future<web.IDBCursorWithValue?> _waitForCursor(web.IDBRequest request) {
    final completer = Completer<web.IDBCursorWithValue?>();

    request.onsuccess = (web.Event event) {
      if (!completer.isCompleted) {
        final cursor = switch (event.target) {
          final web.IDBRequest target =>
            target.result as web.IDBCursorWithValue?,
          _ => null,
        };
        completer.complete(cursor);
      }
    }.toJS;

    request.onerror = (web.Event event) {
      if (!completer.isCompleted) {
        final error = switch (event.target) {
          final web.IDBRequest target => target.error,
          _ => null,
        };
        completer.completeError(Exception('Cursor error: $error'));
      }
    }.toJS;

    return completer.future;
  }

  Future<void> _transactionComplete(web.IDBTransaction transaction) {
    final completer = Completer<void>();

    transaction.oncomplete = (web.Event event) {
      completer.complete();
    }.toJS;

    transaction.onerror = (web.Event event) {
      completer.completeError(
        Exception('Transaction error: ${transaction.error}'),
      );
    }.toJS;

    return completer.future;
  }
}

class IndexConfig {
  const IndexConfig({
    required this.name,
    required this.keyPath,
    this.unique = false,
  });

  final String name;
  final List<String> keyPath;
  final bool unique;
}
