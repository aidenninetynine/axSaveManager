// ignore_for_file: unnecessary_breaks

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'instance.dart'; // Import Instance model
import 'save_file.dart'; // Import SaveFile model
import 'undertale/data_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'axSaveManager',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        darkTheme: ThemeData(
          /* dark theme settings */
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Brightness.dark),
          brightness: Brightness.dark,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    Widget page;
    switch (selectedPage) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedPage');
}


    return Scaffold(
      appBar: AppBar(
        title: const Text("axSaveManager"),
      ),
      body: page,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  newSave() {
    print("smegma");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.red.withAlpha(30),
          onTap: () {
             Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return DefaultTabController(initialIndex: 0, length: 2, child:
                    Scaffold(
                      appBar: AppBar(
                        title: const Text('UNDERTALE'),
                        bottom: const TabBar(
                          tabs: <Widget>[
                            Tab(
                              text: "Saves",
                              icon: Icon(Icons.save)
                            ),
                            Tab(
                              text: "Instances",
                              icon: Icon(Icons.gamepad)
                            ),
                          ]
                        ),
                      ),
                      body: TabBarView(
                        children: [
                          GameUndertaleSavePage(),
                          GameUndertaleGamePage(),
                        ]
                      )
                    )
                  );
                  },
              ));
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('UNDERTALE'),
          ),
        ),
      ),
    );
  }
}

class GameUndertaleSavePage extends StatefulWidget {
  const GameUndertaleSavePage({
    super.key,
  });

  @override
  State<GameUndertaleSavePage> createState() => _GameUndertaleSavePageState();
}

class _GameUndertaleSavePageState extends State<GameUndertaleSavePage> {
  List<SaveFile> _saveFiles = [];
  List<Instance> _instances = [];
  bool _isLoading = true;
  bool _isLoadingInstances = true;

  final TextEditingController _saveFileNameController = TextEditingController();
  Instance? _selectedInstance;

  @override
  void initState() {
    super.initState();
    _loadSaveFiles();
    _loadInstances();
  }

  @override
  void dispose() {
    _saveFileNameController.dispose(); // Dispose controller when widget is disposed
    super.dispose();
  }

