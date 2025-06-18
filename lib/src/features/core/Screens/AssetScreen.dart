import 'dart:io';

import 'package:Motion_AI/managers/userManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AssetScreen extends StatefulWidget {
  @override
  _AssetScreenState createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  List<String> videoUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = await UserManager.getUserID();
      final response = await http.get(
        Uri.parse(
          'http://motionai-backend-production.up.railway.app/list_videos?userId=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final List urls = json.decode(response.body)['videos'];
        setState(() {
          videoUrls = List<String>.from(urls);
          isLoading = false;
        });
      } else {
        print("❌ Failed to load videos, status: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❗ Error fetching videos: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generated Videos")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : videoUrls.isEmpty
              ? Center(child: Text("No videos found"))
              : ListView.builder(
                itemCount: videoUrls.length,
                itemBuilder: (context, index) {
                  final videoUrl = videoUrls[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: VideoListItem(videoUrl: videoUrl, index: index),
                  );
                },
              ),
    );
  }
}

class VideoListItem extends StatefulWidget {
  final String videoUrl;
  final int index;

  const VideoListItem({required this.videoUrl, required this.index});

  @override
  _VideoListItemState createState() => _VideoListItemState();
}

class _VideoListItemState extends State<VideoListItem> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _videoPlayerController.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );
      setState(() {
        _isPlayerReady = true;
      });
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> download_Video(String videoUrl) async {
    try {
      // Request permissions
      final storageStatus = await Permission.storage.request();
      final manageStatus = await Permission.manageExternalStorage.request();

      if (!storageStatus.isGranted && !manageStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      // Show loading snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Downloading video...')));

      // Download video bytes
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download video')),
        );
        return;
      }

      final videoBytes = response.bodyBytes;

      // Create Download directory path
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName =
          'downloaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = '${downloadsDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(videoBytes);

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
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Video ${widget.index + 1}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Pure white for clarity
              ),
            ),
            const SizedBox(height: 8),
            _isPlayerReady && _chewieController != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  ),
                )
                : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(31, 47, 48, 47),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => download_Video(widget.videoUrl),
                icon: const Icon(Icons.download),
                label: const Text("Download"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[400],
                  foregroundColor: Colors.black, // Button text/icon color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
