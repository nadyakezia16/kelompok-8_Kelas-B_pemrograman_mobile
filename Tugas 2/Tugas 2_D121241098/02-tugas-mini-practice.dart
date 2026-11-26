void main() {
  //menyimpan daftar harga menggunakan Map (built-in type)
  Map<String, int> daftarHarga = {
    'Buku': 10000,
    'Pensil': 3000,
    'Penggaris': 7000,
    'Tas': 150000
  };

  //menyimpan daftar belanjaan menggunakan List (built-in type)
  List<String> daftarBelanja = ['Buku', 'Pensil', 'Tas'];

  //menampilkan total akhir belanjaan
  hitungDanTampilkanTotal(daftarBelanja, daftarHarga);
}

//function untuk menghitung total dan menentukan diskon
void hitungDanTampilkanTotal(List<String> belanjaan, Map<String, int> hargaBarang) {
  int totalAwal = 0;

  for (var item in belanjaan) {
    if (hargaBarang.containsKey(item)) {
      totalAwal += hargaBarang[item]!;
    }
  }

  double persenDiskon = 0.0;

  //menentukan case diskon dengan if / else if / else & operator comparison
  if (totalAwal >= 50000) {
    persenDiskon = 0.20; //diskon 20%
  } else if (totalAwal >= 30000) {
    persenDiskon = 0.10; //diskon 10%
  } else {
    persenDiskon = 0.0;  //tanpa diskon
  }

  double totalDiskon = totalAwal * persenDiskon;
  double totalAkhir = totalAwal - totalDiskon;

  print('Total Belanja Awal : Rp$totalAwal');
  print('Diskon (${persenDiskon * 100}%)     : Rp${totalDiskon.toInt()}');
  print('Total Akhir        : Rp${totalAkhir.toInt()}');
}
