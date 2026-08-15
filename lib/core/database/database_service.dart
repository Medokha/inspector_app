/// تخزين مؤقت بسيط للتقارير غير المتزامنة (بدون sqflite).
class DatabaseService {
  static final List<Map<String, dynamic>> _offlineReports = <Map<String, dynamic>>[];
  static int _nextId = 1;

  Future<int> saveReport(Map<String, dynamic> report) async {
    final id = _nextId++;
    _offlineReports.add(<String, dynamic>{
      ...report,
      'id': id,
      'isSynced': report['isSynced'] ?? 0,
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> getUnsyncedReports() async {
    return _offlineReports.where((r) => (r['isSynced'] as int?) == 0).toList();
  }

  Future<int> markAsSynced(int id) async {
    final index = _offlineReports.indexWhere((r) => r['id'] == id);
    if (index < 0) return 0;
    _offlineReports[index]['isSynced'] = 1;
    return 1;
  }
}
