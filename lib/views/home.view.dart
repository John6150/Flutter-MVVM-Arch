import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:first_project/viewmodels/increament.viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  String? recordingPath;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Position position = await ref.read(locatorProvider.notifier).build();
      List<Placemark> placemarks = await ref
          .read(locatorProvider.notifier)
          .locateMe(long: position.longitude, lat: position.latitude);
      print('$placemarks');
      print(
        'Current Position: ${position.latitude}, ${position.longitude.runtimeType}, ${position.accuracy}, ${position.isMocked}',
      );
    });

    // Future.delayed(Duration.zero, () async {
    // });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (recordingPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recording available to play.')),
      );
      return;
    }

    final file = File(recordingPath!);
    if (!await file.exists() || (await file.length()) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The recording file is empty or could not be found.'),
        ),
      );
      return;
    }

    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
      return;
    }

    await _player.play(DeviceFileSource(recordingPath!));
    setState(() => _isPlaying = true);
  }

  @override
  Widget build(BuildContext context) {
    final stateProviderTwo = ref.watch(increamentVMProvider);
    final setStateProvider = ref.read(increamentVMProvider.notifier);

    final isRecording = ref.watch(recordAudioProvider).value ?? false;
    final testKey = dotenv.get('TEST_SECRET_KEY');
    // final publicKey = dotenv.get('TEST_PUBLIC_KEY');

    return Scaffold(
      appBar: AppBar(
        title: Text('Counter App'),
        actionsPadding: EdgeInsets.symmetric(horizontal: 30),
        actions: [],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            key: Key('decrement_button'),
            onPressed: () {
              print(testKey);
              // counter.decreament();
              setStateProvider.decreament();
            },
            child: Icon(Icons.remove),
          ),
          // SizedBox(height: 10),
          // FloatingActionButton(
          //   key: Key('increment_button'),
          //   onPressed: () {
          //     // counter.increament();
          //     setStateProvider.increament(context);
          //   },
          //   child: Icon(Icons.add),
          // ),
          // SizedBox(height: 10),
          // FloatingActionButton(
          //   key: Key('record_button'),
          //   onPressed: () async {
          //     final result = await ref
          //         .read(recordAudioProvider.notifier)
          //         .recording();
          //     print('Recording path: $result');
          //     setState(() {
          //       recordingPath = result;
          //     });

          //     // counter.increament();
          //     // setStateProvider.increament(context);
          //   },
          //   child: Icon(
          //     Icons.circle,
          //     color: isRecording ? Colors.red : Colors.black,
          //   ),
          // ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to my first flutter app'),
            stateProviderTwo.when(
              data: (viewCounter) {
                return Text('You have tapped this $viewCounter many times');
              },
              error: (error, stackTrace) {
                return Center(child: Text('Error occurred: $error'));
              },
              loading: () {
                return Center(child: CircularProgressIndicator());
              },
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _togglePlayback,
                  child: Text(_isPlaying ? 'Stop Recording' : 'Play Recording'),
                ),
              ],
            ),

            SizedBox(height: 20),
            CupertinoButton(
              child: Text('Tap me'),
              color: Colors.blue,

              onPressed: () async {
                await PayWithPayStack().now(
                  context: context,
                  secretKey: testKey,
                  customerEmail: 'abc@gmail.com',
                  amount: 1000,
                  showAppBar: true,

                  callbackUrl: 'https://www.google.com',
                  currency: 'NGN',
                  reference: 'ref-${DateTime.now().millisecondsSinceEpoch}',
                  transactionCompleted: (data) =>
                      print('Transaction completed: $data'),
                  transactionCancelled: () {},
                  transactionNotCompleted: (data) =>
                      print('Transaction not completed: $data'),

                  // PaystackConfig(
                  //   secretKey: testKey,
                  //   currency: 'NGN',
                  //   callbackUrl: 'https://www.google.com',
                  //   enableLogging:
                  //       true, // logs requests in debug, silent in release
                  //   timeout: const Duration(seconds: 30),
                  // ),
                );
              },
              // print('Platform is ${Platform.operatingSystem}');
              // ANDROID ALERT DIALOG
              // showDialog(
              //   context: context,
              //   builder: (context) => AlertDialog(
              //     title: Text('Alert'),
              //     content: Text(
              //       'This is a platform-specific alert dialog.',
              //     ),
              //     actions: [
              //       TextButton(
              //         child: Text('Cancel'),
              //         onPressed: () => Navigator.of(context).pop(),
              //       ),
              //       TextButton(
              //         child: Text('OK'),
              //         onPressed: () => Navigator.of(context).pop(),
              //       ),
              //     ],
              //   ),
              // ),
              // iOS ALERT DIALOG
              // showDialog(
              //   context: context,

              //   builder: (context) => CupertinoDatePicker(
              //     showTimeSeparator: false,
              //     mode: CupertinoDatePickerMode.date,
              //     backgroundColor: Colors.white,
              //     onDateTimeChanged: (val) {},
              //   ),

              // CupertinoAlertDialog(
              //   title: Text('Cupertino Alert'),
              //   content: Text('This is a Cupertino-style alert dialog.'),
              //   actions: [
              //     CupertinoDialogAction(
              //       child: Text('Cancel'),
              //       onPressed: () => Navigator.of(context).pop(),
              //     ),
              //     CupertinoDialogAction(
              //       child: Text('OK'),
              //       onPressed: () => Navigator.of(context).pop(),
              //     ),
              //   ],
              // ),
            ),

            // ANDROID BOTTOM SHEET
            // showModalBottomSheet(
            //   context: context,
            //   builder: (context) => Container(
            //     height: 200,
            //     color: Colors.white,
            //     child: Center(child: Text('This is a bottom sheet')),
            //   ),
            // ),

            // iOS BOTTOM SHEET

            // showCupertinoModalPopup(
            //   context: context,
            //   builder: (context) => CupertinoActionSheet(
            //     title: Text('Cupertino Action Sheet'),
            //     message: Text('This is a Cupertino-style action sheet.'),
            //     actions: [
            //       CupertinoActionSheetAction(
            //         child: Text('Option 1'),
            //         onPressed: () => Navigator.of(context).pop(),
            //       ),
            //       CupertinoActionSheetAction(
            //         child: Text('Option 2'),
            //         onPressed: () => Navigator.of(context).pop(),
            //       ),
            //     ],
            //     cancelButton: CupertinoActionSheetAction(
            //       child: Text('Cancel'),
            //       onPressed: () => Navigator.of(context).pop(),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),

      // bottomNavigationBar: BottomNavigationBar(items: []),
    );
  }
}
