import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OfflineOpType { createDonation, createRequest }

class OfflineOperation {
  final OfflineOpType type;
  final Map<String, dynamic> payload;
  final int timestampMs;

  OfflineOperation({required this.type, required this.payload, required this.timestampMs});

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'payload': payload,
        'ts': timestampMs,
      };

  static OfflineOperation fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      type: OfflineOpType.values.firstWhere((e) => e.name == json['type']),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      timestampMs: json['ts'] as int,
    );
  }
}

class OfflineQueueService {
  static const String _queueKey = 'offline_queue_v1';
  static bool _listening = false;

  static Future<List<OfflineOperation>> _readQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null) return [];
    try {
      final List list = jsonDecode(raw);
      return list.map((e) => OfflineOperation.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint('Failed to decode offline queue: $e');
      return [];
    }
  }

  static Future<void> _writeQueue(List<OfflineOperation> ops) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_queueKey, jsonEncode(ops.map((e) => e.toJson()).toList()));
  }

  static Future<void> enqueue(OfflineOperation op) async {
    final ops = await _readQueue();
    ops.add(op);
    await _writeQueue(ops);
  }

  static Future<void> removeFirst() async {
    final ops = await _readQueue();
    if (ops.isEmpty) return;
    ops.removeAt(0);
    await _writeQueue(ops);
  }

  static Future<List<OfflineOperation>> peekAll() => _readQueue();

  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static void ensureConnectivityListener(Future<bool> Function(OfflineOperation) onProcess) {
    if (_listening) return;
    _listening = true;
    Connectivity().onConnectivityChanged.listen((_) async {
      final online = await isOnline();
      if (online) {
        await drainQueue(onProcess);
      }
    });
  }

  static Future<void> drainQueue(Future<bool> Function(OfflineOperation) onProcess) async {
    var ops = await _readQueue();
    while (ops.isNotEmpty) {
      final ok = await onProcess(ops.first);
      if (!ok) break;
      await removeFirst();
      ops = await _readQueue();
    }
  }
}


