import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:Motion_AI/src/features/core/Screens/paymentPage.dart';
import 'package:Motion_AI/src/features/core/Screens/Text2VideoUI.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  int _currentIndex = 0;

  late AnimationController _blinkController;
  late Animation<double> _scaleAnimation;

  final List<String> videos = [
    'assets/videos/1.mp4',
    'assets/videos/2.mp4',
    'assets/videos/3.mp4',
  ];

  final List<String> videoTexts = [
    "Text to Ai Video",
    "Image to Ai Video",
    "Let's Get Started",
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();

    // Bounce-like animation setup
    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // slower for bounce effect
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _blinkController.dispose(); // dispose animation controller
    super.dispose();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (!isFirstLaunch) {
      _goToMainApp();
    } else {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset(videos[_currentIndex])
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller?.setLooping(true);
        _controller?.play();
      });
  }

  void _nextVideo() async {
    if (_currentIndex < videos.length - 1) {
      await _controller?.pause();
      await _controller?.dispose();
      _currentIndex++;
      _initializeVideo();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenWelcome', true);
      await prefs.setBool('hasSeenPayment', true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => PaymentPage(
                onClose: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => TextToVideoUI()),
                  );
                },
              ),
        ),
      );
    }
  }

  void _goToMainApp() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => TextToVideoUI()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          (_controller != null && _controller!.value.isInitialized)
              ? Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                  Container(color: Colors.black.withOpacity(0.3)),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          videoTexts[_currentIndex],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 5,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                236,
                                216,
                                103,
                              ),
                              foregroundColor: const Color.fromARGB(
                                255,
                                100,
                                55,
                                39,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 70,
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: _nextVideo,
                            child: Text(
                              _currentIndex == videos.length - 1
                                  ? 'Create Video'
                                  : 'Next',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
