import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  // Using the Cloud Name you provided: dv2wf1wbt
  static const String _cloudName = 'dv2wf1wbt'; 

  // Using the API Key you provided: 257232674364722
  static const String _apiKey = '257232674364722'; 

  // Using the API Secret you provided: j-e9JfM5oRayRDMg0KKYbWA0ZWk
  static const String _apiSecret = 'j-e9JfM5oRayRDMg0KKYbWA0ZWk'; 

  static Future<String?> uploadImage(File imageFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // String to sign: timestamp=<timestamp><api_secret>
    final stringToSign = 'timestamp=$timestamp$_apiSecret';
    final signature = sha1.convert(utf8.encode(stringToSign)).toString();

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['api_key'] = _apiKey
      ..fields['timestamp'] = timestamp.toString()
      ..fields['signature'] = signature
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'] as String;
      } else {
        print('Upload failed: ${jsonResponse['error']?['message'] ?? response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading: $e');
      return null;
    }
  }
}
