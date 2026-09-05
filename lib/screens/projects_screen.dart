import '../core/utils.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:ui' show ImageFilter;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../core/app_colors.dart';
import '../core/models/video_project.dart';
import '../core/providers.dart';
import '../widgets/floating_navigation.dart';
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(projectsProvider).load());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(projectsProvider);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: !controller.loaded
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : controller.projects.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _ProjectsHeader(),
                            const SizedBox(height: 9),

                            const SizedBox(height: 14),
                            const Expanded(child: EmptyProjectsState()),
                          ],
                        )
                      : CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              floating: true,
                              pinned: false,
                              snap: true,
                              backgroundColor: AppColors.canvas,
                              automaticallyImplyLeading: false,
                              titleSpacing: 0,
                              title: const _ProjectsHeader(),
                            ),
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 9),

                                  const SizedBox(height: 14),
                                ],
                              ),
                            ),
                            ProjectsGrid(projects: controller.projects),
                          ],
                        ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                child: FloatingNavigation(
                  currentIndex: 0,
                  onCreate: () => showFeatureSelectionSheet(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsHeader extends StatelessWidget {
  const _ProjectsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'KapShorts',
            style: GoogleFonts.manrope(
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: Colors.white,
            ),
          ),
        ),
        const ProButton(),
        const SizedBox(width: 8),
        const CreditBadge(),
      ],
    );
  }
}

class CreditBadge extends StatelessWidget {
  const CreditBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFFFC107), size: 17),
          const SizedBox(width: 4),
          Text(
            '60 Credits',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class ProButton extends StatelessWidget {
  const ProButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: const Text(
        'Get PRO',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class EmptyProjectsState extends StatelessWidget {
  const EmptyProjectsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.3), // Shifts slightly above exact center
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmptyProjectArtwork(),
              // Removed SizedBox to reduce the gap significantly
              Text(
                'No projects yet',
                style: GoogleFonts.manrope(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 300,
                child: Text(
                  'Upload a video to create your first caption project.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyProjectArtwork extends StatelessWidget {
  const EmptyProjectArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      heightFactor: 0.7, // Reduces layout height to crop the empty black padding
      child: Image.asset(
        'assets/images/add_project_folder.png',
        width: 280, // Increased icon size
        height: 280,
      ),
    );
  }
}

class ProjectsGrid extends ConsumerWidget {
  const ProjectsGrid({required this.projects, super.key});
  final List<VideoProject> projects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 16, bottom: 120),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: .68,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            final project = projects[index];
            return GestureDetector(
              onSecondaryTap: () => showProjectActionsSheet(context, ref, project),
              child: InkWell(
                onTap: () async {
                  await ref.read(projectsProvider).select(project);
                  if (context.mounted) context.go('/editor');
                },
                onLongPress: () => showProjectActionsSheet(context, ref, project),
                onDoubleTap: () => showProjectActionsSheet(context, ref, project),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ProjectVideoCover(videoPath: project.videoPath),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        project.duration,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: projects.length,
        ),
      ),
    );
}
}

class ProjectVideoCover extends StatefulWidget {
  const ProjectVideoCover({required this.videoPath, super.key});
  final String videoPath;

  @override
  State<ProjectVideoCover> createState() => _ProjectVideoCoverState();
}

class _ProjectVideoCoverState extends State<ProjectVideoCover> {
  Future<File?>? _cover;

  @override
  void initState() {
    super.initState();
    _cover = createReelFrame(widget.videoPath, 500);
  }

  @override
  void didUpdateWidget(covariant ProjectVideoCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _cover = createReelFrame(widget.videoPath, 500);
    }
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: FutureBuilder<File?>(
      future: _cover,
      builder: (_, snapshot) => Stack(
        fit: StackFit.expand,
        children: [
          if (snapshot.data != null)
            Image.file(snapshot.data!, fit: BoxFit.cover)
          else
            const ColoredBox(color: AppColors.elevated),
          Container(color: Colors.black.withValues(alpha: .12)),
          const Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              size: 38,
              color: Color(0xD9FFFFFF),
            ),
          ),
        ],
      ),
    ),
  );
}



Future<void> showNewProjectSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const NewProjectSheet(),
  );
}

