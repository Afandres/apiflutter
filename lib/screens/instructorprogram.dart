import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:api/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Apprentice {
  final int id;
  final String firstName;
  final String firstLastName;
  final String secondLastName;
  bool isAttended;

  Apprentice({
    required this.id,
    required this.firstName,
    required this.firstLastName,
    required this.secondLastName,
    this.isAttended = false,
  });
}

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
      setState(() {
        // Actualizar el estado de la asistencia del aprendiz
        for (var program in _programs) {
          for (var apprentice in program['course']['apprentices']) {
            if (apprentice['person_id'] == apprenticeId) {
              apprentice['isAttended'] = true;
              break;
            }
          }
        }
      });

      print('Asistencia tomada con éxito');
    } else {
      print('Error al tomar la asistencia');
    }
  }

  List<dynamic> _programs = [];

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        _programs = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_programs.isEmpty) {
      return CircularProgressIndicator();
    } else {
      return ListView.builder(
        itemCount: _programs.length,
        itemBuilder: (context, index) {
          var program = _programs[index];
          var apprentices = program['course']['apprentices'];
          var programId = program['id'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    program['course']['program']['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    program['course']['code'].toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    program['environment']['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: apprentices.length,
                itemBuilder: (context, index) {
                  var apprentice = apprentices[index];
                  var person = apprentice['person'];
                  var apprenticeId = apprentice['person_id'];
                  var firstName = person['first_name'];
                  var firstLastName = person['first_last_name'];
                  var secondLastName = person['second_last_name'];

                  var apprenticeObj = Apprentice(
                    id: apprenticeId,
                    firstName: firstName,
                    firstLastName: firstLastName,
                    secondLastName: secondLastName,
                    isAttended: apprentice['isAttended'] ?? false,
                  );

                  var fullName = '$firstName $firstLastName $secondLastName';

                  return ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      fullName,
                      style: TextStyle(
                        color: apprenticeObj.isAttended
                            ? Colors.green
                            : Colors.black,
                        fontWeight: apprenticeObj.isAttended
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('Aprendiz'),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'P',
                          child: Text('Presente'),
                        ),
                        PopupMenuItem<String>(
                          value: 'MF',
                          child: Text('Media Falla'),
                        ),
                        PopupMenuItem<String>(
                          value: 'FJ',
                          child: Text('Falla Justificada'),
                        ),
                        PopupMenuItem<String>(
                          value: 'FI',
                          child: Text('Falla Injustificada'),
                        ),
                      ],
                      onSelected: (value) {
                        takeAttendance(apprenticeId, value, programId);
                      },
                      child: Icon(FontAwesomeIcons.userPen),
                    ),
                  );
                },
              ),
              Divider(),
            ],
          );
        },
      );
    }
  }
}
