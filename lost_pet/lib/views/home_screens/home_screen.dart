import 'package:flutter/material.dart';
import 'package:lost_pet/views/home_screens/home_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _buildBody(context),
      endDrawer: const HomeDrawer(),
    );
  }

  Widget _buildBody(BuildContext context) {
    return const Placeholder();
  }
}
