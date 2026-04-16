import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'komponen/jam_digital.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //memastikan engine flutter siap digunakan
  await Jiffy.setLocale('id'); //ubah atau setting bahasa jiffy ke id=indonesia
  runApp(const TimeMaster()); //run timemaster
}

class TimeMaster extends StatelessWidget {
  const TimeMaster({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //banner debug dihilangkan
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Color.fromARGB(255, 91, 61, 41)), //tema apk dengan material3 (versi terbaru dan lebih bagus daripada material2)
      home: const Beranda(), //menampilkan beranda sebagai home page
    );
  }
}

class Beranda extends StatefulWidget { //dia stateful buat bisa update data kegiatan 
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  final List<Map<String, dynamic>> _daftarKegiatan = []; //list buat nampung data kegiatan
  final TextEditingController _inputNamaKegiatan = TextEditingController(); //ngambil input text untuk nama kegiatan
  DateTime? _tanggalTerpilih; //ngambil input tanggal 

  void _tampilkanDialogTambah() { //munculin dialog untuk tambah kegiatan
    showDialog(
      context: context,
      builder: (context) => AlertDialog( //nampilin dialog
        title: const Text("Tambah Kegiatan Baru"), //judul dialog
        content: Column(
          mainAxisSize: MainAxisSize.min, //ukuran mengikuti isi
          children: [
            TextField(
              controller: _inputNamaKegiatan, //hubungin ke controller untuk ambil input nama kegiatannya
              decoration: const InputDecoration(labelText: "Nama Kegiatan"), //kasih label di text field nya
            ),
            const SizedBox(height: 15), //atur jarak widget (textfield sm button)
            ElevatedButton(
              onPressed: () async { //kalo dipencet menjalankan await
                DateTime? picked = await showDatePicker( //munculin date picker
                  context: context,
                  initialDate: DateTime.now(), //date default nya tanggal saat ini
                  firstDate: DateTime(2000), //tanggal pertama yang bisa dipilih dri tahun 2000
                  lastDate: DateTime(2100), //tanggal terakhir yg bisa dipilih dari 2100
                );
                if (picked != null) setState(() => _tanggalTerpilih = picked); //kalo tanggal dipilih state diubpdate
              },
              child: Text(_tanggalTerpilih == null //kalo tanggal blm dipilih namipilin 'pilih tanggal'
                  ? "Pilih Tanggal" 
                  : Jiffy.parseFromDateTime(_tanggalTerpilih!).yMMMMd), //kalo tgl udh dipilih nampilin format tanggal lengkap
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")), //tombol batal buat nutup dialog
          ElevatedButton(
            onPressed: () {
              if (_inputNamaKegiatan.text.isNotEmpty && _tanggalTerpilih != null) { //validasi input
                setState(() { //update ui pake data kegiatan baru
                  _daftarKegiatan.add({ //nambahin nama sm tanggal ke daftar kegiatan
                    "nama": _inputNamaKegiatan.text,
                    "tanggal": _tanggalTerpilih,
                  });
                  _inputNamaKegiatan.clear(); //kosongin input
                  _tanggalTerpilih = null; //reset tanggal
                });
                Navigator.pop(context); //nutup dialog
              }
            },
            child: const Text("Simpan"), //tombol simpan
          ),
        ],
      ),
    );
  }

  void _bukaDetail(Map<String, dynamic> data) { //fungsi buka detail kegiatan
  var j = Jiffy.parseFromDateTime(data['tanggal']); //ubah date time ke jiffy ambil dari data tanggal
  var skrg = Jiffy.now(); //ambil waktu sekarang pake jiffy disimpen ke skrg

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, //biar bisa di scroll
    backgroundColor: Color.fromARGB(255, 247, 232, 221),
    builder: (context) => Padding( 
      padding: const EdgeInsets.all(20), //kasih padding untuk jarak 
      child: SingleChildScrollView( //biar bisa scroll kalo isinya banyak
        child: Column(
          mainAxisSize: MainAxisSize.min, //biar pas seukuran isinya
          crossAxisAlignment: CrossAxisAlignment.start, //alingment/posisi rata kiri
          children: [
            //namipilin nama kegiatan
            Text(data['nama'], style: const TextStyle(color: Color.fromARGB(255, 91, 61, 41), fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(), //kasih garis pembatas (antara nama kegiatan sm daftar data nya)
            _teksDetail("📆 Tanggal", j.yMMMMEEEEd), //format data tanggal lengkap
            _teksDetail("⏳ Status", j.fromNow()), //status relatif waktu dari sekarang ke yg dipilih
            _teksDetail("🔢 Selisih", "${j.diff(skrg, unit: Unit.day)} hari lagi"), //selisih waktu dari skrg ke yg dipilih
            _teksDetail("🌙 Nama Bulan", j.MMMM), //nama bulan
            _teksDetail("🗓️ Minggu ke-", "${j.weekOfYear}"), //minggu ke brp di th tersebut
            _teksDetail("✨ Kabisat?", j.isLeapYear ? "Ya" : "Tidak"), //apakah tahun kabisat atau bukan
            _teksDetail("🏁 Awal Minggu", j.startOf(Unit.week).yMMMMd), //awal minggu dari tgl yg dipilih
            _teksDetail("🏁 Akhir Bulan", j.endOf(Unit.month).yMMMMd), //akhir bulan dari tgl yg dipilih
            _teksDetail("📅 Hari ke-", "${j.dayOfYear} dalam setahun"), //hari ke berapda dlm tahun tsb
            _teksDetail("🔍 Perbandingan", j.isBefore(skrg) ? "lampau" : "Mendatang"), //dia masa lampau atau masa mendatang
            const SizedBox(height: 20), 
          ],
        ),
      ),
    ),
  );
}

  Widget _teksDetail(String label, String isi) { //buat nampilin detail kegiatan
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("$label: $isi", style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) { //build ui
    return Scaffold(
      appBar: AppBar( //setting appbar
  title: const Text( //judul appbar
    "Sallie J'time",
    style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 225, 201)),
  ),
  centerTitle: true, //judul ditengah
  flexibleSpace: Container( //buat background appbar
    decoration: BoxDecoration( //setting warna background appbar
      color: const Color.fromARGB(255, 91, 61, 41),
    ),
  ),
  elevation: 0, //menghilangkan garis pembatas bawah biar mulus
),
      body: Column( //setting ui body
        children: [
          const SizedBox(height: 10), //kasih jarak (appbar sm jam digital)
          const JamDigital(), //jam Digital di atas
          const Padding( //setting judul daftar kegiatan
            padding: EdgeInsets.all(16.0), //jarak dari tepi layar
            child: Text("Daftar Kegiatan Anda:", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _daftarKegiatan.isEmpty
                ? const Center(child: Text("Belum ada kegiatan. Klik +")) //kalo daftar kegiatan kosong nampilin teks itu
                : ListView.builder( //nampilin list dinamis
                    itemCount: _daftarKegiatan.length, //jumlah daftar kegiatan
                    itemBuilder: (context, index) { //nampilin tiap item kegiatan
                      var item = _daftarKegiatan[index]; //ambil data kegiatan per index
                      var j = Jiffy.parseFromDateTime(item['tanggal']); //ubah date time ke jiffy ambil dari data tanggal
                      return Card( //card buat nampilin kegiatan
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), //atur jarak antar vard
                        child: ListTile( //buat nampilin kegiatan
                          leading: const Icon(Icons.event, color: Color.fromARGB(255, 91, 61, 41)), //atur icon tanggal
                          title: Text(item['nama']), //kasi judul nama kegiatan
                          subtitle: Text(j.fromNow()), //kasi subtitle status relaif waktu skrg ke tanggal yg dipilih
                          trailing: const Icon(Icons.chevron_right), //icon panah kanan
                          onTap: () => _bukaDetail(item), //pencet untuk buka detail kegiatan
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( //tombol buat tambah kegiatan
        onPressed: _tampilkanDialogTambah, //kalo dipencet nampilin dialog tambah kegiatan
        child: const Icon(Icons.add), //icon tambah
      ),
    );
  }
}