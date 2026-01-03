import "package:flutter/foundation.dart";

/// One saved sale record (from Report & Monitoring)
class SaleRecord {
  final String productName;
  final String productCode;
  final DateTime date; // date of save
  final int soldPieces;

  const SaleRecord({
    required this.productName,
    required this.productCode,
    required this.date,
    required this.soldPieces,
  });
}

/// Excel-like row computed for a given week
class InventoryWeekRow {
  final String productName;
  final String productCode;
  final DateTime initialDateInWeek; // first record date within week
  final int weekPieces;
  final double weekPercent; // 0..100

  const InventoryWeekRow({
    required this.productName,
    required this.productCode,
    required this.initialDateInWeek,
    required this.weekPieces,
    required this.weekPercent,
  });
}

class InventoryStore extends ChangeNotifier {
  final List<SaleRecord> _records = [];

  List<SaleRecord> get records => List.unmodifiable(_records);

  void addSaleRecord({
    required String productName,
    required String productCode,
    required DateTime date,
    required int soldPieces,
  }) {
    _records.add(
      SaleRecord(
        productName: productName,
        productCode: productCode,
        date: DateTime(date.year, date.month, date.day),
        soldPieces: soldPieces,
      ),
    );
    notifyListeners();
  }

  /// Returns computed "Excel rows" for the given week range (inclusive).
  List<InventoryWeekRow> buildWeekRows({
    required DateTime weekStart,
    required DateTime weekEnd,
  }) {
    final start = _dateOnly(weekStart);
    final end = _dateOnly(weekEnd);

    // Filter records inside the week
    final weekRecs = _records.where((r) {
      final d = _dateOnly(r.date);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();

    // Total weekly pieces across all products
    final totalWeekPieces = weekRecs.fold<int>(0, (sum, r) => sum + r.soldPieces);

    // Group by productCode (safer key than name)
    final Map<String, List<SaleRecord>> byProduct = {};
    for (final r in weekRecs) {
      byProduct.putIfAbsent(r.productCode, () => []).add(r);
    }

    final rows = <InventoryWeekRow>[];
    for (final entry in byProduct.entries) {
      final productCode = entry.key;
      final list = entry.value;

      // sort by date to get initial date in week
      list.sort((a, b) => a.date.compareTo(b.date));

      final productName = list.first.productName;
      final initialDate = list.first.date;
      final weekPieces = list.fold<int>(0, (sum, r) => sum + r.soldPieces);

      final weekPercent = totalWeekPieces == 0
          ? 0.0
          : (weekPieces / totalWeekPieces) * 100.0;

      rows.add(
        InventoryWeekRow(
          productName: productName,
          productCode: productCode,
          initialDateInWeek: initialDate,
          weekPieces: weekPieces,
          weekPercent: weekPercent,
        ),
      );
    }

    // Sort rows by highest weekPieces (like a report)
    rows.sort((a, b) => b.weekPieces.compareTo(a.weekPieces));
    return rows;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// Simple singleton store (UI-first). Later you can replace with Hive/Sqflite repository.
final inventoryStore = InventoryStore();

DateTime startOfWeekMonday(DateTime d) {
  final date = DateTime(d.year, d.month, d.day);
  final diff = date.weekday - DateTime.monday; // Monday=1
  return date.subtract(Duration(days: diff));
}

DateTime endOfWeekSunday(DateTime d) {
  final start = startOfWeekMonday(d);
  return start.add(const Duration(days: 6));
}

String fmtYmd(DateTime d) {
  final mm = d.month.toString().padLeft(2, "0");
  final dd = d.day.toString().padLeft(2, "0");
  return "${d.year}-$mm-$dd";
}
