import 'package:floor/floor.dart';
import 'package:localstorage/entity/employee.dart';
import 'package:localstorage/dao/employeeDAO.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@Database(version: 1, entities: [Employee])
abstract class AppDatabase extends FloorDatabase {
  EmployeeDAO get employeeDAO;
}
