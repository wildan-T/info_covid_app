import 'package:flutter/material.dart';
import 'package:info_covid_app/models/covid_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpsertScreen extends StatefulWidget {
  final CovidData? covidData;
  const UpsertScreen({super.key, this.covidData});

  @override
  State<UpsertScreen> createState() => _UpsertScreenState();
}

class _UpsertScreenState extends State<UpsertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kotaController = TextEditingController();
  final _sembuhController = TextEditingController();
  final _dirawatController = TextEditingController();
  final _meninggalController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.covidData != null) {
      _kotaController.text = widget.covidData!.kota;
      _sembuhController.text = widget.covidData!.sembuh.toString();
      _dirawatController.text = widget.covidData!.dirawat.toString();
      _meninggalController.text = widget.covidData!.meninggal.toString();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final sembuh = int.parse(_sembuhController.text);
      final dirawat = int.parse(_dirawatController.text);
      final meninggal = int.parse(_meninggalController.text);

      final data = {
        'kota': _kotaController.text.trim(),
        'sembuh': sembuh,
        'dirawat': dirawat,
        'meninggal': meninggal,
        'total': sembuh + dirawat + meninggal,
      };

      if (widget.covidData == null) {
        // Mode Tambah: Sesuai alur AddScreen
        await Supabase.instance.client.from('covid_data').insert(data);
      } else {
        // Mode Edit: Sesuai alur EditScreen
        await Supabase.instance.client.from('covid_data').update(data).match({
          'id': widget.covidData!.id,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan data')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.covidData == null ? 'Tambah Data' : 'Edit Data'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _kotaController,
              decoration: const InputDecoration(labelText: 'Nama Kota'),
            ),
            TextFormField(
              controller: _sembuhController,
              decoration: const InputDecoration(labelText: 'Jumlah Sembuh'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _dirawatController,
              decoration: const InputDecoration(labelText: 'Jumlah Dirawat'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _meninggalController,
              decoration: const InputDecoration(labelText: 'Jumlah Meninggal'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Simpan'),
                ),
          ],
        ),
      ),
    );
  }
}
