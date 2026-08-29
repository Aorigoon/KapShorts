import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/video_project.dart';

class ProjectsController extends ChangeNotifier {
  static const _storageKey = 'subreel_projects_v1';
  List<VideoProject> _projects = [];
  String? _selectedId;
  bool _loaded = false;

  List<VideoProject> get projects => List.unmodifiable(_projects);
  bool get loaded => _loaded;
  VideoProject? get selected => _projects
      .where((item) => item.id == _selectedId)
      .cast<VideoProject?>()
      .firstOrNull;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final items = jsonDecode(raw) as List<dynamic>;
        _projects =
            items
                .map(
                  (item) => VideoProject.fromJson(item as Map<String, dynamic>),
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (_) {
        _projects = [];
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> addVideo({required String name, required String path}) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final savedPath = await _importVideoFile(id, path);
    final project = VideoProject(
      id: id,
      name: name.replaceFirst(RegExp(r'\.[^.]+$'), ''),
      videoPath: savedPath,
      createdAt: DateTime.now(),
    );
    _projects = [project, ..._projects];
    _selectedId = project.id;
    await _persist();
    notifyListeners();
  }

  Future<String> _importVideoFile(String id, String sourcePath) async {
    if (kIsWeb ||
        sourcePath.startsWith('blob:') ||
        sourcePath.startsWith('data:')) {
      return sourcePath;
    }
    final source = File(sourcePath);
    if (!source.existsSync()) return sourcePath;
    final library = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/subreel/videos',
    );
    await library.create(recursive: true);
    final extension = sourcePath.contains('.')
        ? sourcePath.substring(sourcePath.lastIndexOf('.'))
        : '.mp4';
    final imported = File('${library.path}/$id$extension');
    await source.copy(imported.path);
    return imported.path;
  }

  Future<void> select(VideoProject project) async {
    _selectedId = project.id;
    notifyListeners();
  }

  Future<void> updateTemplate(String template) async {
    final index = _projects.indexWhere((project) => project.id == _selectedId);
    if (index == -1) return;
    _projects[index] = _projects[index].copyWith(template: template);
    await _persist();
    notifyListeners();
  }

  Future<void> saveTranscript(Map<String, dynamic> transcription) async {
    final index = _projects.indexWhere((project) => project.id == _selectedId);
    if (index == -1) return;
    _projects[index] = _projects[index].copyWith(transcription: transcription);
    await _persist();
    notifyListeners();
  }

  Future<void> updateAudio(String audioPath) async {
    final index = _projects.indexWhere((project) => project.id == _selectedId);
    if (index == -1) return;
    _projects[index] = _projects[index].copyWith(audioPath: audioPath);
    await _persist();
    notifyListeners();
  }

  Future<void> replaceSelectedVideo(String sourcePath) async {
    final index = _projects.indexWhere((project) => project.id == _selectedId);
    if (index == -1) return;
    final project = _projects[index];
    final savedPath = await _importVideoFile(project.id, sourcePath);
    _projects[index] = project.copyWith(videoPath: savedPath);
    await _persist();
    notifyListeners();
  }

  Future<void> rename(VideoProject project, String name) async {
    final index = _projects.indexWhere((item) => item.id == project.id);
    if (index == -1 || name.trim().isEmpty) return;
    _projects[index] = _projects[index].copyWith(name: name.trim());
    await _persist();
    notifyListeners();
  }

  Future<void> delete(VideoProject project) async {
    _projects = _projects.where((item) => item.id != project.id).toList();
    if (_selectedId == project.id) _selectedId = null;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_projects.map((item) => item.toJson()).toList()),
    );
  }
}
