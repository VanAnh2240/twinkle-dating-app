import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  // Cloudinary credentials
  static const String cloudName = 'dbqkay0fj';
  static const String apiKey = '323962626519951';
  static const String apiSecret = '3waPOs2aHf_ogVtBUx1y-w1rxcQ';
  static const String uploadPreset = 'twinkle_unsigned'; // For unsigned uploads

  /// Upload image using unsigned upload (simpler, no API secret needed on client)
  /// First, create an unsigned upload preset in Cloudinary Dashboard:
  /// Settings -> Upload -> Upload presets -> Add upload preset -> Set to "Unsigned"
  Future<String?> uploadImageUnsigned({
    required Uint8List bytes,
    required String fileName,
    String folder = 'profile_photos',
  }) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        print('Cloudinary upload success: ${jsonResponse['secure_url']}');
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary upload failed: $responseData');
        return null;
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  /// Upload image using signed upload (more secure)
  Future<String?> uploadImageSigned({
    required Uint8List bytes,
    required String fileName,
    String folder = 'profile_photos',
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Create signature
      final paramsToSign = 'folder=$folder&timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(paramsToSign)).toString();
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', uri);
      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['folder'] = folder;
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        print('Cloudinary upload success: ${jsonResponse['secure_url']}');
        return jsonResponse['secure_url'];
      } else {
        print('Cloudinary upload failed: $responseData');
        return null;
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  /// Delete image from Cloudinary
  Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final paramsToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy'),
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['result'] == 'ok';
      }
      return false;
    } catch (e) {
      print('Cloudinary delete error: $e');
      return false;
    }
  }

  /// Extract public ID from Cloudinary URL
  String? getPublicIdFromUrl(String url) {
    try {
      // URL format: https://res.cloudinary.com/{cloud_name}/image/upload/v{version}/{folder}/{public_id}.{format}
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex < pathSegments.length - 1) {
        // Get everything after 'upload' and version
        final relevantParts = pathSegments.sublist(uploadIndex + 2);
        final fullPath = relevantParts.join('/');
        // Remove file extension
        final lastDot = fullPath.lastIndexOf('.');
        if (lastDot != -1) {
          return fullPath.substring(0, lastDot);
        }
        return fullPath;
      }
      return null;
    } catch (e) {
      print('Error extracting public ID: $e');
      return null;
    }
  }
}
