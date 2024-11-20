import 'package:flutter/material.dart';
import 'dart:convert'; // Used to work with JSON data
import 'package:http/http.dart' as http; // HTTP package for making API calls

void main() {
  runApp(const MyApp());
}

// The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTTP Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Fetch, Update & Delete Example'),
    );
  }
}

// Main widget of the application
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State class for the main widget
class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _data = []; // On va stocker les données récupérées de l'API dans ce bucket
  bool _isLoading = true;  // Loading = true ? comme les useState avec reactjs

  @override
  void initState() {
    super.initState();
    _fetchData(); // Que faire quand l'app démarre ? on appelle fetch !
  }

  // fetch data from the API
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true; 
    });

    try {
      // API call to fetch data
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        // Fetch réussi ?
        setState(() {
          _data = jsonDecode(response.body); // On décode le json
          _isLoading = false; // on arrête le chargement
        });
      } else {
        _showError('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Catch any other freaking errors
      _showError('An error occurred: $error');
    }
  }

  // update a specific item on through the api
  Future<void> _updateData(int id) async {
    try {
      // API call to update data using the PUT method
      final response = await http.put(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'}, // on met des headers vu que c'est une méthode post
        body: jsonEncode({ // like json.stringify de Javascript!
          'id': id,
          'title': 'Updated Title',
          'body': 'This is the updated body content.', 
          'userId': 1,
        }),
      );

      if (response.statusCode == 200) {
        _showMessage('Post $id updated successfully!');
      } else {
        _showError('Failed to update data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showError('An error occurred: $error');
    }
  }

  // Fonction pour supprimer
  Future<void> _deleteData(int id) async {
    try {
      final response = await http.delete(Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'));
      if (response.statusCode == 200) {
        // Successfully deleted data? on l'enlève de notre bucket aussi!
        setState(() {
          _data.removeWhere((item) => item['id'] == id); // Remove it
        });
        _showMessage('Post $id deleted successfully!');
      } else {
        _showError('Failed to delete data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showError('An error occurred: $error');
    }
  }

  // Snackbar pour un peu décorer le message d'erreur
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.red))),
    );
    setState(() {
      _isLoading = false; // Erreur ? on arrête le chargement
    });
  }

  // Pareil mais pour un message de 'success'
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner if loading
          : ListView.builder(
              itemCount: _data.length, // Number of items in the list
              itemBuilder: (context, index) {
                final item = _data[index]; // Current item in the list
                return Card(
                  child: ListTile(
                    title: Text(item['title']), // Display title
                    subtitle: Text(item['body']), // Display body
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Align buttons horizontally
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _updateData(item['id']), // Update this item
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteData(item['id']), // Delete this item
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // Floating action button to reload the data
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        tooltip: 'Reload',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}