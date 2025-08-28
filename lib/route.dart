import 'package:flutter/material.dart';
import 'package:posapp/dashboard1.dart';
import 'package:posapp/layout.dart';
import 'package:posapp/pages/liveview.dart';
import 'package:posapp/pages/loginpage.dart';
import 'package:posapp/pages/menuItems/addmenu.dart';
import 'package:posapp/pages/menuItems/itemTable.dart';
import 'package:posapp/pages/menuItems/menu.dart';
import 'package:posapp/pages/operations/operationitems.dart';
import 'package:posapp/pages/report/categorys_summary.dart';
import 'package:posapp/pages/report/item_summary.dart';
import 'package:posapp/pages/report/orderreport.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _handleNavigation(String route) {
    debugPrint("Navigating to: $route");
    _navigatorKey.currentState?.pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      initialRoute: 'login', // ⬅ Start with login
      onGenerateRoute: (RouteSettings settings) {
        late Widget page;

        switch (settings.name) {
          case 'login':
            page = Loginpage();
            break;

          case 'operations':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: OperationsPage(onNavigate: _handleNavigation),
            );
            break;

          

          case 'live-view':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: LiveViewPage(),
            );
            break;

          case 'order-report':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: OrderReport(),
            );
            break;

        
          case 'category_summary':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: CategorySummaryPage(),
            );
            break;

                  case 'order_summary':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: OrderReport(),
            );
            break;


                  case 'item_summary':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: ItemSummary(),
            );
            break;

           case 'menu_items':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: MenuItems(),
            );
            break;

              case 'update-menu':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: MenuItems(),
            );
            break;
              case 'add-menu':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: AddItemPage(),
            );
            break;
              case 'create-category':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: MenuItems(),
            );
            break;

          case 'show_itemPage':
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: ShowItemsPage(),
            );
            break;


          case 'dashboard':
          default:
            page = MainLayout(
              onNavigate: _handleNavigation,
              child: POSDashboard(countData: ''),
            );
        }

        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}
