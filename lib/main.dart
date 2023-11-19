import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escuchar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Escushar'),
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
  SpeechToText speechToText = SpeechToText();
  bool _speechEnabled = false;
  String lastWords = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initSpeech();
  }
  _initSpeech()async{
    _speechEnabled = await speechToText.initialize();
    setState(() {});
  }
  void startListening()async{
    await speechToText.listen(onResult: speechResult);
    print(speechToText.isListening);
    setState(() {});
  }
  speechResult(SpeechRecognitionResult result){
    print(result.recognizedWords);
    setState(() {
      lastWords=result.recognizedWords;
    });
  }
  void stopListening()async{
    print('stopping');
    await speechToText.stop();
    var res = await http.post(Uri.parse('http://eng-spa-4.hpfufscwa4anfwhc.centralindia.azurecontainer.io:8501/v1/models/translator:predict'),body: '{"signature_name": "serving_default","instances": ["Hello, my name is Dhruv"]}',headers:{'Content-Type': 'text/plain'});
    print(res.body);
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [IconButton(onPressed: (){print('working');}, icon: Icon(Icons.print))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('English'),
            Text(
              speechToText.isListening?'$lastWords':_speechEnabled
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: speechToText.isNotListening?startListening:stopListening,
        tooltip: 'Listen',
        child: Icon(speechToText.isNotListening?Icons.keyboard_voice_outlined:Icons.keyboard_voice),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
