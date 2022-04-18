import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _largeFileUrl = 'http://212.183.159.230/512MB.zip';
  static const _middleSizeFileUrl = 'http://212.183.159.230/5MB.zip';
  static const _smallFileUrl =
      'http://www.africau.edu/images/default/sample.pdf';
  static const MethodChannel _channel =
      MethodChannel('com.example.stream_to_native_example/gallery_saver');

  bool _inProgress = false;
  String? _lastError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed:
                  _inProgress ? null : () => _saveFileFromUrl(_largeFileUrl),
              child: const Text('Save large file'),
            ),
            TextButton(
              onPressed: _inProgress
                  ? null
                  : () => _saveFileFromUrl(_middleSizeFileUrl),
              child: const Text('Save middle-sized file'),
            ),
            TextButton(
              onPressed:
                  _inProgress ? null : () => _saveFileFromUrl(_smallFileUrl),
              child: const Text('Save small file'),
            ),
            const SizedBox(height: 150.0),
            if (_lastError != null) ...[
              const Text('Last error:'),
              Text(
                _lastError!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveFileFromUrl(String url) async {
    setState(() {
      _inProgress = true;
    });
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data ?? []);

      await _channel.invokeMethod(
        'saveBytesToFile',
        <String, dynamic>{
          'bytes': bytes,
          'fileName': 'file_name_example',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text('Downloaded file from $url'),
      ));
      setState(() {
        _inProgress = false;
      });
    } catch (e, s) {
      setState(() {
        _lastError = e.toString();
        _inProgress = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error occurred saving file from $url'),
      ));
      print('Failed to save file from $url: $e \n Stacktrace: $s');
    }
  }
}
