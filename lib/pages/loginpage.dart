import 'package:flutter/material.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Stack(
            children: [
              // Pink Gradient on Left
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: screenWidth * 0.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color.fromARGB(255, 229, 235, 255),
                        Color.fromARGB(255, 200, 202, 255),
                        Color.fromARGB(255, 184, 175, 255),
                      ],
                    ),
                  ),
                ),
              ),

              // Centered Card
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          // Image.asset(
                          //   'assets/petpooja',
                          //   height: 50,
                          // ),
Text("Serve Bite",
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Color.fromARGB(255, 77, 93, 243),
),),

                          const SizedBox(height: 20),

                          const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.mail_outline),
                              hintText: "Enter here...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Password Field
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.vpn_key_outlined),
                              hintText: "Enter here...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // reCAPTCHA Placeholder
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Checkbox(value: false, onChanged: (_) {}),
                                const Text("I'm not a robot"),
                                const Spacer(),
                                const Icon(Icons.security, color: Colors.blue),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 88, 75, 233),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                              Navigator.of(context).pushReplacementNamed('dashboard');

                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
