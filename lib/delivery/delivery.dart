import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:geodesy/geodesy.dart';
import 'package:pathconnect/two_points.dart';

class DeliveryPage extends StatefulWidget {
  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String deliveryUserId;
  LocationData? currentLocation;
  late Location location;
  final Geodesy geodesy = Geodesy();

  @override
  void initState() {
    super.initState();
    // Get current delivery user ID
    deliveryUserId = FirebaseAuth.instance.currentUser!.uid;

    // Initialize location plugin
    location = Location();
    // Fetch current location
    _fetchCurrentLocation();

    // Initialize the TabController
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the TabController when not needed
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      Location location = Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          print('Location services are not enabled.');
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          print('Location permissions are not granted.');
          return;
        }
      }

      _locationData = await location.getLocation();
      setState(() {
        currentLocation = _locationData;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // IconButton(
          //     onPressed: () {
          //       FirebaseAuth.instance.signOut();
          //     },
          //     icon: Icon(Icons.logout_outlined))
        ],
        title: Text('Delivery Page'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        _buildPendingOrdersList(),
        _buildCompletedOrdersList(),
      ]),
    );
  }

  Widget _buildPendingOrdersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('pathconnectOrder')
          .where('isCompleted', isEqualTo: false)
                    .where('type', isEqualTo: 'drop')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData ||
            currentLocation == null ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No orders found',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        // List of orders
        var orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order['orderId']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        order['type'] == 'drop' ? 'Drop Shipping' : 'Ride',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Total Amount: ₹${order['totalRideAmount']}'),
                      SizedBox(height: 4),
                      Text(
                        order['status'] == 'pending'
                            ? 'Pick Up Location'
                            : 'Destination',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        order['status'] == 'pending'
                            ? '${order['currentLocationLatitude']}'
                            : '${order['destinationLocationLatitude']}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              double startLatitude,
                                  startLongitude,
                                  endLatitude,
                                  endLongitude;

                              if (order['status'] == 'pending') {
                                startLatitude = currentLocation!.latitude!;
                                startLongitude = currentLocation!.longitude!;
                                endLatitude = order['currentLocationLatitude'];
                                endLongitude =
                                    order['currentLocationLongitude'];
                              } else {
                                startLatitude =
                                    order['currentLocationLatitude'];
                                startLongitude =
                                    order['currentLocationLongitude'];
                                endLatitude =
                                    order['destinationLocationLatitude'];
                                endLongitude =
                                    order['destinationLocationLongitude'];
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlotMap(
                                    startLatitude: startLatitude,
                                    startLongitude: startLongitude,
                                    endLatitude: endLatitude,
                                    endLongitude: endLongitude,
                                    titleMessage: 'Delivery Route',
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.location_on_outlined),
                            label: Text('View Map'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              String status = order['status'] == 'pending'
                                  ? 'picked up'
                                  : 'completed';
                              _pickUpOrder(order.id,
                                  order['status'] != 'pending', status);
                            },
                            child: Text(
                              order['status'] == 'pending'
                                  ? 'Pick Up'
                                  : 'Complete',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedOrdersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('pathconnectOrder')
          .where('isCompleted', isEqualTo: true)
          .where('assignedDeliveryUserId',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData ||
            currentLocation == null ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No orders found',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        // List of orders
        var orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order['orderId']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        order['type'] == 'drop' ? 'Drop Shipping' : 'Ride',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Total Amount: ₹${order['totalRideAmount']}'),
                      SizedBox(height: 4),
                      Text(
                        order['status'] == 'pending'
                            ? 'Pick Up Location'
                            : 'Destination',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        order['status'] == 'pending'
                            ? '${order['currentLocationLatitude']}'
                            : '${order['destinationLocationLatitude']}',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              double startLatitude,
                                  startLongitude,
                                  endLatitude,
                                  endLongitude;

                              if (order['status'] == 'pending') {
                                startLatitude = currentLocation!.latitude!;
                                startLongitude = currentLocation!.longitude!;
                                endLatitude = order['currentLocationLatitude'];
                                endLongitude =
                                    order['currentLocationLongitude'];
                              } else {
                                startLatitude =
                                    order['currentLocationLatitude'];
                                startLongitude =
                                    order['currentLocationLongitude'];
                                endLatitude =
                                    order['destinationLocationLatitude'];
                                endLongitude =
                                    order['destinationLocationLongitude'];
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlotMap(
                                    startLatitude: startLatitude,
                                    startLongitude: startLongitude,
                                    endLatitude: endLatitude,
                                    endLongitude: endLongitude,
                                    titleMessage: 'Delivery Route',
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.location_on_outlined),
                            label: Text('View Map'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              String status = order['status'] == 'pending'
                                  ? 'picked up'
                                  : 'completed';
                              _pickUpOrder(order.id,
                                  order['status'] != 'pending', status);
                            },
                            child: Text(
                              order['status'] == 'pending'
                                  ? 'Pick Up'
                                  : 'Complete',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    LatLng startLatLng = LatLng(startLatitude, startLongitude);
    LatLng endLatLng = LatLng(endLatitude, endLongitude);
    double distance =
        geodesy.distanceBetweenTwoGeoPoints(startLatLng, endLatLng) / 1000;
    return distance;
  }

  void _pickUpOrder(String orderId, bool isCompleted, String status) {
    _firestore.collection('pathconnectOrder').doc(orderId).update({
      'assignedDeliveryUserId': deliveryUserId,
      'status': status,
      'isCompleted': isCompleted,
    });
  }
}
