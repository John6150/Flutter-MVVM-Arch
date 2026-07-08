import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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
