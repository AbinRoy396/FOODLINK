import 'package:flutter/material.dart';
import 'api_service.dart';

class FoodDonationsPage extends StatefulWidget {
  @override
  _FoodDonationsPageState createState() => _FoodDonationsPageState();
}

class _FoodDonationsPageState extends State<FoodDonationsPage> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> _donations;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  void _loadDonations() {
    setState(() {
      _donations = api.getFoodDonations();
    });
  }

  void _showAddDialog() {
    final _foodTypeController = TextEditingController();
    final _quantityController = TextEditingController();
    final _pickupController = TextEditingController();
    final _expiryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Food Donation"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _foodTypeController, decoration: InputDecoration(labelText: "Food Type")),
              TextField(controller: _quantityController, decoration: InputDecoration(labelText: "Quantity")),
              TextField(controller: _pickupController, decoration: InputDecoration(labelText: "Pickup Address")),
              TextField(controller: _expiryController, decoration: InputDecoration(labelText: "Expiry Time YYYY-MM-DD HH:MM:SS")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                try {
                  await api.addFoodDonation(
                    userId: 1, // change as needed
                    foodType: _foodTypeController.text,
                    quantity: _quantityController.text,
                    pickupAddress: _pickupController.text,
                    expiryTime: _expiryController.text,
                  );
                  Navigator.pop(context);
                  _loadDonations();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: Text("Add"))
        ],
      ),
    );
  }

  void _deleteDonation(int id) async {
    try {
      await api.deleteFood(id);
      _loadDonations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Donations"),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showAddDialog),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _donations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));

          final donations = snapshot.data ?? [];

          if (donations.isEmpty) return Center(child: Text("No donations found."));

          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];
              return ListTile(
                title: Text(donation['food_type']),
                subtitle: Text("Quantity: ${donation['quantity']} | Status: ${donation['status']}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteDonation(donation['donation_id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
