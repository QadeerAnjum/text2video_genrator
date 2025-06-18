import 'dart:convert';
import 'dart:io';
import 'package:Motion_AI/managers/userManager.dart';
import 'package:Motion_AI/src/features/core/Screens/CreditsProvider.dart';
import 'package:Motion_AI/src/features/core/Screens/appBar.dart';
import 'package:Motion_AI/src/features/core/Screens/creditsPage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageToVideoScreen extends StatefulWidget {
  @override
  _ImageToVideoScreenState createState() => _ImageToVideoScreenState();
}

class _ImageToVideoScreenState extends State<ImageToVideoScreen> {
  final TextEditingController _promptController = TextEditingController();

  File? _selectedImage;
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  String? userId;
  String? _generatedVideoUrl;
  bool showGeneratingText = false;
  String? _selectedDuration;
  String? _selectedAspectRatio;

  final List<String> _durationOptions = ['5', '10'];
  final List<String> _aspectRatioOptions = ['16:9', '9:16', '1:1'];

  File? _downloadedVideoFile;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _ensureUserExists() async {
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

  Future<File?> _downloadVideoFileFromUrl(String videoUrl) async {
    if (kIsWeb) return null;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            '${dir.path}/generated_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final file = File(filePath);

        await file.writeAsBytes(
          bytes,
          flush: true,
        ); // Ensure it's written to disk

        if (bytes.length <= 100 * 1024) {
          print("Downloaded file is too small: ${bytes.length} bytes");
        }

        if (await file.exists()) {
          return file;
        } else {
          print("File does not exist after writing.");
          return null;
        }
      } else {
        print("Download failed with status ${response.statusCode}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to download video.")));
        return null;
      }
    } catch (e) {
      print("Download error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error downloading video.")));
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playVideo(File videoFile) async {
    try {
      // Check if file exists and is large enough
      if (!await videoFile.exists()) {
        print("Video file does not exist: ${videoFile.path}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Video file not found.")));
        return;
      }

      if (await videoFile.length() <= 500 * 1024) {
        print("Invalid or too small video file.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Video file is too small or invalid.")),
        );
        return;
      }

      // Dispose previous controller if needed
      if (_videoController != null) {
        await _videoController!.dispose();
      }

      // Initialize and play
      _videoController = VideoPlayerController.file(videoFile);
      try {
        await _videoController!.initialize();
      } catch (e) {
        print("Video initialize failed: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Video cannot be played.")));
        return;
      }
      await _videoController!.setLooping(true);
      await _videoController!.play();

      setState(() {}); // Update UI
    } catch (e) {
      print("Video init/play error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Video play failed: $e")));
    }

    setState(() {
      _videoController = _videoController;
    });
  }

  Future<void> _generateVideo() async {
    // Start loading
    setState(() {
      _isLoading = true;
      _generatedVideoUrl = null;
      _videoController?.dispose();
      _videoController = null;
    });

    // Validate inputs
    if (_selectedImage == null ||
        _promptController.text.isEmpty ||
        _selectedDuration == null ||
        _selectedAspectRatio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields and pick an image.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      await _ensureUserExists();

      final url = Uri.parse(
        'https://motionai-backend-production.up.railway.app/generate_video_from_image',
      );

      final request =
          http.MultipartRequest('POST', url)
            ..fields['userId'] = userId!
            ..fields['prompt'] = _promptController.text
            ..fields['duration'] = _selectedDuration!
            ..fields['aspect_ratio'] = _selectedAspectRatio!
            ..files.add(
              await http.MultipartFile.fromPath('image', _selectedImage!.path),
            );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        final videoUrl = jsonResponse['download_url'];

        print("Video URL received: $videoUrl");

        final videoFile = await _downloadVideoFileFromUrl(videoUrl);
        if (videoFile != null) {
          _downloadedVideoFile = videoFile;
          _videoController = VideoPlayerController.file(videoFile);
          await _videoController!.initialize();
          await _videoController!.play();

          final creditsProvider = context.read<CreditsProvider>();
          await creditsProvider.deductCredits(100);

          setState(() {
            _isLoading = false;
            _generatedVideoUrl = videoFile.path;
          });
        } else {
          throw Exception('Failed to download video file');
        }
      } else {
        print("Server error: ${response.statusCode} ${response.reasonPhrase}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.reasonPhrase}")),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _fetchUserId() async {
    try {
      final id = await UserManager.getUserID();
      print("User ID inside TextToVideoUI: $id");

      setState(() {
        userId = id;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching user ID: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadVideo(
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

  @override
  void dispose() {
    _videoController?.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access credits from provider here:
    final credits = context.watch<CreditsProvider>().credits;
    return Scaffold(
      appBar: CustomAppBar(title: 'Motion AI'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Text(
                'Image To Video Generation',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Replace the existing image picker UI block with this:
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 56, 55, 55),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        97,
                        97,
                        97,
                      ).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  color: Colors.grey[900],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Icon(Icons.image, size: 80, color: Colors.grey),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              94,
                              94,
                              94,
                            ).withOpacity(0.6),

                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Pick Image",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Prompt',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
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
                  counterStyle: GoogleFonts.poppins(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Duration (seconds)",
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey[900],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              value: _selectedDuration,
              items:
                  _durationOptions
                      .map(
                        (dur) => DropdownMenuItem(
                          value: dur,
                          child: Text(
                            dur,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedDuration = val),
            ),

            SizedBox(height: 16),

            // Aspect Ratio Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Aspect Ratio",
                filled: true,
                fillColor: Colors.grey[900],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
              dropdownColor: Colors.grey[900],
              style: TextStyle(color: Colors.white),
              value: _selectedAspectRatio,
              items:
                  _aspectRatioOptions
                      .map(
                        (ratio) => DropdownMenuItem(
                          value: ratio,
                          child: Text(
                            ratio,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedAspectRatio = val),
            ),

            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () async {
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
                                setState(() {
                                  _isLoading = true;
                                  showGeneratingText = true;
                                });

                                await _generateVideo();

                                if (!_isLoading && _generatedVideoUrl != null) {
                                  setState(() {
                                    showGeneratingText =
                                        false; // hide the loading text before showing dialog
                                  });

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Video Generated',
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
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
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
                                              const SizedBox(height: 12),
                                              ElevatedButton.icon(
                                                onPressed:
                                                    () => _downloadVideo(
                                                      context,
                                                      _generatedVideoUrl,
                                                    ),
                                                icon: const Icon(
                                                  Icons.download,
                                                ),
                                                label: const Text("Download"),
                                              ),
                                            ],
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
                                } else {
                                  setState(() {
                                    showGeneratingText = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Video generation failed."),
                                    ),
                                  );
                                }
                              }
                            },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        _isLoading
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

            SizedBox(height: 20),
            if (showGeneratingText)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Generating Video...",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Please wait while your video is being generated.\nEstimated time: 2–4 min",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ],
                ),
              ),

            // if (_videoController != null &&
            //     _videoController!.value.isInitialized)
            //   AspectRatio(
            //     aspectRatio: _videoController!.value.aspectRatio,
            //     child: VideoPlayer(_videoController!),
            //   ),

            // if (_downloadedVideoFile != null &&
            //     _videoController != null &&
            //     _videoController!.value.isInitialized)
            //   Column(
            //     children: [
            //       AspectRatio(
            //         aspectRatio: _videoController!.value.aspectRatio,
            //         child: VideoPlayer(_videoController!),
            //       ),
            //       SizedBox(height: 10),
            //       ElevatedButton.icon(
            //         onPressed: () => _downloadVideo(context),
            //         icon: Icon(Icons.download),
            //         label: Text("Download Video"),
            //       ),
            //     ],
            //   ),
          ],
        ),
      ),
    );
  }
}