  Future<void> _loadSaveFiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _saveFiles = await DataProvider.getSaveFiles();
    } catch (e) {
      // place snackbar here, i'm busy right now
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInstances() async {
    setState(() {
      _isLoadingInstances = true;
    });
    try {
      _instances = await DataProvider.getInstances();
    } catch (e) {
      // place snackbar here, i'm busy right now
    } finally {
      setState(() {
        _isLoadingInstances = false;
      });
    }
  }

  String _getInstanceName(int instanceId) {
    final instance = _instances.firstWhere(
      (inst) => inst.id == instanceId,
      orElse: () => Instance(id: -1, name: 'Unknown Instance', folderName: 'unknown'), // Default if not found
    );
    return instance.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _saveFiles.isEmpty
              ? const Center(child: Text('No save files found.'))
              : ListView.builder(
                  itemCount: _saveFiles.length,
                  itemBuilder: (context, index) {
                    final saveFile = _saveFiles[index];
                    final instanceName = _getInstanceName(saveFile.instanceId);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  saveFile.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Folder: ${saveFile.folderName}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text('id: ${saveFile.id}'),
                                _isLoadingInstances
                                  ? Center(child: Text('Loading...', style: TextStyle(color: Colors.grey[600])))
                                  : Text('Instance: $instanceName', style: TextStyle(color: Colors.grey[600]))
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(title: Text(saveFile.name), actions: [
                                    TextButton(onPressed: () {
                                      Navigator.pop(context, 'Delete');
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) => AlertDialog(
                                          title: Text('Delete save file?'),
                                          content: Text('Are you sure you want to delete ${saveFile.name}?'),
                                          actions: [
                                            TextButton(onPressed: () async {
                                              // Delete save file logic
                                              try {
                                                await DataProvider.deleteSaveFile(saveFile.id);
                                                // Reload save files to update the list
                                                await _loadSaveFiles();
                                                await _loadInstances();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Save file "${saveFile.name}" deleted successfully!')),
                                                );
                                                Navigator.pop(context, 'Deleted');
                                              } catch (e) {
                                                print('Error deleting save file: $e');
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Failed to delete save file: ${e.toString()}')),
                                                );
                                              }
                                            }, child: Text('Yes')),
                                            TextButton(onPressed: () => Navigator.pop(context, 'No'), child: Text('No'))
                                          ]
                                        )
                                      );
                                    },
                                    child: Text('Delete')),
                                    TextButton(onPressed: () {
                                      
                                    },
                                    child: Text('Load')),
                                    TextButton(onPressed: () => Navigator.pop(context, 'OK'), child: Text('OK')),
                                  ])
                                );
                              },
                              child: const Text('Select'), // Customize button text
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('New save file'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: _saveFileNameController,
                  decoration: const InputDecoration(labelText: 'Save name'),
              ),
              const SizedBox(height: 20), // Space between text field and dropdown
                DropdownButtonFormField<Instance>(
                  decoration: const InputDecoration(labelText: 'Instance'),
                  value: _selectedInstance,
                  items: _instances.map((Instance instance) {
                    return DropdownMenuItem<Instance>(
                      value: instance,
                      child: Text(instance.name),
                    );
                  }).toList(),
                  onChanged: (Instance? newValue) {
                    setState(() {
                      _selectedInstance = newValue;
                    });
                  },
                ),
            ]),
            actions: [
              TextButton(onPressed: () async {
                String saveFileName = _saveFileNameController.text;
                Instance? selectedInstance = _selectedInstance;
                if (saveFileName.isNotEmpty && selectedInstance != null) {
                  // Create a new SaveFile object
                  final newSaveFile = SaveFile(
                    id: -1, // Will be auto-generated by database
                    name: saveFileName,
                    folderName: saveFileName, // Default folder name
                    instanceId: selectedInstance.id,
                  );

                  try {
                    // Insert the new save file into the database
                    int insertedId = await DataProvider.insertSaveFile(newSaveFile);
                    print('Inserted Save File ID: $insertedId'); // Log the inserted ID
                    
                    // Reload save files to update the list
                    await _loadSaveFiles(); // Re-fetch instances and save files
                    await _loadInstances();
                    Navigator.of(context).pop(); // Close the dialog
                    // Optionally, clear the input field and selected instance
                    _saveFileNameController.clear();
                    setState(() {
                      _selectedInstance = null;
                    });
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Save file created successfully!')),
                    );
                  } catch (e) {
                    // Handle database insertion error
                    print('Error inserting save file: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create save file: ${e.toString()}')),
                    );
                  }
                } else {
                  // Show an error message if fields are not filled
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter save file name and select an instance.')),
                  );
                }
              }, child: Text('Create')),
              TextButton(onPressed: () => Navigator.pop(context, 'Cancel'), child: Text('Cancel'))
            ],
          )
        );
      }, label: Text('New save'), icon: Icon(Icons.save)),
    );
  }
}

class GameUndertaleGamePage extends StatefulWidget {
  const GameUndertaleGamePage({super.key});

  @override
  State<GameUndertaleGamePage> createState() => _GameUndertaleGamePageState();
}

class _GameUndertaleGamePageState extends State<GameUndertaleGamePage> {
  List<Instance> _instances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaveFiles();
  }

  Future<void> _loadSaveFiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _instances = await DataProvider.getInstances();
    } catch (e) {
      // Handle error loading instances
      print('Error loading instances: $e');
      // You could show a SnackBar or AlertDialog here
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _instances.isEmpty
              ? const Center(child: Text('No save files found.'))
              : ListView.builder(
                  itemCount: _instances.length,
                  itemBuilder: (context, index) {
                    final instance = _instances[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  instance.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Folder: ${instance.folderName}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(title: Text(instance.name), actions: [
                                    TextButton(onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) => AlertDialog(
                                          title: Text('Delete instance?'),
                                          content: Text('Are you sure you want to delete ${instance.name}?'),
                                          actions: [
                                            TextButton(onPressed: () => print('yeehee'), child: Text('Yes')),
                                            TextButton(onPressed: () => Navigator.pop(context, 'No'), child: Text('No'))
                                          ]
                                        )
                                      );
                                    },
                                    child: Text('Delete')),
                                    TextButton(onPressed: () => print('hi'), child: Text('Load')),
                                    TextButton(onPressed: () => Navigator.pop(context, 'OK'), child: Text('OK')),
                                  ])
                                );
                              },
                              child: const Text('Select'), // Customize button text
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}