Future<void> showProjectActionsSheet(
  BuildContext context,
  WidgetRef ref,
  VideoProject project,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.delete_outline_rounded,
              size: 30,
              color: Colors.white,
            ),
            const SizedBox(height: 14),
            Text(
              'Delete project?',
              style: GoogleFonts.manrope(
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '“${project.name}” will be removed from this device.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondary, height: 1.45),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(projectsProvider).delete(project);
                  if (context.mounted) Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class NewProjectSheet extends ConsumerStatefulWidget {
  const NewProjectSheet({super.key});

  @override
  ConsumerState<NewProjectSheet> createState() => _NewProjectSheetState();
}

class _NewProjectSheetState extends ConsumerState<NewProjectSheet> {
  bool busy = false;
  bool linkMode = false;
  late final TextEditingController linkController;

  @override
  void initState() {
    super.initState();
    linkController = TextEditingController();
  }

  @override
  void dispose() {
    linkController.dispose();
    super.dispose();
  }

  Future<void> pickVideo() async {
    setState(() => busy = true);
    try {
      final file = await FilePicker.pickFile(type: FileType.video);
      if (file == null) return;
      ref.read(pendingVideoProvider.notifier).state = file.xFile;
      await ref
          .read(projectsProvider)
          .addVideo(name: file.name, path: file.xFile.path);
      if (mounted) {
        Navigator.pop(context);
        context.go('/transcribing');
      }
    } on PlatformException {
      if (mounted) {
        showAppMessage(
          context,
          'The video picker could not open. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> importVideoLink() async {
    final rawLink = linkController.text.trim();
    final uri = Uri.tryParse(rawLink);
    if (uri == null || !uri.hasScheme || !uri.isScheme('https')) {
      showAppMessage(context, 'Paste a valid public HTTPS video link.');
      return;
    }
    setState(() => busy = true);
    HttpClient? client;
    try {
      client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const HttpException('Video link request was not successful.');
      }
      if (response.contentLength > 100 * 1024 * 1024) {
        throw const HttpException('Video is larger than 100 MB.');
      }
      final rawName = uri.pathSegments.isEmpty
          ? 'video.mp4'
          : uri.pathSegments.last;
      final fileName = rawName.contains('.') ? rawName : '$rawName.mp4';
      final directory = await getTemporaryDirectory();
      final output = File(
        '${directory.path}/subreel_${DateTime.now().microsecondsSinceEpoch}_$fileName',
      );
      await response.pipe(output.openWrite());
      final savedFile = XFile(output.path, name: fileName);
      ref.read(pendingVideoProvider.notifier).state = savedFile;
      await ref
          .read(projectsProvider)
          .addVideo(name: savedFile.name, path: output.path);
      if (mounted) {
        Navigator.pop(context);
        context.go('/transcribing');
      }
    } on HttpException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } on SocketException {
      if (mounted) {
        showAppMessage(context, 'This video link could not be downloaded.');
      }
    } on FileSystemException {
      if (mounted) {
        showAppMessage(context, 'There was not enough space for this video.');
      }
    } finally {
      client?.close(force: true);
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'New Project',
                style: GoogleFonts.manrope(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: busy ? null : () => setState(() => linkMode = false),
                    borderRadius: BorderRadius.circular(22),
                    child: _SheetTab(
                      label: 'Upload video',
                      selected: !linkMode,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: busy ? null : () => setState(() => linkMode = true),
                    borderRadius: BorderRadius.circular(22),
                    child: _SheetTab(label: 'Video link', selected: linkMode),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (!linkMode)
              InkWell(
                onTap: busy ? null : pickVideo,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 174,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondary, width: 1.2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      busy
                          ? const SizedBox(
                              height: 28,
                              width: 28,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.video_library_outlined,
                              size: 34,
                              color: Colors.white,
                            ),
                      const SizedBox(height: 12),
                      Text(
                        busy ? 'Opening your files...' : 'Choose a video',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'MP4 or MOV · up to 100 MB',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Captions generated by SubReel\nNo API key needed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (linkMode)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Paste a public direct MP4 or MOV video link.',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: linkController,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'https://example.com/video.mp4',
                        hintStyle: const TextStyle(color: AppColors.tertiary),
                        filled: true,
                        fillColor: AppColors.elevated,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: FilledButton(
                        onPressed: busy ? null : importVideoLink,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          busy ? 'Downloading video...' : 'Continue',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetTab extends StatelessWidget {
  const _SheetTab({required this.label, required this.selected});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    height: 42,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: selected ? Colors.white : AppColors.elevated,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: selected ? Colors.white : AppColors.line),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? Colors.black : AppColors.tertiary,
      ),
    ),
  );
}


Future<void> showFeatureSelectionSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const FeatureSelectionSheet(),
  );
}


Future<void> showTeleprompterSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => SafeArea(
      top: false,
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: const Center(
          child: Text(
            'Teleprompter Mode Coming Soon...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    ),
  );
}

class FeatureSelectionSheet extends StatelessWidget {
  const FeatureSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'What would you like to create?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showNewProjectSheet(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/caption_template.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'AI Caption',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showTeleprompterSheet(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/teleprompter_template.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'AI Teleprompter',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

