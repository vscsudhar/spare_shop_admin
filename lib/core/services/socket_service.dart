import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_endpoints.dart';
import 'token_service.dart';

class SocketService {
  final TokenService _tokenService;
  IO.Socket? _socket;

  SocketService({TokenService? tokenService})
      : _tokenService = tokenService ?? locator<TokenService>();

  bool get isConnected => _socket?.connected ?? false;

  void connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await _tokenService.getAccessToken();
    _socket = IO.io(
      ApiEndpoints.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket.IO connection established');
    });

    _socket!.onDisconnect((_) {
      print('Socket.IO connection disconnected');
    });

    _socket!.onConnectError((err) {
      print('Socket.IO connection error: $err');
    });
  }

  void joinRoom(String room) {
    if (_socket == null) return;
    _socket!.emit('room:join', {'roomId': room});
  }

  void leaveRoom(String room) {
    if (_socket == null) return;
    _socket!.emit('room:leave', {'roomId': room});
  }

  void joinRequestRoom(String requestId) {
    if (_socket == null) return;
    _socket!.emit('room:join', {'roomId': 'rare-request:$requestId'});
  }

  void leaveRequestRoom(String requestId) {
    if (_socket == null) return;
    _socket!.emit('room:leave', {'roomId': 'rare-request:$requestId'});
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event, [Function(dynamic)? handler]) {
    if (handler != null) {
      _socket?.off(event, handler);
    } else {
      _socket?.off(event);
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
