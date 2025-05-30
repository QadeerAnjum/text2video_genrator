import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

class ImageToVideoScreen extends StatefulWidget {
  @override
  _ImageToVideoScreenState createState() => _ImageToVideoScreenState();
}

class _ImageToVideoScreenState extends State<ImageToVideoScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String _aspectRatio = '16:9';
  String _model = 'model1';
  File? _pickedImage;
  String? _videoPath;
  VideoPlayerController? _videoController;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _generateVideo() async {
    if (_promptController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields and pick an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://your-fastapi-url/generate_image_to_video'),
    );
    request.fields['prompt'] = _promptController.text;
    request.fields['duration'] = _durationController.text;
    request.fields['aspect_ratio'] = _aspectRatio;
    request.fields['model'] = _model;
    request.files.add(
      await http.MultipartFile.fromPath('image', _pickedImage!.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, 'generated_video.mp4');
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      setState(() {
        _videoPath = filePath;
        _videoController = VideoPlayerController.file(file)
          ..initialize().then((_) {
            _videoController!.play();
            setState(() {});
          });
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Video generation failed')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image to Video Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(labelText: 'Prompt'),
            ),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(labelText: 'Duration (seconds)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _aspectRatio,
              onChanged: (value) => setState(() => _aspectRatio = value!),
              items:
                  ['16:9', '9:16', '1:1']
                      .map((ar) => DropdownMenuItem(child: Text(ar), value: ar))
                      .toList(),
              decoration: InputDecoration(labelText: 'Aspect Ratio'),
            ),
            DropdownButtonFormField<String>(
              value: _model,
              onChanged: (value) => setState(() => _model = value!),
              items:
                  ['model1', 'model2']
                      .map(
                        (model) =>
                            DropdownMenuItem(child: Text(model), value: model),
                      )
                      .toList(),
              decoration: InputDecoration(labelText: 'Model'),
            ),
            SizedBox(height: 10),
            _pickedImage != null
                ? Image.file(_pickedImage!, height: 150)
                : TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text('Pick Image'),
                  onPressed: _pickImage,
                ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateVideo,
              child: Text(_isLoading ? 'Generating...' : 'Generate Video'),
            ),
            SizedBox(height: 20),
            if (_videoPath != null && _videoController != null)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
          ],
        ),
      ),
    );
  }
}
