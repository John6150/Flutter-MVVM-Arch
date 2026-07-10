import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:first_project/viewmodels/increament.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
            onPressed: () {
              // counter.decreament();
              setStateProvider.decreament();
            },
            child: Icon(Icons.remove),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              // counter.increament();
              setStateProvider.increament(context);
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              final result = await ref
                  .read(recordAudioProvider.notifier)
                  .recording();
              print('Recording path: $result');
              setState(() {
                recordingPath = result;
              });

              // counter.increament();
              // setStateProvider.increament(context);
            },
            child: Icon(
              Icons.circle,
              color: isRecording ? Colors.red : Colors.black,
            ),
          ),
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
          ],
        ),
      ),

      // bottomNavigationBar: BottomNavigationBar(items: []),
    );
  }
}
