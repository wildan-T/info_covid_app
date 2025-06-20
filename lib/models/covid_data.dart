class CovidData {
  final int id;
  final String kota;
  final int sembuh;
  final int dirawat;
  final int meninggal;
  final int total;

  CovidData({
    required this.id,
    required this.kota,
    required this.sembuh,
    required this.dirawat,
    required this.meninggal,
    required this.total,
  });

  factory CovidData.fromMap(Map<String, dynamic> map) {
    return CovidData(
      id: map['id'] as int,
      kota: map['kota'] as String,
      sembuh: map['sembuh'] as int,
      dirawat: map['dirawat'] as int,
      meninggal: map['meninggal'] as int,
      total: map['total'] as int,
    );
  }
}
