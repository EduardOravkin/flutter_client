import 'package:flutter/material.dart';
import 'package:flutter_client/networking.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediSearch Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'MediSearch Flutter Demo'),
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
  BehaviorSubject<String> responseStreamController = BehaviorSubject<String>();
  bool isReset = true;
  String api_key = '';

  // This function is called when the user presses the button It sends a request
  // to MediSearch and sets up a stream (BehaviourSubject from the rxdart package)
  // which asynchronously receives data from MediSearch.
  void _getResponse() async {
    if (!isReset) {
      responseStreamController = BehaviorSubject<String>();
      isReset = true;
    } else {
      fillMediSearchStream(
          query: 'Is cancer transmissible?',
          api_key: api_key,
          streamController: responseStreamController);
      isReset = false;
    }
    setState(() {});
  }

  // The widget below asynchronously receives data from MediSearch and displays it
  // It is based on the StreamBuilder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(30),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter your api key here',
                  ),
                  onChanged: (String value) {
                    api_key = value;
                  },
                )),
            StreamBuilder(
                stream: responseStreamController.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  return Padding(
                      padding: EdgeInsets.all(30),
                      // If the stream is empty, we display a message to the user
                      // Otherwise, we display the response from MediSearch
                      child: (isReset || snapshot.data == null)
                          ? Text(
                              'Click the below button. This will ask MediSearch "Is cancer transmissible?". Wait a couple of seconds to see the response.')
                          : Text(snapshot.data!));
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getResponse,
        tooltip: 'Ask MediSearch',
        child: const Icon(Icons.question_mark),
      ),
    );
  }
}
