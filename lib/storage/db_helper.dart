// // Updated DBHelper with order_items and category summary logic
// import 'dart:convert';

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DBHelper {
//   static Database? _db;

//   static Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }

//   static Future<Database> _initDB() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'pos_items.db');

//     return await openDatabase(
//       path,
//       version: 3,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE items (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT
//           );
//         ''');

// await db.execute('''
//   CREATE TABLE sub_items (
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     item_id INTEGER,
//     name TEXT,
//     price REAL,
//     short_code TEXT,
//     unit TEXT,
//     description TEXT,
//     choice TEXT,
//     order_types TEXT,
//     image_path TEXT,
//     isvarient INTEGER,
//     hastoppings INTEGER,
//     variants TEXT,   -- 🔥 JSON ke liye
//     toppings TEXT    -- 🔥 JSON ke liye
//   )
// ''');




//          await db.execute('''
//   CREATE TABLE summary (
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//      order_id TEXT,
//    order_date TEXT,
//     order_type TEXT,
//     parent_name TEXT,
//     table_number TEXT,
//     person_count INTEGER,
//     subitem_name TEXT,
//     item_count INTEGER,
//     net_amount REAL,
//     discount REAL,
//     tax REAL,
//     total_sale REAL
  
//   );
// ''');
// // table data 
// // Add inside _initDB()
// await db.execute('''
//   CREATE TABLE tables (
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     table_number INTEGER,
//     location TEXT
//   );
// ''');





//         await db.execute('''
//           CREATE TABLE order_items (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             sub_item_id INTEGER,
//             quantity INTEGER,
//             FOREIGN KEY(sub_item_id) REFERENCES sub_items(id)
//           );
//         ''');
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 3) {
//           await db.execute('''
//             CREATE TABLE order_items (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               sub_item_id INTEGER,
//               quantity INTEGER,
//               FOREIGN KEY(sub_item_id) REFERENCES sub_items(id)
//             );
//           ''');
//         }
//       },
//     );
//   }

//   static Future<int> insertItem(String name) async {
//     final db = await database;
//     return await db.insert('items', {'name': name});
//   }

// static Future<void> insertSubItem(
//   int itemId,
//   String name,
//   double price, {
//   String? shortCode,
//   String? unit,
//   String? description,
//   String? choice,
//   String? orderTypes,
//   String? imagePath,
//   bool isvarient = false,
//   bool hastoppings = false,
//   List<Map<String, dynamic>> variants = const [],
  
//   List<Map<String, dynamic>> toppings = const [],
// }) async {
//   final db = await database;

//   await db.insert('sub_items', {
//     'item_id': itemId,
//     'name': name,
//     'price': price,
//     'short_code': shortCode,
//     'unit': unit,
//     'description': description,
//     'choice': choice,
//     'order_types': orderTypes,
//     'image_path': imagePath,
//     'isvarient': isvarient ? 1 : 0,
//     'hastoppings': hastoppings ? 1 : 0,
//     'variants': jsonEncode(variants),   // ✅ JSON encode before saving
//     'toppings': jsonEncode(toppings),   // ✅ JSON encode before saving
//   });
// }



// static Future<List<Map<String, dynamic>>> getItemsWithSubItems() async {
//   final db = await database;
//   final itemsRaw = await db.query('items');
//   List<Map<String, dynamic>> itemsWithSubs = [];

//   for (var item in itemsRaw) {
//     final subItems = await db.query(
//       'sub_items',
//       where: 'item_id = ?',
//       whereArgs: [item['id']],
//     );

//     // 🔥 JSON decode karke return karenge
//    final subItemsWithExtras = subItems.map((sub) {
//   final subWithExtras = Map<String, dynamic>.from(sub);

//   if (sub['variants'] != null && (sub['variants'] as String).isNotEmpty) {
//     subWithExtras['variants'] = jsonDecode(sub['variants'] as String);
//   } else {
//     subWithExtras['variants'] = [];
//   }

//   if (sub['toppings'] != null && (sub['toppings'] as String).isNotEmpty) {
//     subWithExtras['toppings'] = jsonDecode(sub['toppings'] as String);
//   } else {
//     subWithExtras['toppings'] = [];
//   }

//   return subWithExtras;
// }).toList();


//     final itemWithSubs = Map<String, dynamic>.from(item);
//     itemWithSubs['sub_items'] = subItemsWithExtras;
//     itemsWithSubs.add(itemWithSubs);
//   }

//   return itemsWithSubs;
// }



//   static Future<void> deleteDatabaseFile() async {
//   final dbPath = await getDatabasesPath();
//   final path = join(dbPath, 'pos_items.db');
//   await deleteDatabase(path);
// }



// static Future<void> insertCategorySummary(Map<String, dynamic> data) async {
//   final db = await database;

//   await db.insert('summary', data);
// }


  
//   static Future<void> insertCategoryDine(Map<String, dynamic> data) async {
//     final db = await database;
//     await db.insert('summaryDine', data);
//   }

// // static Future<List<Map<String, dynamic>>> getCategorySummary() async {
// //   final db = await database;
// //   return await db.query('summary', orderBy: 'id DESC'); // Show latest first
// // }

// static Future<List<Map<String, dynamic>>> getCategorySummary() async {
//   final db = await database;
//   return await db.rawQuery('''
//     SELECT 
//       parent_name,
//       subitem_name,
//        COUNT(DISTINCT order_id) AS orders, -- unique orders only
//       SUM(item_count) as item_count,
//       SUM(net_amount) as net_amount,
//       SUM(discount) as discount,
//       SUM(tax) as tax,
//       SUM(total_sale) as total_sale
//     FROM summary
//     GROUP BY parent_name, subitem_name
//     ORDER BY parent_name ASC
//   ''');
// }


// static Future<void> updateSubItem(
//   int id,
//   String name,
//   double price, {
//   String? shortCode,
//   String? unit,
//   String? description,
//   String? choice,
//   String? orderTypes,
//   String? imagePath,
//   bool isvarient = false,
//   bool hastoppings = false,
//   List<Map<String, dynamic>> variants = const [],
//   List<Map<String, dynamic>> toppings = const [],
// }) async {
//   final db = await database;

//   await db.update(
//     'sub_items',
//     {
//       'name': name,
//       'price': price,
//       'short_code': shortCode,
//       'unit': unit,
//       'description': description,
//       'choice': choice,
//       'order_types': orderTypes,
//       'image_path': imagePath,
//       'isvarient': isvarient ? 1 : 0,
//       'hastoppings': hastoppings ? 1 : 0,
//       'variants': jsonEncode(variants),
//       'toppings': jsonEncode(toppings),
//     },
//     where: 'id = ?',
//     whereArgs: [id],
//   );
// }

// static Future<List<Map<String, dynamic>>> getAllSubItems() async {
//   final db = await database;
//   final subItems = await db.query('sub_items', orderBy: 'id DESC');

//   // ✅ JSON decode variants + toppings
//   return subItems.map((sub) {
//     final subWithExtras = Map<String, dynamic>.from(sub);

//     if (sub['variants'] != null && (sub['variants'] as String).isNotEmpty) {
//       subWithExtras['variants'] = jsonDecode(sub['variants'] as String);
//     } else {
//       subWithExtras['variants'] = [];
//     }

//     if (sub['toppings'] != null && (sub['toppings'] as String).isNotEmpty) {
//       subWithExtras['toppings'] = jsonDecode(sub['toppings'] as String);
//     } else {
//       subWithExtras['toppings'] = [];
//     }

//     return subWithExtras;
//   }).toList();
// }


// static Future<Map<String, dynamic>?> getSubItemById(int id) async {
//   final db = await database;
//   final result = await db.query('sub_items', where: 'id = ?', whereArgs: [id]);
//   if (result.isEmpty) return null;

//   final sub = result.first;
//   final subWithExtras = Map<String, dynamic>.from(sub);

//   subWithExtras['variants'] =
//       (sub['variants'] != null && (sub['variants'] as String).isNotEmpty)
//           ? jsonDecode(sub['variants'] as String)
//           : [];

//   subWithExtras['toppings'] =
//       (sub['toppings'] != null && (sub['toppings'] as String).isNotEmpty)
//           ? jsonDecode(sub['toppings'] as String)
//           : [];

//   return subWithExtras;
// }






// // Insert new table
// static Future<int> insertTable(int number, String location) async {
//   final db = await database;
//   return await db.insert('tables', {
//     'table_number': number,
//     'location': location,
//   });
// }

// // Fetch all tables
// static Future<List<Map<String, dynamic>>> getAllTables() async {
//   final db = await database;
//   return await db.query('tables', orderBy: 'location ASC, table_number ASC');
// }

// static Future<void> deleteSubItem(int id) async {
//   final db = await database;
//   await db.delete(
//     'sub_items',
//     where: 'id = ?',
//     whereArgs: [id],
//   );
// }




//   static Future<void> clearAllData() async {
//     final db = await database;
//     await db.delete('order_items');
//     await db.delete('sub_items');
//     await db.delete('items');
   
//   }


//   static Future<void> clearTableData() async {
//     final db = await database;
//     await db.delete('summary');

   
//   }


// }






// Updated DBHelper with order_items and category summary logic
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_items.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE sub_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_id INTEGER,
            name TEXT,
            price REAL,
            short_code TEXT,
            unit TEXT,
            description TEXT,
            choice TEXT,
            order_types TEXT,
            image_path TEXT,
            isvarient INTEGER,
            hastoppings INTEGER,
            variants TEXT,
            toppings TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE summary (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id TEXT,
            order_date TEXT,
            order_type TEXT,
            parent_name TEXT,
            table_number TEXT,
            person_count INTEGER,
            subitem_name TEXT,
            item_count INTEGER,
            net_amount REAL,
            discount REAL,
            tax REAL,
            total_sale REAL
          );
        ''');

        await db.execute('''
          CREATE TABLE tables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            table_number INTEGER,
            location TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sub_item_id INTEGER,
            quantity INTEGER,
            FOREIGN KEY(sub_item_id) REFERENCES sub_items(id)
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE order_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              sub_item_id INTEGER,
              quantity INTEGER,
              FOREIGN KEY(sub_item_id) REFERENCES sub_items(id)
            );
          ''');
        }
      },
    );
  }

  static Future<int> insertItem(String name) async {
    final db = await database;
    return await db.insert('items', {'name': name});
  }

  // ✅ Insert sub_item and return updated parent item with sub_items
  static Future<Map<String, dynamic>?> insertSubItem(
    int itemId,
    String name,
    double price, {
    String? shortCode,
    String? unit,
    String? description,
    String? choice,
    String? orderTypes,
    String? imagePath,
    bool isvarient = false,
    bool hastoppings = false,
    List<Map<String, dynamic>> variants = const [],
    List<Map<String, dynamic>> toppings = const [],
  }) async {
    final db = await database;

    await db.insert('sub_items', {
      'item_id': itemId,
      'name': name,
      'price': price,
      'short_code': shortCode,
      'unit': unit,
      'description': description,
      'choice': choice,
      'order_types': orderTypes,
      'image_path': imagePath,
      'isvarient': isvarient ? 1 : 0,
      'hastoppings': hastoppings ? 1 : 0,
      'variants': jsonEncode(variants),
      'toppings': jsonEncode(toppings),
    });

    return await _getItemWithSubs(itemId);
  }

  static Future<List<Map<String, dynamic>>> getItemsWithSubItems() async {
    final db = await database;
    final itemsRaw = await db.query('items');
    List<Map<String, dynamic>> itemsWithSubs = [];

    for (var item in itemsRaw) {
      final itemWithSubs = await _getItemWithSubs(item['id'] as int);
      if (itemWithSubs != null) {
        itemsWithSubs.add(itemWithSubs);
      }
    }

    return itemsWithSubs;
  }

  // ✅ Helper: get single item with decoded sub_items
  static Future<Map<String, dynamic>?> _getItemWithSubs(int itemId) async {
    final db = await database;

    final parentItem =
        await db.query('items', where: 'id = ?', whereArgs: [itemId]);
    if (parentItem.isEmpty) return null;

    final item = Map<String, dynamic>.from(parentItem.first);

    final subItems =
        await db.query('sub_items', where: 'item_id = ?', whereArgs: [itemId]);

    final subItemsWithExtras = subItems.map((sub) {
      final subWithExtras = Map<String, dynamic>.from(sub);

      subWithExtras['variants'] =
          (sub['variants'] != null && (sub['variants'] as String).isNotEmpty)
              ? jsonDecode(sub['variants'] as String)
              : [];

      subWithExtras['toppings'] =
          (sub['toppings'] != null && (sub['toppings'] as String).isNotEmpty)
              ? jsonDecode(sub['toppings'] as String)
              : [];

      return subWithExtras;
    }).toList();

    item['sub_items'] = subItemsWithExtras;

    return item;
  }

  static Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_items.db');
    await deleteDatabase(path);
  }

  static Future<void> insertCategorySummary(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('summary', data);
  }

  static Future<void> insertCategoryDine(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('summaryDine', data);
  }

  static Future<List<Map<String, dynamic>>> getCategorySummary() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        parent_name,
        subitem_name,
        COUNT(DISTINCT order_id) AS orders,
        SUM(item_count) as item_count,
        SUM(net_amount) as net_amount,
        SUM(discount) as discount,
        SUM(tax) as tax,
        SUM(total_sale) as total_sale
      FROM summary
      GROUP BY parent_name, subitem_name
      ORDER BY parent_name ASC
    ''');
  }

  // ✅ Update sub_item and return updated parent item with sub_items
  static Future<Map<String, dynamic>?> updateSubItem(
    int id,
    String name,
    double price, {
    String? shortCode,
    String? unit,
    String? description,
    String? choice,
    String? orderTypes,
    String? imagePath,
    bool isvarient = false,
    bool hastoppings = false,
    List<Map<String, dynamic>> variants = const [],
    List<Map<String, dynamic>> toppings = const [],
  }) async {
    final db = await database;

    await db.update(
      'sub_items',
      {
        'name': name,
        'price': price,
        'short_code': shortCode,
        'unit': unit,
        'description': description,
        'choice': choice,
        'order_types': orderTypes,
        'image_path': imagePath,
        'isvarient': isvarient ? 1 : 0,
        'hastoppings': hastoppings ? 1 : 0,
        'variants': jsonEncode(variants),
        'toppings': jsonEncode(toppings),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    // get parent id to fetch fresh data
    final sub =
        await db.query('sub_items', where: 'id = ?', whereArgs: [id]);
    if (sub.isEmpty) return null;

    return await _getItemWithSubs(sub.first['item_id'] as int);
  }

  static Future<List<Map<String, dynamic>>> getAllSubItems() async {
    final db = await database;
    final subItems = await db.query('sub_items', orderBy: 'id DESC');

    return subItems.map((sub) {
      final subWithExtras = Map<String, dynamic>.from(sub);

      subWithExtras['variants'] =
          (sub['variants'] != null && (sub['variants'] as String).isNotEmpty)
              ? jsonDecode(sub['variants'] as String)
              : [];

      subWithExtras['toppings'] =
          (sub['toppings'] != null && (sub['toppings'] as String).isNotEmpty)
              ? jsonDecode(sub['toppings'] as String)
              : [];

      return subWithExtras;
    }).toList();
  }

  static Future<Map<String, dynamic>?> getSubItemById(int id) async {
    final db = await database;
    final result =
        await db.query('sub_items', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;

    final sub = result.first;
    final subWithExtras = Map<String, dynamic>.from(sub);

    subWithExtras['variants'] =
        (sub['variants'] != null && (sub['variants'] as String).isNotEmpty)
            ? jsonDecode(sub['variants'] as String)
            : [];

    subWithExtras['toppings'] =
        (sub['toppings'] != null && (sub['toppings'] as String).isNotEmpty)
            ? jsonDecode(sub['toppings'] as String)
            : [];

    return subWithExtras;
  }

  static Future<int> insertTable(int number, String location) async {
    final db = await database;
    return await db.insert('tables', {
      'table_number': number,
      'location': location,
    });
  }

  static Future<List<Map<String, dynamic>>> getAllTables() async {
    final db = await database;
    return await db.query('tables', orderBy: 'location ASC, table_number ASC');
  }

  static Future<void> deleteSubItem(int id) async {
    final db = await database;
    await db.delete(
      'sub_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('order_items');
    await db.delete('sub_items');
    await db.delete('items');
  }

  static Future<void> clearTableData() async {
    final db = await database;
    await db.delete('summary');
  }
}
