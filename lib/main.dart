import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Joke App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Random Joke Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const JokeGeneratorPage();
        break;
      case 1:
        page = const Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              currentIndex: selectedIndex,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: 'Favorites')
              ]),
          body: Row(
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class JokeGeneratorPage extends StatefulWidget {
  const JokeGeneratorPage({super.key});

  @override
  State<JokeGeneratorPage> createState() => _JokeGeneratorPageState();
}

Joke? randomJoke;

class _JokeGeneratorPageState extends State<JokeGeneratorPage> {
  Future<void> fetchRandomJoke() async {
    final response = await http.get(Uri.parse(
        'https://official-joke-api.appspot.com/jokes/programming/random'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is List && responseData.isNotEmpty) {
        final jokedata = responseData[0];
        setState(() {
          randomJoke = Joke(jokedata['setup'], jokedata['punchline']);
        });
      } else {
        throw Exception('Failed to fetch a joke');
      }
    } else {
      throw Exception('Failed to fetch a joke');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("A Random Programmer's Joke"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (randomJoke != null)
              Text(
                '${randomJoke!.setup}\n${randomJoke!.punchline}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: () {}, child: const Text('ADD TO FAVORITE')),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                    onPressed: fetchRandomJoke,
                    child: const Text('GET NEXT JOKE'))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Joke {
  final String setup;
  final String punchline;

  Joke(this.setup, this.punchline);
}
