class VideoProject {
  const VideoProject({
    required this.id,
    required this.name,
    required this.videoPath,
    required this.createdAt,
    this.duration = 'Ready to caption',
    this.template = 'Warm Stage',
    this.transcription,
    this.audioPath,
  });

  final String id;
  final String name;
  final String videoPath;
  final DateTime createdAt;
  final String duration;
  final String template;
  final Map<String, dynamic>? transcription;
  final String? audioPath;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'videoPath': videoPath,
    'createdAt': createdAt.toIso8601String(),
    'duration': duration,
    'template': template,
    'transcription': transcription,
    'audioPath': audioPath,
  };

  factory VideoProject.fromJson(Map<String, dynamic> json) => VideoProject(
    id: json['id'] as String,
    name: json['name'] as String,
    videoPath: json['videoPath'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    duration: json['duration'] as String? ?? 'Ready to caption',
    template: json['template'] as String? ?? 'Blink Pop',
    transcription: json['transcription'] is Map
        ? Map<String, dynamic>.from(json['transcription'] as Map)
        : null,
    audioPath: json['audioPath'] as String?,
  );

  VideoProject copyWith({
    String? name,
    String? videoPath,
    String? template,
    Map<String, dynamic>? transcription,
    String? audioPath,
  }) => VideoProject(
    id: id,
    name: name ?? this.name,
    videoPath: videoPath ?? this.videoPath,
    createdAt: createdAt,
    duration: duration,
    template: template ?? this.template,
    transcription: transcription ?? this.transcription,
    audioPath: audioPath ?? this.audioPath,
  );
}
