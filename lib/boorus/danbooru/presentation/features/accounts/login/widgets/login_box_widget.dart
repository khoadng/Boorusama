// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/api/api_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/profile/profile_repository.dart';
import 'package:boorusama/core/utils.dart';

class LoginBox extends HookWidget {
  const LoginBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tickerProvider = useSingleTickerProvider();
    final animationController = useAnimationController(
        vsync: tickerProvider, duration: Duration(milliseconds: 150));
    final _formKey = useState(GlobalKey<FormState>());
    final _isValidUsernameAndPassword = useState(true);

    final usernameTextController = useTextEditingController();
    final passwordTextController = useTextEditingController();
    final showPassword = useState(false);
    final usernameHasText = useState(false);

    usernameTextController.addListener(() {
      if (usernameTextController.text.isNotEmpty) {
        animationController.forward();
        usernameHasText.value = usernameTextController.text.isNotEmpty;
      } else {
        animationController.reverse();
      }
    });

    void onTextChanged() {
      _isValidUsernameAndPassword.value = true;
    }

    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _isValidUsernameAndPassword.value = true;
          Navigator.of(context).pop();
        } else if (state is AuthenticationError &&
            state.exception is InvalidUsernameOrPassword) {
          _isValidUsernameAndPassword.value = false;
          _formKey.value.currentState!.validate();
        } else if (state is AuthenticationError &&
            state.exception is Exception) {
          final snackbar = SnackBar(
            behavior: SnackBarBehavior.floating,
            elevation: 6.0,
            content: Text(
              'Something went wrong, please try again later',
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      },
      child: Form(
        autovalidateMode: AutovalidateMode.disabled,
        key: _formKey.value,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LoginField(
                labelText: 'login.form.username'.tr(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'login.errors.missingUsername'.tr();
                  }

                  if (!_isValidUsernameAndPassword.value) {
                    return 'login.errors.invalidUsernameOrPassword'.tr();
                  }
                  return null;
                },
                onChanged: (text) => onTextChanged(),
                controller: usernameTextController,
                suffixIcon: usernameHasText.value
                    ? ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animationController,
                          curve: Interval(0.0, 1.0, curve: Curves.linear),
                        ),
                        child: IconButton(
                            splashColor: Colors.transparent,
                            icon: FaIcon(FontAwesomeIcons.solidTimesCircle),
                            onPressed: () => usernameTextController.clear()),
                      )
                    : null,
              ),
              SizedBox(height: 20),
              LoginField(
                labelText: 'login.form.password'.tr(),
                obscureText: !showPassword.value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'login.errors.missingPassword'.tr();
                  }
                  if (!_isValidUsernameAndPassword.value) {
                    return 'login.errors.invalidUsernameOrPassword'.tr();
                  }
                  return null;
                },
                onChanged: (text) => onTextChanged(),
                controller: passwordTextController,
                suffixIcon: IconButton(
                    splashColor: Colors.transparent,
                    icon: showPassword.value
                        ? FaIcon(FontAwesomeIcons.solidEyeSlash)
                        : FaIcon(FontAwesomeIcons.solidEye),
                    onPressed: () => showPassword.value = !showPassword.value),
              ),
              TextButton.icon(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('API key?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Cancel"),
                          ),
                          BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
                            builder: (context, state) => TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                launchExternalUrl(Uri.parse(state.booru.url));
                              },
                              child: Text("Open web browser"),
                            ),
                          ),
                        ],
                        content: Text(
                            '1. Log in to your account.\n2. Navigate to your profile\n3. Find and copy your API key into the login form here\n4. ???\n5. Profit'),
                      );
                    }),
                icon: FaIcon(FontAwesomeIcons.solidQuestionCircle),
                label: Text("API key?"),
              ),
              SizedBox(height: 20),
              BlocBuilder<AuthenticationCubit, AuthenticationState>(
                builder: (context, state) => state is AuthenticationInProgress
                    ? CircularProgressIndicator()
                    : _buildLoginButton(
                        context,
                        _formKey,
                        usernameTextController,
                        passwordTextController,
                        _isValidUsernameAndPassword,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
      BuildContext context,
      ValueNotifier<GlobalKey<FormState>> _formKey,
      TextEditingController usernameTextController,
      TextEditingController passwordTextController,
      ValueNotifier<bool> _isValidUsernameAndPassword) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(onPrimary: Colors.white),
      child: Text('login.form.login'.tr()),
      onPressed: () {
        if (_formKey.value.currentState!.validate()) {
          ReadContext(context)
              .read<AuthenticationCubit>()
              .logIn(usernameTextController.text, passwordTextController.text);
          FocusScope.of(context).unfocus();
        } else {
          _isValidUsernameAndPassword.value = true;
        }
      },
    );
  }
}

class LoginField extends HookWidget {
  const LoginField({
    Key? key,
    required this.validator,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? Function(String?) validator;
  final Widget? suffixIcon;
  final String labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final _controller = useTextEditingController();

    return TextFormField(
      onChanged: onChanged,
      obscureText: obscureText,
      validator: validator,
      controller: controller ?? _controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).accentColor, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).errorColor),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).errorColor, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        contentPadding: EdgeInsets.all(12.0),
        labelText: labelText,
      ),
    );
  }
}
