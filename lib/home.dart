import 'package:first_project/utils/navigation.dart';
import 'package:first_project/viewmodels/deep_link.viewmodel.dart';
import 'package:first_project/views/home.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Instantiate the deep-link viewmodel so it starts listening for incoming
    // links. `read` is enough here — we don't need to rebuild MyApp when a link
    // arrives; the viewmodel navigates via the root navigator key itself.
    ref.read(deepLinkVMProvider);

    return MaterialApp(
      title: 'First Flutter App',
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: const Home(),
    );
  }
}
