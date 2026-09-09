import 'package:flutter/material.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  void login() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak boleh kosong'),
        ),
      );

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121210),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Log In to Strava',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 45),

              TextField(
                controller: emailController,

                keyboardType: TextInputType.emailAddress,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: InputDecoration(
                  labelText: 'Email',

                  labelStyle: const TextStyle(
                    color: Colors.white70,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),

                    borderSide: const BorderSide(
                      color: Color(0xFF555555),
                      width: 2,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),

                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 60,

                child: FilledButton(
                  onPressed: login,

                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFC5200),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white54,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Google Login akan ditambahkan nanti',
                        ),
                      ),
                    );
                  },

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.white54,
                      width: 2,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'G',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(width: 15),

                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFF242422),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.white,
                    ),

                    SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Looking for Facebook login?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Facebook login is no longer supported. '
                            'You can still log in with the email '
                            'associated with your Facebook account.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Learn More',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'By continuing, you are agreeing to our '
                'Terms of Service and Privacy Policy.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}