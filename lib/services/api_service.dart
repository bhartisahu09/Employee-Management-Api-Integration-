import 'dart:convert';
import 'package:employee_management_app/utils/app_pref.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

//mock fake api
class ApiService {
  static const String BASE_URL = 'https://reqres.in/api';
  static const String token = 'reqres-free-v1'; // Free API key for ReqRes

  static Future<Map<String, String>> getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': token,
    };
    debugPrint('Token: $token');
    debugPrint('Headers JSON: ${jsonEncode(headers)}');
    return headers;
  }

  Future<List<Employee>> getAllEmployees() async {
    String url = '${BASE_URL}/users';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        return data.map((e) => Employee.fromJsonReqRes(e)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  Future<Employee> getEmployeeById(int id) async {
    String url = '${BASE_URL}/users/$id';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        return Employee.fromJsonReqRes(json.decode(response.body)['data']);
      } else {
        throw Exception('Failed to load employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load employee: $e');
    }
  }

  Future<void> createEmployee(Employee employee) async {
    String url = '${BASE_URL}/users';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await getHeaders(),
        body: json.encode(employee.toReqResJson()),
      );
      print('Create Employee Status: ${response.statusCode}');
      print('Create Employee Body: ${response.body}');
      if (response.statusCode != 201) {
        throw Exception(
            'Failed to create employee: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Create Employee Exception: $e');
      throw Exception('Failed to create employee: $e');
    }
  }

  Future<void> updateEmployee(int id, Employee employee) async {
    String url = '${BASE_URL}/users/$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await getHeaders(),
        body: json.encode(employee.toReqResJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<void> deleteEmployee(int id) async {
    String url = '${BASE_URL}/users/$id';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: await getHeaders(),
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }
} 


// real api service code
// import 'dart:convert';
// import 'package:employee_management_app/utils/app_pref.dart';
// import 'package:http/http.dart' as http;
// import '../models/employee.dart';

// class ApiService {
//   static const String BASE_URL = 'https://reqres.in/api';
//   //static const String apiKey = 'reqres-free-v1'; // Free API key for ReqRes

//   Future<List<Employee>> getAllEmployees() async {
//     String url =
//         '${BASE_URL}/users';
//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           "Authorization": 'Bearer ${await AppPreference.getToken()}',
//           "Content-Type": "application/json",
//         },
//       );

//       if (response.statusCode == 200) {
//         final List data = json.decode(response.body)['data'];
//         return data.map((e) => Employee.fromJsonReqRes(e)).toList();
//       } else {
//         throw Exception('Failed to load employees: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load employees: $e');
//     }
//   }

//   Future<Employee> getEmployeeById(int id) async {
//     String url =
//         '${BASE_URL}/users/$id';
//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           "Authorization": 'Bearer ${await AppPreference.getToken()}',
//           "Content-Type": "application/json",
//         },
//       );
//       if (response.statusCode == 200) {
//         return Employee.fromJsonReqRes(json.decode(response.body)['data']);
//       } else {
//         throw Exception('Failed to load employee: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load employee: $e');
//     }
//   }

//   Future<void> createEmployee(Employee employee) async {
//      String url =
//         '${BASE_URL}/users';
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           "Authorization": 'Bearer ${await AppPreference.getToken()}',
//           "Content-Type": "application/json",
//         },
//         body: json.encode(employee.toReqResJson()),
//       );
//       print('Create Employee Status: ${response.statusCode}');
//       print('Create Employee Body: ${response.body}');
//       if (response.statusCode != 201) {
//         throw Exception('Failed to create employee: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       print('Create Employee Exception: $e');
//       throw Exception('Failed to create employee: $e');
//     }
//   }

//   Future<void> updateEmployee(int id, Employee employee) async {
//       String url =
//         '${BASE_URL}/users/$id';
//     try {
//       final response = await http.put(
//        Uri.parse(url),
//         headers: {
//           "Authorization": 'Bearer ${await AppPreference.getToken()}',
//           "Content-Type": "application/json",
//         },
//         body: json.encode(employee.toReqResJson()),
//       );
//       if (response.statusCode != 200) {
//         throw Exception('Failed to update employee: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to update employee: $e');
//     }
//   }

//   Future<void> deleteEmployee(int id) async {
//     String url =
//         '${BASE_URL}/users/$id';
//     try {
//       final response = await http.delete(
//         Uri.parse(url),
//         headers: {
//           "Authorization": 'Bearer ${await AppPreference.getToken()}',
//           "Content-Type": "application/json",
//         },
//       );
//       if (response.statusCode != 204) {
//         throw Exception('Failed to delete employee: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to delete employee: $e');
//     }
//   }
// } 