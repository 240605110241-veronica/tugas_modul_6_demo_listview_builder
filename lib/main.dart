import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<dynamic> dataGame = [];
  bool sedangMemuat = true;
  String? pesanError;

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  Future<void> _ambilData() async {
    setState(() {
      sedangMemuat = true;
      pesanError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://www.freetogame.com/api/games'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          dataGame = data.take(20).toList();
          sedangMemuat = false;
        });
      } else {
        throw Exception('Gagal mengambil data game.');
      }
    } catch (e) {
      setState(() {
        pesanError = 'Data game tidak dapat dimuat. Periksa koneksi internet.';
        sedangMemuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Game'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isiHalaman(),
    );
  }

  Widget _isiHalaman() {
    if (sedangMemuat) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pesanError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pesanError!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _ambilData,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: dataGame.length,
      itemBuilder: (context, index) {
        final game = dataGame[index];

        return _listItem(
          context,
          url: game['thumbnail'] ?? '',
          judul: game['title'] ?? 'Tidak ada judul',
          genre: game['genre'] ?? 'Tidak ada genre',
          rilis: game['release_date'] ?? 'Tanggal tidak tersedia',
        );
      },
    );
  }
}

Widget _listItem(
    BuildContext context, {
      required String url,
      required String judul,
      required String genre,
      required String rilis,
    }) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url.isEmpty
              ? _gambarPengganti()
              : Image.network(
            url,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (context, error, stackTrace) {
              return _gambarPengganti();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                genre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                rilis,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _tombolBaca(context, judul, genre, rilis),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _gambarPengganti() {
  return Container(
    width: 90,
    height: 90,
    color: Colors.orange.shade100,
    child: const Icon(Icons.videogame_asset, size: 40, color: Colors.orange),
  );
}

Widget _tombolBaca(
    BuildContext context,
    String judul,
    String genre,
    String rilis,
    ) {
  return InkWell(
    borderRadius: BorderRadius.circular(15),
    onTap: () {
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(judul),
            content: Text(
              'Genre: $genre\nTanggal rilis: $rilis',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Baca Info',
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}