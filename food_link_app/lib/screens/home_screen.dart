import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Pass your backend URL here
  final ApiService apiService = ApiService(baseUrl: "http://10.0.2.2:3000");
  late Future<List<dynamic>> donationsFuture;

  @override
  void initState() {
    super.initState();
    donationsFuture = apiService.getDonations(); // use existing method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donations")),
      body: FutureBuilder<List<dynamic>>(
        future: donationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No donations found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final donation = snapshot.data![index];
                return ListTile(
                  title: Text(donation['title'] ?? 'No Title'),
                  subtitle: Text(donation['description'] ?? 'No Description'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
