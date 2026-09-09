void main() {
  // 1. Menyimpan daftar harga
  Map<String, int> harga = {
    "Nasi Ayam Sambal Matah": 30000,
    "Bakmi Ori": 25000,
    "Mie Goreng Jawa": 28000,
    "Kopi Hitam": 23000,
    "Kopi Aren": 25000,
    "Air Mineral": 8000,
  };

  // 2. Menyimpan daftar belanjaan
  List<String> daftarBelanja = [
    "Nasi Ayam Sambal Matah",
    "Mie Goreng Jawa",
    "Air Mineral",
    "Kopi Aren",
  ];

  // Menghitung total belanja
  int total = hitungTotal(daftarBelanja, harga);

  // 3. Menentukan diskon
  double diskon = hitungDiskon(total);

  // Menghitung nilai diskon
  double nilaiDiskon = total * diskon;

  // 4. Menghitung total akhir
  double totalAkhir = total - nilaiDiskon;

  // Menampilkan hasil
  print("=== DAFTAR BELANJA ===");

  for (String barang in daftarBelanja) {
    print("$barang: Rp${harga[barang]}");
  }

  print("\nTotal Belanja : Rp$total");
  print("Diskon        : ${(diskon * 100).toInt()}%");
  print("Nilai Diskon  : Rp${nilaiDiskon.toInt()}");
  print("Total Akhir   : Rp${totalAkhir.toInt()}");
}


// Function untuk menghitung total belanja
int hitungTotal(
    List<String> daftarBelanja,
    Map<String, int> harga) {

  int total = 0;

  for (String barang in daftarBelanja) {
    total += harga[barang]!;
  }

  return total;
}


// Function untuk menentukan diskon
double hitungDiskon(int total) {
  if (total >= 100000) {
    return 0.20;
  } else if (total >= 50000) {
    return 0.10;
  } else if (total >= 25000) {
    return 0.05;
  } else {
    return 0;
  }
}