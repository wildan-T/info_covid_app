import 'package:flutter/material.dart';
import 'package:info_covid_app/models/covid_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Controller yang akan mengelola state dan logika bisnis
class CovidDataController extends ChangeNotifier {
  List<CovidData> _covidDataList = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters untuk diakses oleh UI (View)
  List<CovidData> get covidDataList => _covidDataList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor untuk memuat data awal
  CovidDataController() {
    fetchData();
  }

  // Method untuk mengambil data
  Future<void> fetchData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Beri tahu UI bahwa sedang loading

    try {
      final response = await Supabase.instance.client
          .from('covid_data')
          .select()
          .order('kota');

      _covidDataList = response.map((map) => CovidData.fromMap(map)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Beri tahu UI bahwa loading selesai (baik sukses maupun gagal)
    }
  }

  // Method untuk menghapus data
  Future<void> deleteData(int id) async {
    try {
      await Supabase.instance.client.from('covid_data').delete().match({
        'id': id,
      });
      // Setelah berhasil hapus, ambil data terbaru
      await fetchData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Method untuk menambah atau mengedit data
  Future<bool> submitData({
    required String kota,
    required String sembuh,
    required String dirawat,
    required String meninggal,
    CovidData? existingData, // null jika mode tambah, ada isinya jika mode edit
  }) async {
    try {
      final data = {
        'kota': kota,
        'sembuh': int.parse(sembuh),
        'dirawat': int.parse(dirawat),
        'meninggal': int.parse(meninggal),
        'total': int.parse(sembuh) + int.parse(dirawat) + int.parse(meninggal),
      };

      if (existingData == null) {
        // Mode Tambah
        await Supabase.instance.client.from('covid_data').insert(data);
      } else {
        // Mode Edit
        await Supabase.instance.client.from('covid_data').update(data).match({
          'id': existingData.id,
        });
      }

      // Ambil data terbaru setelah sukses
      await fetchData();
      return true; // Sukses
    } catch (e) {
      return false; // Gagal
    }
  }
}

// Provider untuk memungkinkan UI mengakses CovidDataController
final covidDataProvider = ChangeNotifierProvider((ref) {
  return CovidDataController();
});
