import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/employee_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EmployeeManagementApp());
}

class EmployeeManagementApp extends StatelessWidget {
  const EmployeeManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeeProvider()..fetchEmployees(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Employee Management App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
