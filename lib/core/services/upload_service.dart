import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'api_client.dart';

class UploadService {
  final ApiClient _apiClient;

  UploadService({ApiClient? apiClient})
      : _apiClient = apiClient ?? locator<ApiClient>();

  Future<List<String>> uploadImages(String requestId, List<XFile> files) async {
    if (files.isEmpty) return [];

    final formData = FormData();
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: file.name,
      );
      formData.files.add(MapEntry('images', multipartFile));
    }

    final response = await _apiClient.post('/rare-requests/$requestId/images',
        data: formData);
    final List<dynamic> urls = response.data['data']?['images'] ?? [];
    return urls.cast<String>();
  }

  Future<String> uploadLogo(dynamic file) async {
    final formData = FormData();
    MultipartFile multipartFile;
    if (file is XFile) {
      final bytes = await file.readAsBytes();
      multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
    } else {
      multipartFile = MultipartFile.fromBytes([], filename: 'logo.png');
    }
    formData.files.add(MapEntry('logo', multipartFile));

    final response = await _apiClient.post('/settings/logo', data: formData);
    return response.data['data']?['logo'] ?? '';
  }
}
