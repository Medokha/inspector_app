import 'package:flutter/foundation.dart';
import 'package:inspector_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:inspector_app/features/auth/domain/entities/user.dart';
import 'package:inspector_app/features/auth/domain/repositories/auth_repository.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository repository,
    required AuthLocalDataSource localDataSource,
  })  : _repository = repository,
        _localDataSource = localDataSource;

  final AuthRepository _repository;
  final AuthLocalDataSource _localDataSource;

  User? _user;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;

  Future<void> initialize() async {
    _user = await _localDataSource.getUser();
    _isInitialized = true;
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }
}
