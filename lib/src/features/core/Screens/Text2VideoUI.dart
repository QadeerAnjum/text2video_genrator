import 'package:Motion_AI/managers/userManager.dart';
import 'package:Motion_AI/src/features/core/Screens/CreditsProvider.dart';
import 'package:Motion_AI/src/features/core/Screens/appBar.dart';
import 'package:Motion_AI/src/features/core/Screens/creditsPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:Motion_AI/src/features/core/Screens/appDrawer.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_downloader/flutter_downloader.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: TextToVideoUI()),
  );
}

class TextToVideoUI extends StatefulWidget {
  const TextToVideoUI({super.key});

  @override
  State<TextToVideoUI> createState() => _TextToVideoUIState();
}

class _TextToVideoUIState extends State<TextToVideoUI> {
  final TextEditingController _promptController = TextEditingController();

  String selectedDuration = '5s'; // options: '5s' or '10s'
  String selectedAspectRatio = '16:9'; // options: '16:9' or '1:1'
  String selectedModel = 'MINIMAX v1'; // options: 'MINIMAX v1' or 'MINIMAX v2'

  String? userId;
  bool isLoading = false;

  String? generatedVideoUrl;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    fetchUserId();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> fetchUserId() async {
    try {
      final id = await UserManager.getUserID();
      print("User ID inside TextToVideoUI: $id");

      setState(() {
        userId = id;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user ID: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> ensureUserExists() async {
    final url = Uri.parse(
      'https://motionai-backend-production.up.railway.app/create_user',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode != 200 && response.statusCode != 400) {
      // 400 = user already exists, so treat as success
      throw Exception('Failed to create or verify user');
    }
  }

  Future<void> generateVideo() async {
    setState(() {
      isLoading = true;
      generatedVideoUrl = null;
      _videoController?.dispose();
      _videoController = null;
    });

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a prompt')));
      setState(() => isLoading = false);
      return;
    }

    try {
      await ensureUserExists(); // make sure userId is initialized

      final url = Uri.parse(
        'https://motionai-backend-production.up.railway.app/generate_video',
      );
      final int durationSec = int.parse(selectedDuration.replaceAll('s', ''));

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'prompt': prompt,
          'duration': durationSec,
          'aspect_ratio': selectedAspectRatio,
          'model': selectedModel,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final downloadUrl = data['download_url'];

        final videoResponse = await http.get(Uri.parse(downloadUrl));
        if (videoResponse.statusCode == 200) {
          final bytes = videoResponse.bodyBytes;

          final directory = await getApplicationDocumentsDirectory();
          final filePath =
              '${directory.path}/generated_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
          final file = File(filePath);
          await file.writeAsBytes(bytes);

          _videoController = VideoPlayerController.file(file);
          await _videoController!.initialize();
          await _videoController!.play();

          _videoController!.addListener(() {
            setState(() {});
          });

          print('Status code: ${response.statusCode}');
          print('Response body: ${response.body}');

          final creditsProvider = context.read<CreditsProvider>();
          await creditsProvider.deductCredits(100);

          setState(() {
            isLoading = false;
            generatedVideoUrl = filePath;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download generated video')),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate video: ${response.statusCode} - ${response.reasonPhrase}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> downloadVideo(
    BuildContext context,
    String? generatedVideoPath,
  ) async {
    if (generatedVideoPath == null || generatedVideoPath.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid video path')));
      return;
    }

    try {
      // Request necessary permissions
      final storageStatus = await Permission.storage.request();
      final manageStatus = await Permission.manageExternalStorage.request();

      if (!storageStatus.isGranted && !manageStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      final sourceFile = File(generatedVideoPath);

      if (!await sourceFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Source video file does not exist')),
        );
        return;
      }

      // Use external storage for downloads
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName =
          'downloaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final destinationPath = '${downloadsDir.path}/$fileName';
      final destinationFile = File(destinationPath);

      await destinationFile.writeAsBytes(await sourceFile.readAsBytes());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video saved to Downloads as $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving video: $e')));
    }
  }

  Widget _dropOption(String text, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color:
            selected
                ? const Color.fromARGB(255, 97, 97, 98)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: selected ? Colors.white : Colors.white54,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _dropOptionWithIcon(String text, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color:
            selected
                ? const Color.fromARGB(255, 97, 97, 98)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.aspect_ratio,
            color: selected ? Colors.white : Colors.white54,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: selected ? Colors.white : Colors.white54,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVideoPlaying = _videoController?.value.isPlaying ?? false;
    final videoDuration = _videoController?.value.duration ?? Duration.zero;
    final videoPosition = _videoController?.value.position ?? Duration.zero;

    // Access credits from provider here:
    final credits = context.watch<CreditsProvider>().credits;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: 'Motion AI'),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 180),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Text To Video Generation',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      Text(
                        'Prompt',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _promptController,
                          maxLines: 6,
                          maxLength: 2000,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            hintText: 'Describe the scene and the action...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            counterStyle: GoogleFonts.poppins(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Avoid violent scenes, disturbing content, or any NSFW material.',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Example:',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'A sunset over a calm ocean, and with reflection of sun in water.',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Duration',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDuration = '5s';
                              });
                            },
                            child: _dropOption(
                              '5 seconds',
                              selected: selectedDuration == '5s',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Aspect Ratio',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAspectRatio = '16:9';
                              });
                            },
                            child: _dropOptionWithIcon(
                              '16:9',
                              selected: selectedAspectRatio == '16:9',
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAspectRatio = '1:1';
                              });
                            },
                            child: _dropOptionWithIcon(
                              '1:1',
                              selected: selectedAspectRatio == '1:1',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Generate Video Button Positioned
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            if (credits < 100) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreditsPage(),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "You need at least 100 credits to generate a video.",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  bool localLoading = true;

                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      if (localLoading) {
                                        localLoading = false;
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) async {
                                              await generateVideo();
                                              setState(() {});
                                            });
                                      }

                                      return AlertDialog(
                                        title: Text(
                                          isLoading
                                              ? 'Generating Video...'
                                              : 'Video Generated',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: SizedBox(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.8,
                                          child:
                                              isLoading
                                                  ? Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const CircularProgressIndicator(),
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      Text(
                                                        'Please wait while we generate your video...',
                                                        style:
                                                            GoogleFonts.poppins(),
                                                      ),
                                                      Text(
                                                        'Estimated Time: 2–4 minutes',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                    ],
                                                  )
                                                  : _videoController != null &&
                                                      _videoController!
                                                          .value
                                                          .isInitialized
                                                  ? Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      AspectRatio(
                                                        aspectRatio:
                                                            _videoController!
                                                                .value
                                                                .aspectRatio,
                                                        child: VideoPlayer(
                                                          _videoController!,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      ElevatedButton.icon(
                                                        onPressed:
                                                            () => downloadVideo(
                                                              context,
                                                              generatedVideoUrl,
                                                            ),
                                                        icon: const Icon(
                                                          Icons.download,
                                                        ),
                                                        label: const Text(
                                                          "Download",
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                  : Text(
                                                    generatedVideoUrl == null
                                                        ? 'Video generation failed or was cancelled.'
                                                        : 'Video preview failed to load.',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              _videoController?.dispose();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Generate Video',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
