import 'package:first_project/viewmodels/increament.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    final counter = ref.read(increamentProvider.notifier);
    final viewCounter = ref.watch(increamentProvider);

    final stateProviderTwo = ref.watch(increamentVMProvider);
    final setStateProvider = ref.read(increamentVMProvider.notifier);
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
          ],
        ),
      ),

      // bottomNavigationBar: BottomNavigationBar(items: []),
    );
  }
}
