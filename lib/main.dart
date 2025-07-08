import 'package:flutter/material.dart';
import 'package:pet_health/components/navbar/sidebar.dart';
import 'pages/home-page/home_page.dart';
import 'pages/vet-page/vet_page.dart';
import 'pages/food-page/food_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'components/navbar/custom_header.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PetHealthApp());
}

class PetHealthApp extends StatelessWidget {
  const PetHealthApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Health Monitoring System',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 1; // 0 = Vet, 1 = Home, 2 = Food

  final _pages = const [
    VetPage(),
    HomePage(),
    FoodPage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Pet Health Monitoring System'),
      leading: IconButton(
        icon: const Icon(Icons.account_circle_outlined),
        onPressed: () {
          // TODO: Navigate to profile page
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            // TODO: Notifications placeholder
          },
        ),
      ],
    );
  }

  BottomNavigationBar _buildNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital_outlined),
          label: 'Vet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Food',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Column(
      children: [
        const CustomHeader(), // Top bar with logo + title + bell
        Expanded(child: _pages[_currentIndex]), // Your actual page
        ],
      ),  
      bottomNavigationBar: _buildNavBar(),
    );
  }
}