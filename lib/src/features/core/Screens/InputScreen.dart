
import 'package:flutter/material.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool isLoading = false;

  void generateVideo() {
    setState(() => isLoading = true);
    // Placeholder for processing logic
    Future.delayed(Duration(seconds: 3), () {
      setState(() => isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Your Video'),
        centerTitle: true,
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Prompt:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe the scene and action.Forexample: a beautiful lady in an oil painting,with soft light casting on her face.',
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: isLoading ? null : generateVideo,
              icon: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Icon(Icons.video_call),
              label: Text(isLoading ? 'Generating...' : 'Generate Video', style: TextStyle(color: Colors.white), ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 37, 171, 119),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // You can embed a video player here or show a sample video
    return Scaffold(
      appBar: AppBar(title: Text('Your Video')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 100, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              'Your video is ready!',
              style: TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}



class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF1E1E1E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
            ),
            accountName: Text('xAoNLCpr'),
            accountEmail: Text('ID 29343036'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 40),
            ),
          ),

          // Rounded Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Column(
                children: [
                  // Upgrade Card
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.upgrade, color: Colors.black),
                        title: Text("Upgrade your plan", style: TextStyle(color: Colors.black)),
                        subtitle: Text("More Credits & Premium Features", style: TextStyle(color: Colors.black54)),
                        onTap: () {},
                      ),
                    ),
                  ),

                  // Credits + Manage Plan in One Card
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text("Credits Details", style: TextStyle(color: Colors.white)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, color: Colors.green),
                SizedBox(width: 5),
                Text("166.00", style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade800, thickness: 0.2),
          ListTile(
            title: Text("Manage your plan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  ),

  // Help Section in Card
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(title: Text("Messages", style: TextStyle(color: Colors.white))),
          Divider(color: Colors.grey.shade800, thickness: 0.2),
          ListTile(title: Text("Help Center", style: TextStyle(color: Colors.white))),
          Divider(color: Colors.grey.shade800, thickness: 0.2),
          ListTile(title: Text("Communities", style: TextStyle(color: Colors.white))),
          Divider(color: Colors.grey.shade800, thickness: 0.2),
          ListTile(title: Text("Contact Us", style: TextStyle(color: Colors.white))),
        ],
      ),
    ),
  ),

   // Help Section in Card
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(title: Text("Permission list", style: TextStyle(color: Colors.white))),
          Divider(color: Colors.grey.shade800, thickness: 0.2),
          ListTile(title: Text("Privacy Policy", style: TextStyle(color: Colors.white))),
          Divider(color: Colors.grey.shade800, thickness: 0.2),
          ListTile(title: Text("terms of services", style: TextStyle(color: Colors.white))),
          Divider(color: Colors.grey.shade800, thickness: 0.2),
          ListTile(title: Text("About Us", style: TextStyle(color: Colors.white))),
        ],
      ),
    ),
  ),

 Padding(
  
    padding: EdgeInsets.all(12), // apply padding inside container
    child: Center(
      child: SizedBox(
        width: 150,
        height: 40,
        child: ElevatedButton(
          onPressed: () {
            // Add sign out logic here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Sign out",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  ),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
