import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // These are the "Privacy Settings" logic pieces
  bool isPrivate = false;
  bool shareWithClinic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Management"),
        backgroundColor: const Color(0xFF003366), // NUST Blue
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          // User Info Section
          const TextField(
            decoration: InputDecoration(
              labelText: "Full Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          const TextField(
            decoration: InputDecoration(
              labelText: "NUST Student ID",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),

          // Privacy Settings Section
          const Text(
            "Privacy Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Private Profile"),
            subtitle: const Text("Hide my health info from other students"),
            value: isPrivate,
            onChanged: (bool value) {
              setState(() {
                isPrivate = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text("Share with Clinic"),
            subtitle: const Text("Allow NUST Clinic to see my medical history"),
            value: shareWithClinic,
            onChanged: (bool value) {
              setState(() {
                shareWithClinic = value;
              });
            },
          ),
          const SizedBox(height: 30),

          // The "Finish" Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003366),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile Updated Successfully!")),
              );
            },
            child: const Text(
              "Save Changes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
