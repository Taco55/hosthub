import 'package:flutter/widgets.dart';

import 'api_client.dart';

class ApiClientLifecycleObserver with WidgetsBindingObserver {
  ApiClientLifecycleObserver(this._apiClient);

  final ApiClient _apiClient;
  bool _registered = false;
  bool _hasEverResumed = false;

  void initialize() {
    if (_registered) return;
    final binding = WidgetsBinding.instance;
    final initialState = binding.lifecycleState;
    if (initialState == AppLifecycleState.resumed) {
      _hasEverResumed = true;
    }
    binding.addObserver(this);
    _registered = true;
  }

  void dispose() {
    if (!_registered) return;
    WidgetsBinding.instance.removeObserver(this);
    _registered = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _hasEverResumed = true;
        _apiClient.markResume();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        _apiClient.cancelActiveRequests('app_background');
        break;
      case AppLifecycleState.detached:
        _apiClient.cancelActiveRequests('app_detached');
        break;
      case AppLifecycleState.hidden:
        if (!_hasEverResumed) {
          break;
        }
        _apiClient.cancelActiveRequests('app_hidden');
        break;
    }
  }
}
