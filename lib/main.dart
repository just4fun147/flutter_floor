import 'package:faker/faker.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:localstorage/dao/employeeDAO.dart';
import 'package:localstorage/database/database.dart';
import 'package:localstorage/entity/employee.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database =
      await $FloorAppDatabase.databaseBuilder('edmt database.db').build();
  final dao = database.employeeDAO;

  runApp(MyApp(dao: dao));
}

class MyApp extends StatelessWidget {
  final EmployeeDAO dao;

  MyApp({required this.dao});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', dao: dao),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, required this.dao});

  final EmployeeDAO dao;

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final GlobalKey<ScaffoldMessengerState> scaffoldKey =
    //     GlobalKey<ScaffoldMessengerState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final employee = Employee(
                    firstName: Faker().person.firstName(),
                    lastName: Faker().person.lastName(),
                    email: Faker().internet.email());
                await widget.dao.insertEmployee(employee);

                // ScaffoldMessenger.of(context)
                //     .showSnackBar(scaffoldKey.currentState, 'Clear Success');
              }),
          IconButton(
              icon: Icon(Icons.clear),
              onPressed: () async {
                await widget.dao.deleteAllEmployee();
                setState(() {});
                // ScaffoldMessenger.of(context)
                //     .showSnackBar(scaffoldKey.currentState, 'Clear Success');
              })
        ],
      ),
      body: StreamBuilder(
        stream: widget.dao.getAllEmployee(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            var listEmployee = snapshot.data as List<Employee>;
            return ListView.builder(
              itemCount: listEmployee != null ? listEmployee.length : 0,
              itemBuilder: (context, index) {
                return Slidable(
                  child: ListTile(
                    title: Text(
                        '${listEmployee[index].firstName} ${listEmployee[index].lastName}'),
                    subtitle: Text('${listEmployee[index].email}'),
                  ),
                  actionPane: SlidableDrawerActionPane(),
                  secondaryActions: [
                    IconSlideAction(
                      caption: 'Update',
                      color: Colors.blue,
                      icon: Icons.update,
                      onTap: () async {
                        final updateEmployee = listEmployee[index];

                        updateEmployee.firstName = Faker().person.firstName();
                        updateEmployee.lastName = Faker().person.lastName();
                        updateEmployee.email = Faker().internet.email();

                        await widget.dao.updateEmployee(updateEmployee);
                      },
                    ),
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () async {
                        final deleteEmployee = listEmployee[index];

                        await widget.dao.deleteEmployee(deleteEmployee);
                      },
                    )
                  ],
                );
              },
            );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }
}
