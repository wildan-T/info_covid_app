import 'package:flutter/material.dart';
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
  final _stream = Supabase.instance.client
      .from('covid_data')
      .stream(primaryKey: ['id'])
      .order('kota');

  Future<void> _deleteData(int id) async {
    // Fungsi ini hanya bisa dijalankan oleh Admin
    await Supabase.instance.client.from('covid_data').delete().match({
      'id': id,
    });
  }

  void _showProfileDialog() {
    // Sesuai Activity & Sequence Diagram, ada menu ke profil
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final dataList = snapshot.data!;
          if (dataList.isEmpty) {
            return const Center(child: Text('Belum ada data tersedia.'));
          }

          return ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final data = dataList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    data['kota'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Total: ${data['total']} | Sembuh: ${data['sembuh']} | Dirawat: ${data['dirawat']} | Wafat: ${data['meninggal']}',
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
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                UpsertScreen(covidData: data),
                                      ),
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteData(data['id']),
                              ),
                            ],
                          )
                          : null, // Tamu tidak punya tombol aksi
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          widget.isAdmin
              ? FloatingActionButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpsertScreen()),
                    ),
                child: const Icon(Icons.add),
                tooltip: 'Tambah Data',
              )
              : null, // Tamu tidak punya FAB
    );
  }
}
