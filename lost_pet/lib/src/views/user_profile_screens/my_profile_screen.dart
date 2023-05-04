import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:lost_pet/src/services/authentication_service.dart';
import 'package:lost_pet/src/services/theme.dart';
import 'package:lost_pet/src/services/user_provider.dart';
import 'package:lost_pet/src/views/widgets/change_user_avatar.dart';
import 'package:lost_pet/src/views/widgets/custom_snackbar.dart';
import 'package:lost_pet/src/views/widgets/error_popup.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreen();
}

class _MyProfileScreen extends State<MyProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  late UserProvider _userProvider;
  bool _loading = false;
  bool _resetLoading = false;
  bool _validEmail = false;
  bool _validDisplayName = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final ValueNotifier<bool> _saveEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  _loadUserDetails() async {
    _userProvider = UserProvider.instance;
    setState(() {
      _displayNameController.text =
          _userProvider.value?.displayName ?? 'Luke Skywalker';
      _emailController.text =
          _userProvider.value?.emailAddress ?? 'luke@skywalker.com';
    });
  }

  void _setLoading([bool loading = false]) {
    setState(() {
      _loading = loading;
    });
  }

  void _setResetLoading([bool loading = false]) {
    setState(() {
      _resetLoading = loading;
    });
  }

  Future<void> _showError(String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => ErrorPopup(
        title: title,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        leading: const BackButton(color: Colors.white),
      ),
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: _myDetailsBody(context),
    );
  }

  Widget _myDetailsBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              // User Image
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                child: ChangeUserAvatar(
                  size: 200,
                  isLoading: _loading,
                  setLoading: _setLoading,
                ),
              ),
              // User Display Name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildUserName(context),
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _buildForm(context),
          ),
        )
      ],
    );
  }

  Widget _buildUserName(BuildContext context) {
    return SizedBox(
      height: 35,
      width: MediaQuery.of(context).size.width,
      child: AutoSizeText(
        _userProvider.value?.displayName ?? '',
        textAlign: TextAlign.center,
        maxLines: 1,
        maxFontSize: 35,
        minFontSize: 5,
        style: const TextStyle(
          fontFamily: "avenir",
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _updateAccountDetails(
    String newDisplayName,
    String newEmail,
  ) async {
    try {
      _setLoading(true);
      await _userProvider.updateDisplayName(displayName: newDisplayName);
      await _userProvider.updateEmailAddress(emailAddress: newEmail);
      await _loadUserDetails();

      _setLoading(false);
      _saveEnabled.value = false;
      if (context.mounted) {
        CustomSnackBar.showSnackBar(
          context,
          'Success!',
          'Account details updated!',
          ContentType.success,
        );
      }
    } on AuthenticationServiceError catch (error) {
      _setLoading(false);
      _showError(
        'Authentication Error',
        error.message,
      );
    }
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          border: Border.all(
            color: Theme.of(context).colorScheme.background,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: lightFormBoxShadow,
        ),
        child: Column(
          children: <Widget>[
            TextFormField(
              style: const TextStyle(
                fontFamily: 'avenir',
              ),
              onChanged: (value) => _displayNameChangesMade(value),
              controller: _displayNameController,
              enabled: !_loading,
              autovalidateMode: AutovalidateMode.always,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  _validDisplayName = false;
                  return 'Display name cannot be empty';
                }
                _validDisplayName = true;
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Display name',
                labelText: 'Display name',
                suffixIcon: IconButton(
                  onPressed: _displayNameController.clear,
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                  ),
                ),
              ),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            TextFormField(
              style: const TextStyle(
                fontFamily: 'avenir',
              ),
              onChanged: (value) => _emailAddressChangesMade(value),
              controller: _emailController,
              enabled: !_loading,
              autovalidateMode: AutovalidateMode.always,
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
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.grey,
                ),
                hintText: 'Email address',
                labelText: 'Email address',
                suffixIcon: IconButton(
                  onPressed: _emailController.clear,
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),
            _buildSaveChangesButton(context),
            _buildUpdatePasswordButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveChangesButton(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _saveEnabled,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSecondary,
                surfaceTintColor: Theme.of(context).colorScheme.onSecondary,
                disabledBackgroundColor:
                    Theme.of(context).colorScheme.onInverseSurface,
                side: _saveEnabled.value
                    ? BorderSide(
                        width: 1,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : null,
                shape: _saveEnabled.value
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
              ),
              onPressed: _saveEnabled.value
                  ? () async {
                      if (_validEmail == true && _validDisplayName) {
                        await _updateAccountDetails(
                          _displayNameController.text,
                          _emailController.text,
                        );
                      }
                    }
                  : null,
              child: _loading
                  ? SizedBox.square(
                      dimension: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  : Text(
                      "SAVE CHANGES",
                      style: TextStyle(
                        fontFamily: 'avenir',
                        color: _saveEnabled.value
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpdatePasswordButton(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: UserProvider.instance,
        builder: (context, user, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: _resetLoading
                    ? () {}
                    : () async {
                        _resetPassword(user!.emailAddress);
                      },
                child: _resetLoading
                    ? const Text(
                        "RESET PASSWORD",
                        style: TextStyle(
                          fontFamily: 'avenir',
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        "RESET PASSWORD",
                        style: TextStyle(
                          fontFamily: 'avenir',
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          );
        });
  }

  Future<void> _resetPassword(String emailAddress) async {
    try {
      _setResetLoading(true);
      await AuthenticationService()
          .resetPassword(email: emailAddress)
          .whenComplete(() => CustomSnackBar.showSnackBar(
                context,
                'Success!',
                'Recovery email sent',
                ContentType.success,
              ));
    } on AuthenticationServiceError catch (error) {
      _setResetLoading(false);
      await _showError(
        'Authentication Error',
        error.message,
      );
    } finally {
      _setResetLoading(false);
    }
  }

  _displayNameChangesMade(String value) {
    _saveEnabled.value = _userProvider.value?.displayName != value;
  }

  _emailAddressChangesMade(String value) {
    _saveEnabled.value = _userProvider.value?.emailAddress != value;
  }
}
