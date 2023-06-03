import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  FlutterDownloader.registerCallback(TestClass.downloadCallback);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Downloader Demo'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                urlDownloader("https://picsum.photos/250?image=9");
              },
              child: commonButton(),
            ),
            const SizedBox(
              height: 12,
            ),
            GestureDetector(
              onTap: () {
                urlDownloader(
                    "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3");
              },
              child: commonButton(buttonName: "MusicDownloader"),
            ),
            const SizedBox(
              height: 12,
            ),
            GestureDetector(
              onTap: () {
                urlDownloader(
                    "http://techslides.com/demos/sample-videos/small.mp4");
              },
              child: commonButton(buttonName: "VideoDownloader"),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Container commonButton({String? buttonName}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(16),
      child: Text(
        buttonName ?? "ImageDownload",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Future<String?> getDownloadFolderPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  urlDownloader(String fileURL) async {
    final indexOfLastDash = fileURL.lastIndexOf("/");
    final indexOfQuestionMark = fileURL.lastIndexOf("?");
    var fileName = fileURL;
    if (indexOfLastDash != -1) {
      fileName = fileURL.substring(indexOfLastDash + 1,
          indexOfQuestionMark != -1 ? indexOfQuestionMark : fileURL.length);
    }

    final downloadDirectoryPath = await getDownloadFolderPath();
    if (downloadDirectoryPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cannot access to download folder!'),
      ));

      return;
    }

    final file = File("$downloadDirectoryPath/$fileName");
    final fileExist = await file.exists();
    if (fileExist) {
      file.delete();
    }
    if (Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Go to FlutterDownloader folder'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Go to Download folder'),
      ));
    }
    await FlutterDownloader.enqueue(
      url: fileURL,
      headers: {},
      savedDir: downloadDirectoryPath,
      saveInPublicStorage: true,
      showNotification: true,
      openFileFromNotification: true,
    );
  }
}

class TestClass {
  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    print(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );
  }
}
