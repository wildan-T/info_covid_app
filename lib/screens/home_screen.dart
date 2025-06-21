import 'package:flutter/material.dart';
import 'package:info_covid_app/models/covid_data.dart';
import 'package:info_covid_app/controllers/covid_data_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'upsert_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  const HomeScreen({super.key, required this.isAdmin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<CovidData>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<List<CovidData>> _fetchData() async {
    final response = await Supabase.instance.client
        .from('covid_data')
        .select()
        .order('kota');

    final dataList = response.map((map) => CovidData.fromMap(map)).toList();
    return dataList;
  }

  Future<void> _refreshData() async {
    setState(() {
      _dataFuture = _fetchData() as Future<List<CovidData>>?;
    });
  }

  Future<void> _deleteData(int id) async {
    await Supabase.instance.client.from('covid_data').delete().match({
      'id': id,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _refreshData();
    }
  }

  Future<void> _showDeleteConfirmationDialog(int id, String kota) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus data untuk kota "$kota"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteData(id);
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfileDialog() {
    final user = Supabase.instance.client.auth.currentUser;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Profil Admin'),
            content: Text('Email: ${user?.email ?? ''}'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Supabase.instance.client.auth.signOut();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data COVID-19 Banten'),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: _showProfileDialog,
              tooltip: 'Profil',
            )
          else
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  ),
              child: const Text(
                'Login Admin',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: FutureBuilder<List<CovidData>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data tersedia.'));
          }
          final dataList = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final data = dataList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      data.kota,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Total: ${data.total} | Sembuh: ${data.sembuh} | Dirawat: ${data.dirawat} | Wafat: ${data.meninggal}',
                    ),
                    trailing:
                        widget.isAdmin
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                UpsertScreen(covidData: data),
                                      ),
                                    );
                                    _refreshData();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => _showDeleteConfirmationDialog(
                                        data.id,
                                        data.kota,
                                      ),
                                ),
                              ],
                            )
                            : null,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton:
          widget.isAdmin
              ? FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UpsertScreen()),
                  );
                  _refreshData();
                },
                child: const Icon(Icons.add),
                tooltip: 'Tambah Data',
              )
              : null,
    );
  }
}
