import 'package:dio/dio.dart';

class NetworkInfoService {
  Future<bool> get isConnected async {
    try {
      final dio = Dio();
      final response = await dio
          .get('https://www.google.com')
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
