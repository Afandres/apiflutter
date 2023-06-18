import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:api/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Apprentice {
  final int id;
  final String firstName;
  final String firstLastName;
  final String secondLastName;
  bool isAttended;
  String state;
  Apprentice({
    required this.id,
    required this.firstName,
    required this.firstLastName,
    required this.secondLastName,
    this.isAttended = false,
    this.state = '',
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
  DateTime currentDate = DateTime.now();
  List<dynamic> _programs = [];

  Future<List<dynamic>> fetchData() async {
    String date = DateFormat('yyyy-MM-dd').format(currentDate);
    String time = DateFormat('HH:mm:ss').format(currentDate);
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
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };
    String jsonBody = jsonEncode(body);
    final response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: jsonBody);
    print('Datos enviados: $body');
    print('Respuesta recibida: ${response.body}');
    if (response.statusCode == 200) {
      setState(() {
        for (var program in _programs) {
          for (var apprentice in program['course']['apprentices']) {
            if (apprentice['person_id'] == apprenticeId) {
              apprentice['isAttended'] = true;
              apprentice['state'] = state;
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

  Future<void> updatePrograms() async {
    List<dynamic> data = await fetchData();
    setState(() {
      _programs = data;
    });
  }

  Future<void> goToPreviousDate() async {
    setState(() {
      currentDate = currentDate.subtract(Duration(days: 1));
    });
    await updatePrograms();
  }

  Future<void> goToNextDate() async {
    setState(() {
      currentDate = currentDate.add(Duration(days: 1));
    });
    await updatePrograms();
  }

  @override
  void initState() {
    super.initState();
    updatePrograms();
  }

  @override
  Widget build(BuildContext context) {
    if (_programs.isEmpty) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: goToPreviousDate,
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(currentDate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: goToNextDate,
              ),
            ],
          ),
          Text(
            'No se encontró programación para esta fecha.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: goToPreviousDate,
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(currentDate),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: goToNextDate,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
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
                          state: apprentice['state'] ?? '',
                        );
                        var fullName =
                            '$firstName $firstLastName $secondLastName';
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FontAwesomeIcons.userPen),
                                SizedBox(width: 20),
                                Text(apprenticeObj.state),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      );
    }
  }
}
