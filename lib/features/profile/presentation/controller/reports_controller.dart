import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/profile/domain/entities/report_item.dart';
import 'package:inspector_app/features/profile/domain/repositories/profile_repository.dart';

class ReportsController extends ChangeNotifier {
  ReportsController({required ProfileRepository repository}) : _repository = repository;

  final ProfileRepository _repository;

  List<ReportItem> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<ReportItem> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _repository.getReports();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
