import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:text2video_app/src/features/core/Screens/appDrawer.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_filex/open_filex.dart';

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

  bool isLoading = false;

  final String userId =
      "dummy_user_123"; // TODO: replace with actual user ID from auth

  String? generatedVideoUrl;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _promptController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> ensureUserExists() async {
    final url = Uri.parse('http://192.168.100.202:8000/create_user');
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
      await ensureUserExists();

      final url = Uri.parse('http://192.168.100.202:8000/generate_video');
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

        // Download video bytes from downloadUrl
        final videoResponse = await http.get(Uri.parse(downloadUrl));
        if (videoResponse.statusCode == 200) {
          final bytes = videoResponse.bodyBytes;

          // Save to local file
          final directory = await getApplicationDocumentsDirectory();
          final filePath =
              '${directory.path}/generated_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
          final file = File(filePath);
          await file.writeAsBytes(bytes);

          // Initialize video controller with local file
          _videoController = VideoPlayerController.file(file);
          await _videoController!.initialize();
          await _videoController!.play();

          _videoController!.addListener(() {
            setState(() {}); // update UI on video progress
          });

          setState(() {
            isLoading = false;
            generatedVideoUrl = filePath; // now this is local path
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
    String? generatedVideoUrl,
  ) async {
    if (generatedVideoUrl == null) return;

    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download not supported on Web')));
      return;
    }

    try {
      final file = File(generatedVideoUrl);
      if (await file.exists()) {
        // Just open the file directly
        await OpenFilex.open(generatedVideoUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video opened from $generatedVideoUrl')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Video file does not exist')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening video: $e')));
    }
  }

  Widget _dropOption(String text, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
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
        color: selected ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Text to Video',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: selectedModel,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              items:
                  ['MINIMAX v1', 'MINIMAX v2']
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedModel = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(showLoginDialog: showLoginDialog),
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

                      // Warning with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Avoid violent scenes, disturbing content, or any NSFW material.',
                              style: TextStyle(
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
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDuration = '10s';
                              });
                            },
                            child: _dropOption(
                              '10 seconds',
                              selected: selectedDuration == '10s',
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
                      const SizedBox(height: 24),
                      if (generatedVideoUrl != null &&
                          _videoController != null &&
                          _videoController!.value.isInitialized)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Generated Video',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isVideoPlaying
                                        ? Icons.pause_circle
                                        : Icons.play_circle,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isVideoPlaying) {
                                        _videoController!.pause();
                                      } else {
                                        _videoController!.play();
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Slider(
                                    activeColor: Colors.blueAccent,
                                    inactiveColor: Colors.white24,
                                    min: 0,
                                    max:
                                        videoDuration.inMilliseconds.toDouble(),
                                    value:
                                        videoPosition.inMilliseconds
                                            .clamp(
                                              0,
                                              videoDuration.inMilliseconds,
                                            )
                                            .toDouble(),
                                    onChanged: (value) {
                                      _videoController!.seekTo(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                    },
                                  ),
                                ),
                                Text(
                                  '${videoPosition.inSeconds}s / ${videoDuration.inSeconds}s',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed:
                                  () =>
                                      downloadVideo(context, generatedVideoUrl),
                              icon: const Icon(
                                Icons.download,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Download Video',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : generateVideo,
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
