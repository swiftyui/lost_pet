import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:lost_pet/views/login_screens/login_screen.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      surfaceTintColor: Theme.of(context).colorScheme.onSecondary,
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _logoutButton(context),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.onSecondary,
      onTap: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      },
      dense: true,
      title: const Text(
        'Logout',
        style: TextStyle(
          fontFamily: 'avenir',
          fontSize: 15,
        ),
      ),
      leading: Icon(
        Icons.logout_outlined,
        color: Theme.of(context).colorScheme.onBackground,
        size: 30,
      ),
    );
  }
}
