


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posapp/dashbord.dart';
import 'package:posapp/pages/loginpage.dart';
import 'package:posapp/pages/operations/operationitems.dart';
import 'package:posapp/route.dart';
import 'package:posapp/storage/bloc_statemanager.dart';
import 'package:posapp/storage/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


Future<void> main() async {
  // Only initialize FFI for desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    
    databaseFactory = databaseFactoryFfi;
  }
      // await DBHelper.deleteDatabaseFile(); // ← Add this only once

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>(
          create: (_) => OrderBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'POS App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home:   AppRouter(),
      
      ),
    ),
  );
}

