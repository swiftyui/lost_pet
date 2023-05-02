import 'package:flutter/material.dart';
import 'package:lost_pet/src/models/user_model.dart';
import 'package:lost_pet/src/services/animation_list.dart';
import 'package:lost_pet/src/services/authentication_service.dart';
import 'package:lost_pet/src/views/home_screens/home_screen.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Lottie.asset(AnimationList.dinosaur),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondary,
              border: Border.all(
                color: Theme.of(context).colorScheme.background,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 20, 9, 9),
              child: Column(
                children: [
                  _buildEmailField(context),
                  const SizedBox(height: 20),
                  _buildPasswordField(context),
                  const SizedBox(height: 20),
                  _buildSignInButton(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      enabled: !_loading,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.mail_outline,
        ),
        suffixIcon: IconButton(
          onPressed: _emailController.clear,
          icon: const Icon(
            Icons.clear,
            color: Colors.grey,
          ),
        ),
        hintText: 'Email address',
        labelText: 'Email address',
      ),
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        return null;
      },
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      enabled: !_loading,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.password_outlined,
        ),
        suffixIcon: IconButton(
          onPressed: _emailController.clear,
          icon: const Icon(
            Icons.clear,
            color: Colors.grey,
          ),
        ),
        hintText: 'Password',
        labelText: 'Password',
      ),
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        return null;
      },
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading
            ? () {}
            : () async {
                try {
                  UserModel? result =
                      await AuthenticationService().signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const HomeScreen()));
                } on AuthenticationServiceError catch (error) {
                  print(error.message.toString());
                }
              },
        child: _loading
            ? const SizedBox.square(
                dimension: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  color: Colors.white,
                ),
              )
            : const Text('SIGN IN'),
      ),
    );
  }
}
