import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
    final response = await http.get(
      Uri.parse('http://192.168.100.123:8000/list_videos'),
    );

    if (response.statusCode == 200) {
      final List urls = json.decode(response.body)['videos'];
      setState(() {
        videoUrls = List<String>.from(urls);
        isLoading = false;
      });
    } else {
      print("Failed to load videos, status: ${response.statusCode}");
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
        // You can customize controls here if needed
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Video ${widget.index + 1}",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _isPlayerReady && _chewieController != null
            ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            )
            : Container(
              height: 200,
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
      ],
    );
  }
}
