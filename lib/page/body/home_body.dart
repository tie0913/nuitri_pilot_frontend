
import 'package:flutter/material.dart';

class HomeBody extends StatefulWidget{
  const HomeBody({super.key});
  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody>{

  void _showImageSourceActionSheet(){}

  @override
  Widget build(BuildContext context){
  return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home, size: 64),
            const SizedBox(height: 12),
            Text(
              'Welcome to Nutri Pilot',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('This is a protected page after auth.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceActionSheet,
        tooltip: 'Add Photo',
        child: const Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat
    );
  }
}