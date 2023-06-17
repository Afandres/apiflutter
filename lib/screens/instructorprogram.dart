import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:api/constant.dart';

class InstructorProgram extends StatefulWidget {
  final String instructorId;

  const InstructorProgram({required this.instructorId});

  @override
  _InstructorProgramState createState() => _InstructorProgramState();
}

class _InstructorProgramState extends State<InstructorProgram> {
  String apiUrl = instructorprogramURL;

  Future<List<dynamic>> fetchData() async {
    DateTime now = DateTime.now();
    String date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    String time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    String url = '$apiUrl${widget.instructorId}/$date/$time';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> list = data['list'];
      return list;
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  Future<void> takeAttendance(
      int apprenticeId, String state, int programId) async {
    String apiUrl = attendanceURL;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      'person_id': apprenticeId.toString(),
      'state': state,
      'instructor_program_id': programId.toString(),
      'date': DateTime.now().toString().substring(0, 10),
    };
    String jsonBody = jsonEncode(body);

    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonBody);

    print('Datos enviados: $body');
    print('Respuesta recibida: ${response.body}');

    if (response.statusCode == 200) {
      print('Asistencia tomada con éxito');
    } else {
      print('Error al tomar la asistencia');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Listado de Aprendices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    var item = snapshot.data![index];
                    var apprentices = item['course']['apprentices'];
                    var programId =
                        item['id']; // Obtener el ID del programa aquí

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: apprentices.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            var apprentice = apprentices[index];
                            var person = apprentice['person'];
                            var apprenticeId = apprentice['person_id'];
                            var firstName = person['first_name'];
                            var firstLastName = person['first_last_name'];
                            var secondLastName = person['second_last_name'];

                            var fullName =
                                '$firstName $firstLastName $secondLastName';

                            return ListTile(
                              leading: Icon(Icons.person),
                              title: Text(fullName),
                              subtitle: Text('Aprendiz'),
                              trailing: PopupMenuButton<String>(
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'F',
                                    child: Text('F'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'MF',
                                    child: Text('MF'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'FJ',
                                    child: Text('FJ'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'FI',
                                    child: Text('FI'),
                                  ),
                                ],
                                onSelected: (value) {
                                  takeAttendance(
                                      apprenticeId, value, programId);
                                },
                                child: Icon(Icons.more_vert),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
