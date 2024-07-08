import 'package:catat_keuangan/helper/dimensions.dart';
import 'package:catat_keuangan/module/authentication/signin_page.dart';
import 'package:catat_keuangan/overlay/overlays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'auth_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/forgot.svg',
            semanticsLabel: 'My SVG Image',
            width: 200,
          ),
          SizedBox(
            height: Dimensions.size15,
          ),
          const Text(
            "Forgot Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                    Overlays.success(
                      message: "Reset password berhasil dikirim ke email kamu.",
                    );
                  } else if (state is AuthFailure) {
                    Overlays.error(
                      message: "Gagal Mereset password.",
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                ForgotPasswordRequested(
                                  email: emailController.text,
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange[200],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
