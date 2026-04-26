import 'dart:async';
import 'package:flutter/foundation.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class ConnectionInfo {
  final String id;
  final String name;
  final String? ipAddress;
  final ConnectionStatus status;
  final bool isP2P;

  ConnectionInfo({
    required this.id,
    required this.name,
    this.ipAddress,
    this.status = ConnectionStatus.disconnected,
    this.isP2P = false,
  });

  ConnectionInfo copyWith({
    String? id,
    String? name,
    String? ipAddress,
    ConnectionStatus? status,
    bool? isP2P,
  }) {
    return ConnectionInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      status: status ?? this.status,
      isP2P: isP2P ?? this.isP2P,
    );
  }
}

class ConnectionService extends ChangeNotifier {
  ConnectionInfo? _currentConnection;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _errorMessage;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;

  ConnectionInfo? get currentConnection => _currentConnection;
  ConnectionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _status == ConnectionStatus.connected;

  Future<bool> connect(String id, {String? serverAddress}) async {
    _status = ConnectionStatus.connecting;
    _errorMessage = null;
    _reconnectAttempts = 0;
    notifyListeners();

    try {
      _currentConnection = ConnectionInfo(
        id: id,
        name: 'Device $id',
        status: ConnectionStatus.connecting,
      );
      notifyListeners();

      final success = await _establishConnection(id, serverAddress: serverAddress);

      if (success) {
        _status = ConnectionStatus.connected;
        _currentConnection = _currentConnection?.copyWith(
          status: ConnectionStatus.connected,
          isP2P: true,
        );
        _startHeartbeat();
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to establish connection');
      }
    } catch (e) {
      _status = ConnectionStatus.error;
      _errorMessage = e.toString();
      _currentConnection = _currentConnection?.copyWith(
        status: ConnectionStatus.error,
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> _establishConnection(String id, {String? serverAddress}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendHeartbeat();
    });
  }

  void _sendHeartbeat() {
    if (_status == ConnectionStatus.connected) {
      debugPrint('Heartbeat sent for connection: ${_currentConnection?.id}');
    }
  }

  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _status = ConnectionStatus.disconnected;
    _currentConnection = null;
    _reconnectAttempts = 0;
    notifyListeners();
  }

  Future<void> reconnect() async {
    if (_currentConnection == null) return;

    if (_reconnectAttempts >= 5) {
      _errorMessage = 'Max reconnection attempts reached';
      notifyListeners();
      return;
    }

    _reconnectAttempts++;
    await disconnect();

    await Future.delayed(Duration(seconds: _reconnectAttempts * 2));
    await connect(_currentConnection!.id);
  }

  void updateConnectionInfo(ConnectionInfo info) {
    _currentConnection = info;
    notifyListeners();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}