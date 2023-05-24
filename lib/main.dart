import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Apprentice {
  final String identificacion;
  final String nombre;
  bool asistencia;

  Apprentice({
    required this.identificacion,
    required this.nombre,
    required this.asistencia,
  });

  factory Apprentice.fromJson(Map<String, dynamic> json) {
    return Apprentice(
      identificacion: json['identificacion'].toString(),
      nombre: json['nombre'],
      asistencia: json['asistencia'] == "si" ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identificacion': identificacion,
      'nombre': nombre,
      'asistencia': asistencia ? 'si' : 'no',
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
        await http.get(Uri.parse('http://127.0.0.1:8000/api/apprentices'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final aprendices = data.map((item) => Apprentice.fromJson(item)).toList();
      return aprendices;
    } else {
      throw Exception('Error al cargar la lista de aprendices');
    }
  }

  Future<void> actualizarAsistencia(Apprentice apprentice) async {
    final response = await http.put(
      Uri.parse(
          'http://127.0.0.1:8000/api/apprentices${apprentice.identificacion}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(apprentice.toJson()),
    );

    if (response.statusCode == 200) {
      // Actualización exitosa
      print('Asistencia actualizada');
    } else {
      // Error al actualizar
      print('Error al actualizar la asistencia');
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
                    apprentice.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Identificación: ${apprentice.identificacion}'),
                      SwitchListTile(
                        title: Text('Asistencia'),
                        value: apprentice.asistencia,
                        onChanged: (value) {
                          setState(() {
                            apprentice.asistencia = value;
                          });
                          actualizarAsistencia(apprentice).then((_) {
                            // Actualización completada
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Asistencia actualizada'),
                              ),
                            );
                          }).catchError((error) {
                            // Error al actualizar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error al actualizar la asistencia'),
                              ),
                            );
                          });
                        },
                      ),
                    ],
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
