import 'package:api/screens/instructorprogram.dart';
import 'package:api/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';
import 'package:api/models/api_response.dart';
import 'package:api/models/user.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentTab = 0;
  final List<Widget> screens = [
    FutureBuilder<ApiResponse<User>>(
      future: getUserDetail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          String? instructorId = snapshot.data!.data?.personId.toString();
          return InstructorProgram(instructorId: instructorId ?? '');
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Center(
              child: Text('No se pudo obtener los detalles del usuario'));
        }
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SIGAC'),
        backgroundColor: const Color.fromARGB(255, 40, 233, 47),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              logout().then((value) => {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Login()),
                        (route) => false)
                  });
            },
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: CircularNotchedRectangle(),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.listCheck, color: Colors.green),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.personWalkingArrowRight,
                    color: Colors.green),
                label: ''),
          ],
          currentIndex: currentTab,
          onTap: (val) => setState(() {
            currentTab = val;
          }),
        ),
      ),
      body: screens[currentTab],
    );
  }
}
