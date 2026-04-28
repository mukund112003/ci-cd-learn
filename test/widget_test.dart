import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:to_do/main.dart';
import 'package:to_do/screens/todo_list_screen.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for tests to ensure the database operations don't fail
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App renders TodoListScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the FutureBuilder/async fetch in TodoListScreen to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify if the 'My To-Dos' AppBar title is rendered correctly.
    expect(find.text('My To-Dos'), findsWidgets);
    
    // Verify that the list screen is there (typically it shows a list, empty message or error).
    expect(find.byType(TodoListScreen), findsOneWidget);
    
    // Verify an add button logic exists (FAB icon test).
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
