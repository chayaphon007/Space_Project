import 'package:flutter/material.dart';
import '../models/research_data.dart';
import '../database/db_helper.dart';

class ResearchProvider with ChangeNotifier {
  List<ResearchData> _data = [];

  List<ResearchData> get data => _data;

  Future<void> fetchData(String category) async {
    _data = await DBHelper.getDataByCategory(category);
    notifyListeners(); // ✅ โหลดข้อมูลใหม่และอัปเดต UI
  }

  Future<void> addData(ResearchData data) async {
    await DBHelper.insertData(data);
    await fetchData(data.category); // ✅ โหลดข้อมูลใหม่หลังเพิ่มข้อมูล
  }

  Future<void> updateData(ResearchData data) async {
    await DBHelper.updateData(data);
    await fetchData(data.category);
  }

  Future<void> deleteData(int id, String category) async {
    await DBHelper.deleteData(id);
    await fetchData(category);
  }
}
