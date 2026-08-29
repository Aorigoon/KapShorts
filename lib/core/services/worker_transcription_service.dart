import 'package:dio/dio.dart';
import 'package:cross_file/cross_file.dart';

class WorkerTranscriptionException implements Exception {
  const WorkerTranscriptionException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Calls the SubReel Worker only. No Gemini credential is held by Flutter.
class WorkerTranscriptionService {
  WorkerTranscriptionService({Dio? client}) : _client = client ?? Dio();
  final Dio _client;

  Future<Map<String, dynamic>> transcribe({
    required Uri workerUri,
    required XFile video,
  }) async {
    final bytes = await video.readAsBytes();
    final form = FormData.fromMap({
      'media': MultipartFile.fromBytes(bytes, filename: video.name),
    });
    try {
      final response = await _client.post<Map<String, dynamic>>(
        workerUri.resolve('/v1/transcribe').toString(),
        data: form,
        options: Options(
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ),
      );
      final data = response.data;
      if (data == null)
        throw const WorkerTranscriptionException(
          'The caption service returned no transcription response.',
        );
      return data;
    } on DioException catch (error) {
      final payload = error.response?.data;
      final message = payload is Map
          ? payload['error'] as String?
          : payload is String && payload.isNotEmpty
          ? payload
          : null;
      final status = error.response?.statusCode;
      throw WorkerTranscriptionException(
        message ??
            (status == null
                ? 'Unable to connect to the caption service. Please check your internet connection and try again.'
                : 'Caption service request failed ($status). Please try again.'),
      );
    }
  }
}
