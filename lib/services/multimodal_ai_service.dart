
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class MultimodalAiResult {
  final String summary;
  final List<String> tags;
  final List<String> suggestions;
  final Map<String, dynamic> metadata;

  const MultimodalAiResult({
    required this.summary,
    this.tags = const [],
    this.suggestions = const [],
    this.metadata = const {},
  });
}

/// Secure multimodal AI bridge.
///
/// The client uploads the selected image to Firebase Storage and sends only a
/// storage URL + user prompt to a trusted Cloud Function. The function should
/// perform the actual vision/model call server-side so provider secrets never
/// ship in the mobile APK.
class MultimodalAiService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<MultimodalAiResult> analyzeImage({
    required XFile image,
    String prompt = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in before using image AI.');

    final Uint8List bytes = await image.readAsBytes();
    if (bytes.isEmpty) throw StateError('The selected image is empty.');
    if (bytes.length > 12 * 1024 * 1024) {
      throw StateError('Please choose an image smaller than 12 MB.');
    }

    final extension = image.name.split('.').last.toLowerCase();
    final safeExtension = RegExp(r'^[a-z0-9]{1,5}$').hasMatch(extension)
        ? extension
        : 'jpg';
    final path = 'ai_inputs/${user.uid}/${DateTime.now().microsecondsSinceEpoch}.$safeExtension';

    final ref = _storage.ref(path);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: _contentType(safeExtension)),
    );
    final imageUrl = await ref.getDownloadURL();

    try {
      final callable = _functions.httpsCallable('analyzeSwipeBuyImage');
      final response = await callable.call({
        'imageUrl': imageUrl,
        'prompt': prompt.trim(),
      });
      final data = Map<String, dynamic>.from(response.data as Map);
      return MultimodalAiResult(
        summary: data['summary']?.toString() ?? 'SwipeBuy analyzed the image.',
        tags: _stringList(data['tags']),
        suggestions: _stringList(data['suggestions']),
        metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? const {}),
      );
    } finally {
      // Keep deletion server-controlled in production if audit/history is needed.
      // The current prototype removes temporary AI input media after analysis.
      try {
        await ref.delete();
      } catch (_) {
        debugPrint('Temporary AI input cleanup failed: $path');
      }
    }
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }
}
