import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:async'; //untuk operasi async

class JamDigital extends StatefulWidget { //stateful karena waktu berubah tiap detik
  const JamDigital({super.key}); 

  @override
  State<JamDigital> createState() => _JamDigitalState(); //menghubungkan ke state untuk update waktu
}

class _JamDigitalState extends State<JamDigital> {
  late Timer _timer; //timer buat update waktu
  DateTime _waktuSekarang = DateTime.now(); //simpan waktu sekarang

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { //atur timer terupdate setiap detik
      if (mounted) { //mounted=pastiin widget masih aktif sblm update
        setState(() { //update state untuk refresh tampilan
          _waktuSekarang = DateTime.now(); //update waktu skrg
        });
      }
    });
  }

  @override
  void dispose() { //biar memori bersih saat widget dihancurkan/app ditutup
    _timer.cancel(); //matikan timer saat widget dihancurkan
    super.dispose(); //panggil dispose nya flutter
  }

  @override
  Widget build(BuildContext context) { //build ui jam digital
    var jiffy = Jiffy.parseFromDateTime(_waktuSekarang); //ubah waktu sekarang ke format nya jiffy

    return Container( //atur container jam digital
      width: double.infinity, //lebarnya penuh
      padding: const EdgeInsets.all(25), 
      decoration: BoxDecoration( //dekorasi kontainernya
        color: const Color.fromARGB(255, 229, 178, 140).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30), //atur sudut kontainernya
        border: Border.all(color: const Color.fromARGB(255, 49, 36, 31).withOpacity(0.5)),
      ),
      child: Column( //format kolom
        children: [
          const Text( //kasih teks
            "WAKTU SAAT INI",
            style: TextStyle(letterSpacing: 2, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            jiffy.format(pattern: 'HH:mm:ss'), //atur format jam
            style: const TextStyle(
              fontSize: 55,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 91, 61, 41),
            ),
          ),
          Text( //kasih teks format hari, tanggal, bulan
            jiffy.yMMMMEEEEd,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}