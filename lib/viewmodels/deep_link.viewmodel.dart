import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:first_project/utils/navigation.dart';
import 'package:first_project/views/details.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeepLinkViewModel extends AsyncNotifier<Uri?> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  @override
  Future<Uri?> build() async {
    ref.onDispose(() => _subscription?.cancel());

    // Links received while the app is already running / backgrounded.
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error) => debugPrint('Deep link error: $error'),
    );

    // Link that cold-started the app from a terminated state.
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }
    return initialUri;
  }

  void _handleUri(Uri uri) {
    debugPrint('Received deep link: $uri');
    state = AsyncData(uri);

    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    // "/"
    // "/home"

    // www.facebook.com/ -host
    // profile/id?=ausduihchs8sdiusho98u987bsidtdwgee -path

    // flutterapp://7sdhy7fdgdyfdfhdu7dufhddetails/

    final segments = <String>[
      if (uri.host.isNotEmpty) uri.host,
      ...uri.pathSegments,
    ];
    if (segments.isEmpty) return;

    switch (segments.first) {
      case 'details':
        final id = uri.queryParameters['id'] ??
            (segments.length > 1 ? segments[1] : null);
        navigator.push(
          MaterialPageRoute(builder: (_) => DetailsView(id: id)),
        );
        break;
      case 'home':
        navigator.popUntil((route) => route.isFirst);
        break;
    }
  }
}

final deepLinkVMProvider = AsyncNotifierProvider<DeepLinkViewModel, Uri?>(
  DeepLinkViewModel.new,
);
