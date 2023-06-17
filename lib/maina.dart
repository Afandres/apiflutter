import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Apprentice {
  final int id;
  final String name;
  final int documentNumber;
  final String email;
  final int telephone;
  final int courseId;

  Apprentice({
    required this.id,
    required this.name,
    required this.documentNumber,
    required this.email,
    required this.telephone,
    required this.courseId,
  });

  factory Apprentice.fromJson(Map<String, dynamic> json) {
    return Apprentice(
      id: json['id'],
      name: json['name'],
      documentNumber: json['document_number'],
      email: json['email'],
      telephone: json['telephone'],
      courseId: json['course_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'document_number': documentNumber,
      'email': email,
      'telephone': telephone,
      'course_id': courseId,
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Aprendices',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PantallaListaAprendices(),
    );
  }
}

class PantallaListaAprendices extends StatefulWidget {
  @override
  _PantallaListaAprendicesState createState() =>
      _PantallaListaAprendicesState();
}

class _PantallaListaAprendicesState extends State<PantallaListaAprendices> {
  late Future<List<Apprentice>> futureListaAprendices;

  @override
  void initState() {
    super.initState();
    futureListaAprendices = obtenerListaAprendices();
  }

  Future<List<Apprentice>> obtenerListaAprendices() async {
    final response =
        await http.get(Uri.parse('http://10.192.144.116:8000/api/apprentices'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final aprendices = data.map((item) => Apprentice.fromJson(item)).toList();
      return aprendices;
    } else {
      throw Exception('Error al cargar la lista de aprendices');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Aprendices'),
      ),
      body: FutureBuilder<List<Apprentice>>(
        future: futureListaAprendices,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final apprentice = snapshot.data![index];
                return ListTile(
                  title: Text(
                    apprentice.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar la lista de aprendices'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
