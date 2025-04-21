import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String functionUrl =
      'https://predict-image-jgy4jzef3a-uc.a.run.app';

  static Future<String> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(functionUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', 
          imageFile.path,
        ),
      );

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return respStr;
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}