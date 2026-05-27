import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName = 'dkmaatyg8';
  static const String _uploadPreset = 'moises';

  static Future<String?> uploadFile(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['secure_url'] != null) {
        return data['secure_url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> uploadFromUrl(String imageUrl) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final response = await http
          .post(uri, body: {'upload_preset': _uploadPreset, 'file': imageUrl})
          .timeout(const Duration(seconds: 30));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['secure_url'] != null) {
        return data['secure_url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<XFile?> pickFromGallery() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    return xfile;
  }
}
