import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateActivityScreen extends StatefulWidget {
  @override
  _CreateActivityScreenState createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController(); // Added category input
  bool _isLoading = false;

  // Hardcoded location for MVP (Chennai). 
  // In a real app, you would pick this from the map.
  final double _lat = 13.0827;
  final double _lng = 80.2707;

  Future<void> _createActivity() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      // If user is not logged in, we can't create a post
      if (user != null) {
        await Supabase.instance.client.from('activities').insert({
          'creator_id': user.id,
          'title': _titleController.text,
          'category': _categoryController.text.isEmpty ? 'General' : _categoryController.text,
          'lat': _lat,
          'lng': _lng,
          'status': 'open',
          'max_slots': 10, // Default value
        });

        if (mounted) {
          Navigator.pop(context); // Go back to the map
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Activity Created Successfully!"))
          );
        }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You must be logged in to post."))
          );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Host an Activity")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController, 
              decoration: InputDecoration(
                labelText: 'Activity Title', 
                hintText: 'e.g. Badminton at 5 PM',
                border: OutlineInputBorder()
              )
            ),
            SizedBox(height: 16),
             TextField(
              controller: _categoryController, 
              decoration: InputDecoration(
                labelText: 'Category', 
                hintText: 'e.g. Sports, Study, Food',
                border: OutlineInputBorder()
              )
            ),
            SizedBox(height: 24),
            _isLoading 
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _createActivity,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: Text("Create Activity"),
              ),
          ],
        ),
      ),
    );
  }
}