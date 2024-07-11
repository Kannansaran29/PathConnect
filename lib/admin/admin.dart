import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pathconnect/delivery/delivery.dart';

class AdminPage extends StatefulWidget {
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),

        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),

           
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _userService.getStudentUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found.'));
          } else {
            List<Map<String, dynamic>> users = snapshot.data!;
            int totalUsers = users.length;
            int adminUsers = users.where((user) => user['userRole'] == 'admin').length;
           // int deliveryUsers = users.where((user) => user['userRole'] == 'delivery').length;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          DashboardCard(title: 'Total Users', count: totalUsers, icon: Icons.people),
                          DashboardCard(title: 'Admin Users', count: adminUsers, icon: Icons.admin_panel_settings),
                          //DashboardCard(title: 'Delivery Users', count: deliveryUsers, icon: Icons.delivery_dining),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'All Users',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> user = users[index];
                        return Card(
                          elevation: 3.0,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              user['userName'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['userEmail'] ?? ''),
                                SizedBox(height: 8.0),
                              ],
                            ),
                            onTap: () {

                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  DashboardCard({required this.title, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 36.0,
          color: Colors.blue,
        ),
        SizedBox(height: 8.0),
        Text(
          title,
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 4.0),
        Text(
          '$count',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('pathconnectUsers');

  Stream<List<Map<String, dynamic>>> getStudentUsersStream() {
    return _usersCollection.snapshots().map((querySnapshot) => querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList());
  }
}