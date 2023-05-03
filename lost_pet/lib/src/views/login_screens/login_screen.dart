import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:lost_pet/src/models/user_model.dart';
import 'package:lost_pet/src/services/animation_list.dart';
import 'package:lost_pet/src/services/authentication_service.dart';
import 'package:lost_pet/src/services/theme.dart';
import 'package:lost_pet/src/views/home_screens/home_screen.dart';
import 'package:lost_pet/src/views/widgets/error_popup.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _rememberMe = false;
  String _emailAddress = '';
  bool _validEmail = false;
  String _password = '';
  bool _isHidden = true;

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
                  _buildRememberMeCheckBox(context),
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
        if (value != null && value.isEmpty) {
          return 'Email cannot be empty';
        } else {
          final String email = value ?? "";
          _validEmail = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(email);
          if (_validEmail == false) {
            return 'Invalid email provided';
          }
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeCheckBox(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      checkColor: Theme.of(context).colorScheme.onSecondary,
      activeColor: greenAccentColour,
      controlAffinity: ListTileControlAffinity.leading,
      title: const Text(
        'Remember me',
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'avenir',
        ),
      ),
      value: _rememberMe,
      onChanged: (value) {
        setState(() {
          _rememberMe = value ?? false;
        });
      },
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isHidden,
      obscuringCharacter: '*',
      enabled: !_loading,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: greyIconColour,
        ),
        hintText: 'Password',
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isHidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: greyIconColour,
          ),
          onPressed: _togglePasswordView,
        ),
      ),
      keyboardType: _isHidden ? null : TextInputType.visiblePassword,
      textCapitalization: TextCapitalization.none,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        return null;
      },
    );
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  Future<void> _showError({
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => ErrorPopup(
        title: title,
        message: message,
      ),
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
                  _setLoading(true);
                  await _login();
                  _setLoading(false);
                } on AuthenticationServiceError catch (error) {
                  _setLoading(false);
                  await _showError(
                    title: 'Authentication Error',
                    message: error.message,
                  );
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

  @override
  void initState() {
    super.initState();
    _asyncInit();
  }

  Future _asyncInit() async {
    await _loadPreferences();
  }

  void _setLoading([bool loading = false]) {
    setState(() {
      _loading = loading;
    });
  }

  Future _login() async {
    if (_validEmail == true) {
      _emailAddress = _emailController.text;
      _password = _passwordController.text;

      await _savePreferences(
          rememberMe: _rememberMe,
          emailAddress: _emailAddress,
          password: _password);

      UserModel? result =
          await AuthenticationService().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (result == null) {
        await _showError(
          title: 'Authentication Error',
          message: 'An unknown error occurred.',
        );
      } else {
        _navigateToHomeScreen();
      }
    }
  }

  Future<void> _savePreferences({
    required bool rememberMe,
    String? emailAddress,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    EncryptedSharedPreferences encryptedSharedPreferences =
        EncryptedSharedPreferences(prefs: prefs);
    SharedPreferences instance = await encryptedSharedPreferences.getInstance();
    await instance.setBool('rememberMe', rememberMe);
    await instance.setBool('showLogin', true);
    if (rememberMe) {
      await instance.setString('emailAddress', emailAddress!);
      await instance.setString('password', password!);
    }
  }

  _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  Future _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    EncryptedSharedPreferences encryptedSharedPreferences =
        EncryptedSharedPreferences(prefs: prefs);
    SharedPreferences instance = await encryptedSharedPreferences.getInstance();
    _rememberMe = instance.getBool('rememberMe') ?? false;

    if (_rememberMe == true) {
      _emailAddress = instance.getString('emailAddress') ?? '';
      _password = instance.getString('password') ?? '';
    }

    setState(() {
      _rememberMe = _rememberMe;
      _emailAddress = _emailAddress;
      _password = _password;
      _emailController.text = _emailAddress;
      _passwordController.text = _password;
    });
  }
}
