import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Path Connect'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/images/icon.png',height: 100,)),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Welcome to PathConnect!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              CardWithIcon(
                icon: Icons.info,
                title: 'About Us:',
                description:
                    'Our dropshipping app is designed to provide a seamless experience customers. We connect sellers with a wide audience, making it easy for them to showcase and sell their products without the hassle of managing inventory or shipping logistics.',
              ),
              SizedBox(height: 20),
              CardWithIcon(
                icon: Icons.shopping_bag,
                title: 'Dropshipping:',
                description: 'Join our platform to start dropshipping today. Showcase your products to a vast audience and let us handle the logistics for you!',
              ),
              SizedBox(height: 20),
              CardWithIcon(
                icon: Icons.directions_bike,
                title: 'Ride:',
                description: '''Need a ride? We've got you covered. Enjoy reliable transportation services with real-time tracking for your convenience.''',
              ),
              SizedBox(height: 20),
              CardWithIcon(
                icon: Icons.star,
                title: 'Key Features:',
                description: 
                    '• Secure and convenient transactions for customers\n'
                    '• Efficient and reliable delivery services',
              ),
              SizedBox(height: 20),
              CardWithIcon(
                icon: Icons.contact_support,
                title: 'Contact Us:',
                description: 'Have questions or feedback? Contact us at support@example.com',
                additionalInfo: 'pathconnec15@.com',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardWithIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? additionalInfo;

  const CardWithIcon({
    required this.icon,
    required this.title,
    required this.description,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 30,
   
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            if (additionalInfo != null) ...[
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.email),
                  SizedBox(width: 5),
                  Text(additionalInfo!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
