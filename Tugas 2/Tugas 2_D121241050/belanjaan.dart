void main() {
  // 01. Menyimpan daftar harga (built-in type: Map)
  Map<String, int> daftarHarga = {
    'Roti': 15000,
    'Susu': 20000,
    'Telur': 30000,
    'Gula': 13000,
  };

  // 02. Menyimpan daftar belanjaan (built-in type: List)
  List<String> daftarBelanjaan = ['Roti', 'Susu', 'Telur'];

  // Hitung total belanja sebelum diskon
  int totalBelanja = hitungTotal(daftarBelanjaan, daftarHarga);

  // 03. Menentukan case diskon belanjaan (function + if/else if/else)
  double diskon = tentukanDiskon(totalBelanja);

  // 04. Menampilkan total akhir belanjaan
  int totalAkhir = (totalBelanja - (totalBelanja * diskon)).toInt();

  print('Daftar Belanjaan : $daftarBelanjaan');
  print('Total Belanja    : Rp$totalBelanja');
  print('Diskon           : ${(diskon * 100).toInt()}%');
  print('Total Akhir      : Rp$totalAkhir');
}

// Function untuk menghitung total belanja
int hitungTotal(List<String> belanjaan, Map<String, int> harga) {
  int total = 0;
  for (String item in belanjaan) {
    if (harga.containsKey(item)) {
      total += harga[item]!;
    }
  }
  return total;
}

// Function untuk menentukan diskon berdasarkan total belanja
double tentukanDiskon(int total) {
  if (total >= 100000) {
    return 0.2; // diskon 20%
  } else if (total >= 50000) {
    return 0.1; // diskon 10%
  } else if (total >= 20000) {
    return 0.05; // diskon 5%
  } else {
    return 0.0; // tidak ada diskon
  }
}
