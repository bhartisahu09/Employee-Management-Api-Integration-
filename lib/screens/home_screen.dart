import 'package:employee_management_app/utils/color_constant.dart';
import 'package:employee_management_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../models/employee.dart';
import '../widgets/generic_data_table.dart';
import 'add_employee_screen.dart';
import 'edit_employee_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee')),
      body: ColoredBox(
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: backgroundLight,
                  border: Border.all(
                    color: lightGrey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Consumer<EmployeeProvider>(
                            builder: (context, provider, _) {
                              return CustomButton(
                                buttonColor: ACCENT_COLOR,
                                buttonHeight: 40,
                                buttonWidth: 120,
                                textColor: Colors.white,
                                buttonText: '+ Add New',
                                topRightRadius: 8,
                                topLeftRadius: 8,
                                bottomRightRadius: 8,
                                bottomLeftRadius: 8,
                                onButtonPress: () async {
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    barrierLabel: 'Dialog',
                                    barrierColor: Colors.black.withOpacity(0.2),
                                    transitionDuration: const Duration(milliseconds: 200),
                                    transitionBuilder: (context, anim1, anim2, child) {
                                      return FadeTransition(
                                        opacity: anim1,
                                        child: child,
                                      );
                                    },
                                    pageBuilder: (context, anim1, anim2) {
                                      return Center(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: ChangeNotifierProvider.value(
                                            value: Provider.of<EmployeeProvider>(context, listen: false),
                                            child: const AddEmployeeScreen(),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Consumer<EmployeeProvider>(
                          builder: (context, provider, _) {
                            if (provider.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (provider.error != null) {
                              return Center(child: Text(provider.error!));
                            }
                            if (provider.employees.isEmpty) {
                              return const Center(child: Text('No employees found.'));
                            }
                            final tableData = employeesToTableData(provider.employees);
                            return GenericDataTable(
                              data: tableData,
                              editableFields: const [],
                              ignoredFields: [],
                              onRowUpdate: (updatedRows) {},
                              editCallBack: (row) => employeeDataEdit(context, row, provider),
                              deleteCallBack: (row) => employeeDataDelete(context, row, provider),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void employeeDataEdit(BuildContext context, Map<String, dynamic> row, EmployeeProvider provider) {
    final employee = provider.employees.firstWhere((e) => e.id == row['id']);
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ChangeNotifierProvider.value(
              value: Provider.of<EmployeeProvider>(context, listen: false),
              child: EditEmployeeScreen(employee: employee),
            ),
          ),
        );
      },
    );
  }

  void employeeDataDelete(BuildContext context, Map<String, dynamic> row, EmployeeProvider provider) {
    debugPrint('_handleDelete called for row: $row');
    showDeleteDialog(context, row, provider);
  }
}

List<Map<String, dynamic>> employeesToTableData(List<Employee> employees) {
  return employees.map((e) => {
    'id': e.id,
    'first_name': e.name,
    'last_name': e.lastName,
    'email': e.email,
    'salary': e.salary,
    'age': e.age,
  }).toList();
}
Future<void> showDeleteDialog(
  BuildContext context,
  Map<String, dynamic> row,
  EmployeeProvider provider,
) async {
  debugPrint('showDeleteDialog called for row: $row');

  final int? employeeId = row['id'] is int ? row['id'] : int.tryParse(row['id'].toString());
  final String employeeName = row['first_name']?.toString() ?? 'Employee';

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete $employeeName?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              debugPrint('Delete cancelled');
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              debugPrint('Delete confirmed for ID: $employeeId');
              Navigator.of(dialogContext).pop();
              try {
                if (employeeId != null) {
                  await provider.deleteEmployee(employeeId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$employeeName deleted successfully'), backgroundColor: Colors.green,),
                    
                  );
                  debugPrint('Employee deleted successfully');
                } else {
                  throw Exception('Invalid Employee ID');
                }
              } catch (e) {
                debugPrint('Error deleting employee: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete employee')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
