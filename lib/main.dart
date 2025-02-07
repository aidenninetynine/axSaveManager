import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          brightness: Brightness.dark,
          /* dark theme settings */
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
                  return Scaffold(
                    appBar: AppBar(title: const Text('UNDERTALE')),
                    body: Stack(
                      children: <Widget>[
                        // Center Button (as before)
                        Center(child: Text("Testing")),

                        // Bottom-Right Button using Align
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding( // Optional padding with Align
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                splashColor: Colors.red.withAlpha(30),
                                onTap: () {

                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(Icons.add),
                                  ),Text("New save")],)
                                )
                              )
                            )
                          ),
                        ),
                      ],
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


