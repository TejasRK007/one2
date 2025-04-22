import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://hips.hearstapps.com/hmg-prod/images/tasman-glacier-lake-royalty-free-image-1623252368.jpg?crop=1xw:1xh;center,top&resize=980:*',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tejas RK',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'ID: 0123-4567-8910',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),

            _sectionTitle("Personal Information"),
            _profileTile("Email", "tejasrk@gmail.com", Icons.email),
            _profileTile("Phone", "+91 70192 86337", Icons.phone),
            _profileTile("DOB", "16 April 2003", Icons.cake),
            _profileTile("Gender", "Male", Icons.person_outline),

            const SizedBox(height: 20),
            _sectionTitle("Document Status"),
            _statusCard("Aadhar Verified", true),
            _statusCard("PAN Linked", true),
            _statusCard("Healthcare Registered", false),
            _statusCard("Address Verified", true),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit Profile feature coming soon.")),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _statusCard(String label, bool verified) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          verified ? Icons.verified_user : Icons.warning,
          color: verified ? Colors.green : Colors.orange,
        ),
        title: Text(label),
        trailing: Icon(
          verified ? Icons.check_circle : Icons.error,
          color: verified ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 20),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}