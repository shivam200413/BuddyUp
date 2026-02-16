import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // The Free Map Widget
import 'package:latlong2/latlong.dart';      // Coordinates Helper
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_activity_screen.dart'; // Ensure this matches your file name exactly

class HomeMapScreen extends StatefulWidget {
  @override
  _HomeMapScreenState createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  // List to hold our map markers
  List<Marker> _markers = [];
  
  // Starting location: Chennai
  final LatLng _initialCenter = LatLng(13.0827, 80.2707);

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  // 1. Fetch data from Supabase
  Future<void> _fetchActivities() async {
    final supabase = Supabase.instance.client;
    try {
      final List<dynamic> response = await supabase.from('activities').select();

      setState(() {
        _markers = response.map((activity) {
          // 2. Convert database rows into Markers
          return Marker(
            point: LatLng(
              (activity['lat'] ?? 13.08).toDouble(), 
              (activity['lng'] ?? 80.27).toDouble()
            ),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showJoinDialog(activity),
              child: Icon(
                Icons.location_on, 
                color: Colors.redAccent, 
                size: 40,
                shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
              ),
            ),
          );
        }).toList();
      });
    } catch (e) {
      // In a real app, handle error silently or show a retry button
      print("Error loading map: $e");
    }
  }

  // 3. Popup when a user taps a pin
  void _showJoinDialog(Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(activity['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${activity['category'] ?? 'General'}"),
            SizedBox(height: 8),
            Text("Do you want to join this activity?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () {
               // In a real app, you would add an 'insert' to 'participants' table here
               Navigator.pop(ctx);
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text("Request Sent!"))
               );
            },
            child: Text("Join")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity Buddy"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _initialCenter,
          initialZoom: 13.0,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          // Layer 1: The Map Tiles (Images)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.activity_buddy',
          ),
          // Layer 2: Your Activity Pins
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Wait for the user to come back from the create screen
          await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateActivityScreen()));
          // Refresh the map to show the new pin
          _fetchActivities();
        },
      ),
    );
  }
}