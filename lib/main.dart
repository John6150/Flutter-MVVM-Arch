import 'package:first_project/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  // bool firstRun = await IsFirstRun.isFirstRun();
  await dotenv.load();
  runApp(ProviderScope(child: MyApp()));
}
