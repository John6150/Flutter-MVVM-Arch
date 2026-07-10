import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class IncreamentNotifier extends StateNotifier<int> {
  IncreamentNotifier() : super(0);

  void increament() {
    state++;
  }

  void decreament() {
    state--;
  }
}

final increamentProvider = StateNotifierProvider<IncreamentNotifier, int>((
  ref,
) {
  return IncreamentNotifier();
});

// StateAsyncNotifier is used to manage state that can be asynchronously loaded or updated. It allows you to handle asynchronous operations and manage the state accordingly. In this case, it is used to manage an integer state that can be incremented asynchronously.

class IncreamentViewModel extends AsyncNotifier<int> {
  // IncreamentViewModel() : super();

  // @override
  // Future<int> build() => Future.value(0);

  @override
  Future<int> build() async {
    state = AsyncLoading();
    print('IncreamentViewModel build method called');
    await Future.delayed(Duration(seconds: 2), () {
      state = AsyncData(0);
    });
    return 0;
  }

  Future<void> increament(BuildContext context) async {
    state = AsyncLoading();
    await Future.delayed(Duration(seconds: 2));
    state = AsyncData(state.value! + 1);
    // ref.watch(provider)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Incremented to ${state.value}'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> decreament() async {
    state = AsyncLoading();
    await Future.delayed(Duration(seconds: 2));
    state = AsyncData(state.value! - 1);
  }
}

final increamentVMProvider = AsyncNotifierProvider<IncreamentViewModel, int>(
  // () => IncreamentViewModel(),
  IncreamentViewModel.new,
);

class LocatorViewModel extends AsyncNotifier<Position?> {
  Future<Position> build() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<List<Placemark>> locateMe({
    required double long,
    required double lat,
  }) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    // final Geocoding _geocoding = Geocoding();
    // PlaceMark placeMark = await placemarkFromCoordinates(37.4219983, -122.084);
    return placemarks;
  }
}

final locatorProvider = AsyncNotifierProvider<LocatorViewModel, Position?>(
  LocatorViewModel.new,
);

class RecordAudio extends AsyncNotifier<bool> {
  // A single recorder instance for the lifetime of this notifier, so the same
  // object that starts the recording is the one that stops it. Stopping is what
  // finalizes the WAV header (writes the data-chunk size back). Using a fresh
  // AudioRecorder to stop leaves the file with an invalid header, which makes
  // playback fail with MEDIA_ERROR_UNKNOWN.
  final AudioRecorder _record = AudioRecorder();

  @override
  Future<bool> build() async {
    ref.onDispose(() {
      _record.dispose();
    });
    state = AsyncLoading();
    await Future.delayed(Duration(seconds: 2));
    state = AsyncData(false);
    return false;
  }

  Future<String?> recording() async {
    if (!await _record.hasPermission()) {
      return Future.error('Permission denied');
    }

    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final recordingFilePath = '${appDocumentsDir.path}/my_recording.wav';

    if (state.value == false) {
      await _record.start(
        const RecordConfig(
          sampleRate: 44100,
          bitRate: 128000,
          encoder: AudioEncoder.wav,
        ),
        path: recordingFilePath,
      );
      state = AsyncData(true);
      return null;
    } else {
      // stop() returns the finalized file path once the header is written.
      final path = await _record.stop();
      state = AsyncData(false);

      final resolvedPath = path ?? recordingFilePath;
      final file = File(resolvedPath);
      if (await file.exists() && (await file.length()) > 0) {
        return resolvedPath;
      }
      return null;
    }
  }
}

final recordAudioProvider = AsyncNotifierProvider<RecordAudio, bool>(
  RecordAudio.new,
);
