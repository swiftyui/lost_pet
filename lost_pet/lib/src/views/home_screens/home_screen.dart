import 'package:flutter/material.dart';
import 'package:lost_pet/src/models/user_model.dart';
import 'package:lost_pet/src/services/authentication_service.dart';
import 'package:lost_pet/src/views/home_screens/home_drawer.dart';

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
    return ValueListenableBuilder(
      valueListenable: UserProvider.instance,
      builder: (context, value, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _welcomeWidget(context, value),
            ],
          ),
        );
      },
    );
  }

  Widget _welcomeWidget(BuildContext context, UserModel? userModel) {
    return Container(
      child: Text('Hi ${userModel?.displayName}'),
    );
  }
}
