// User Card Widget
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userProfileUrl;

  const UserCard({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userProfileUrl,
    required double fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(userProfileUrl),
        ),
        title: Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(userEmail),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          onPressed: () {
            // Navigate to user details or perform an action
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailsScreen(userName: userName),
              ),
            );
          },
        ),
      ),
    );
  }
}

// User Details Screen (Optional)
class UserDetailsScreen extends StatelessWidget {
  final String userName;

  const UserDetailsScreen({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userName Details'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Details for $userName',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
