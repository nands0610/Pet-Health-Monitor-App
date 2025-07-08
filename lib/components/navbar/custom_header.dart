import 'package:flutter/material.dart';


class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (){
              Scaffold.of(context).openDrawer();
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/pet_placeholder.jpg'),
            )
          ),
          const Text(
            'Pet Health Monitoring System',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.notifications),
        ],
      ),
    );
  }
}
