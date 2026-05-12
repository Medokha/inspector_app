import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/profile/domain/entities/profile_overview.dart';
import 'package:inspector_app/features/profile/domain/usecases/get_profile_overview_usecase.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required GetProfileOverviewUseCase getOverview})
      : _getOverview = getOverview;

  final GetProfileOverviewUseCase _getOverview;

  ProfileOverview? _overview;
  bool _isLoading = false;
  String? _error;

  ProfileOverview? get overview => _overview;
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
}
