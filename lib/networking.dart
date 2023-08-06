import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:rxdart/rxdart.dart';

String backendUrl = 'wss://public.backend.medisearch.io:443/ws/medichat/api';

// This function
Future<void> fillMediSearchStream({
  required String query,
  required BehaviorSubject<String> streamController,
  required String api_key,
}) async {
  // generate ID for this conversation with MediSearch
  String conversationId = generateID();

  // prepare the request to MediSearch
  // TODO: you can insert your API key here
  Map<String, dynamic> userConversation = {
    'event': 'user_message',
    'conversation': ['Is cancer transmissible?'],
    'key': api_key,
    'id': conversationId,
    'settings': {'language': 'English'}
  };

  // set up connection to MediSearch.
  final channel = IOWebSocketChannel.connect(
      'wss://public.backend.medisearch.io:443/ws/medichat/api');

  // Prepare for receiving the request
  channel.stream.listen(
    (data) {
      // when we receive String data from the server, we decode it into a Map
      final Map jsonData = jsonDecode(data);

      // Now we check what type of data the server sent us. We can get
      // 1. articles
      // 2. response from the MediSearch LLM
      // 3. error
      if (jsonData['event'] == 'articles') {
        // print the articles
        print('Got articles');
        print(jsonData["articles"]);
      } else if (jsonData['event'] == 'llm_response') {
        // add the response from the MediSearch LLM to the stream
        print('Got llm response');
        streamController.add(jsonData["text"]);
      } else if (jsonData['event'] == 'error') {
        // print the error
        print(jsonData["error_code"]);
      }
    },
    onError: (error) => print(error),
  );

  // Send a request to the server.
  // the logic to handle this request is implemented in the code above
  channel.sink.add(jsonEncode(userConversation));

  // Note: Don't forget to close the channel when it's no longer needed.
}

String generateID() {
  String id = '';
  const String characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var rnd = Random();

  for (int i = 0; i < 32; i++) {
    id += characters[rnd.nextInt(characters.length)];
  }

  return id;
}
