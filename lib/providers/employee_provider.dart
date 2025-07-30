import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? selectedFirstName;
  List<String> filteredLastNames = [];

  final ApiService employeeApiService = ApiService();
  List<Employee> _employees = [];
  List<Employee> _localEmployees = []; // Local storage
  bool _isLoading = false;
  String? _error;
  int _nextLocalId = 1000;

  List<Employee> get employees => [..._employees, ..._localEmployees];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dropdown Lists
  List<String> get firstNames => employees
      .map((e) => e.name)
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList();

  // Validation
  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter first name';
    if (value.trim().length < 2) return 'First name must be at least 2 characters';
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter last name';
    if (value.trim().length < 2) return 'Last name must be at least 2 characters';
    return null;
  }

  String? validateEmployeeEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter email';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  String? validateSalary(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter salary';
    final salary = int.tryParse(value);
    if (salary == null) return 'Please enter a valid number';
    if (salary <= 0) return 'Salary must be greater than 0';
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter age';
    final age = int.tryParse(value);
    if (age == null) return 'Please enter a valid number';
    if (age < 18 || age > 100) return 'Age must be between 18 and 100';
    return null;
  }
  
  //get all employees data
  Future<void> fetchEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _employees = await employeeApiService.getAllEmployees();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
  
  //add new employee
  Future<void> addEmployee(Employee employee) async {
    _isLoading = true;
    notifyListeners();
    try {
      await employeeApiService.createEmployee(employee);
      final newEmployee = Employee(
        id: _nextLocalId++,
        name: employee.name,
        lastName: employee.lastName,
        email: employee.email,
        salary: employee.salary,
        age: employee.age,
      );
      _localEmployees.add(newEmployee);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
  
  //update existing employee
  Future<void> updateEmployee(int id, Employee employee) async {
    _isLoading = true;
    notifyListeners();
    try {
      await employeeApiService.updateEmployee(id, employee);
      final apiIndex = _employees.indexWhere((e) => e.id == id);
      if (apiIndex != -1) _employees[apiIndex] = employee;

      final localIndex = _localEmployees.indexWhere((e) => e.id == id);
      if (localIndex != -1) _localEmployees[localIndex] = employee;

      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
  
  //delete employee
  Future<void> deleteEmployee(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await employeeApiService.deleteEmployee(id);
      _employees.removeWhere((e) => e.id == id);
      _localEmployees.removeWhere((e) => e.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearFormFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    salaryController.clear();
    ageController.clear();
    selectedFirstName = null;
    filteredLastNames = [];
  }
}
