import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/home/domain/entities/home_overview.dart';
import 'package:inspector_app/features/home/domain/usecases/get_home_overview_usecase.dart';

class HomeController extends ChangeNotifier {
  HomeController({required GetHomeOverviewUseCase getOverview}) : _getOverview = getOverview;

  final GetHomeOverviewUseCase _getOverview;

  HomeOverview? _overview;
  bool _isLoading = false;
  String? _error;
  Timer? _timer;

  HomeOverview? get overview => _overview;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _overview = await _getOverview();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
