import 'package:flutter/material.dart';
import 'package:lost_pet/src/services/authentication_service.dart';
import 'package:lost_pet/src/services/user_provider.dart';
import 'package:lost_pet/src/views/login_screens/login_screen.dart';
import 'package:lost_pet/src/views/user_profile_screens/my_profile_screen.dart';
import 'package:lost_pet/src/views/widgets/change_user_avatar.dart';

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
          _buildHeader(context),
          const Divider(),
          _buildProfileButton(context),
          const Divider(),
          _logoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ValueListenableBuilder(
            valueListenable: UserProvider.instance,
            builder: (context, value, child) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ChangeUserAvatar(
                      size: 96,
                      isLoading: false,
                      setLoading: (_) => {},
                    ),
                  ),
                  if (value != null && value.displayName.isNotEmpty)
                    Text(
                      value.displayName,
                      style: const TextStyle(
                        fontFamily: 'avenir',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.onSecondary,
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MyProfileScreen()));
      },
      dense: true,
      title: const Text(
        'My Profile',
        style: TextStyle(
          fontFamily: 'avenir',
          fontSize: 15,
        ),
      ),
      leading: Icon(
        Icons.person_outline,
        color: Theme.of(context).colorScheme.onBackground,
        size: 30,
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.onSecondary,
      onTap: () {
        AuthenticationService().signOut();
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
