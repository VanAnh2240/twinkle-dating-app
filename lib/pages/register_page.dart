import 'package:flutter/material.dart';
import 'package:twinkle/components/login_register/custom_textfield.dart';
import 'package:twinkle/components/login_register/custom_button.dart';
import 'package:twinkle/services/auth/auth_service.dart';

enum PasswordStrength { weak, medium, strong, veryStrong, empty }

PasswordStrength checkPasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.empty;
  bool hasNumber = password.contains(RegExp(r'[0-9]'));
  bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  if (password.length < 6) return PasswordStrength.weak;
  if (password.length < 10) return PasswordStrength.medium;
  if (password.length >= 10 && (!hasNumber || !hasSpecial)) {
    return PasswordStrength.strong;
  }
  if (password.length >= 10 && hasNumber && hasSpecial) {
    return PasswordStrength.veryStrong;
  }
  return PasswordStrength.weak;
}

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  // controllers
  final firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  bool obscureText = true;

  // VALIDATION PW + TEARMS
  bool agreeTerms = false;
  String password = '';
  bool get isLengthValid => password.length >= 8;
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecial => password.contains(RegExp(r'[!@#$%^&*]'));
  bool get allValid => isLengthValid && hasNumber && hasSpecial;
  
  // Checkbox color
  Color textColor(bool isValid) =>
      isValid ? Colors.white : Colors.white70;
  Color checkboxColor(bool isValid) =>
    isValid ? Colors.pinkAccent : Colors.white70;

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  // match password
  void register(BuildContext context) {
    final auth = AuthService();
    if (pwController.text == confirmPwController.text) {
      try {
        auth.registerWithEmailPassword(
          emailController.text,
          pwController.text,
          firstnameController.text,
          lastnameController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords do not match!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //logo
                      Icon(
                        Icons.message,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      const SizedBox(height: 10),
                      //message
                      Text(
                        "Let's create an account for you",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 25),
                      
                      //last name textfield
                      CustomTextfield(
                        controller: emailController,
                        labelText: 'Last name',
                        icon: Icons.person,
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // email textfield
                      CustomTextfield(
                        controller: emailController,
                        labelText: 'Email',
                        icon: Icons.person,
                      ),
                                        

                      // email textfield
                      CustomTextfield(
                        controller: emailController,
                        labelText: "Email",
                        obscureText: false,
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 5),

                      // pw textfield
                      CustomTextfield(
                        controller: pwController,
                        labelText: 'Password',
                        icon: Icons.password,
                        isPassword: true,
                        obscureText: obscureText,
                        onToggleObscure: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),

                      const SizedBox(height: 5),

                      // confirm pw textfield
                      CustomTextfield(
                        controller: confirmPwController,
                        labelText: "Confirm Password",
                        icon: Icons.password,
                        isPassword: true,
                        obscureText: obscureText,
                        onToggleObscure: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // pw  checklist

                      //include 8 char
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                        child: Row(
                          children: [
                            Icon(
                              isLengthValid
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: checkboxColor(isLengthValid),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "At least 8 characters",
                              style: TextStyle(color: textColor(isLengthValid)),
                            ),
                          ],
                        ),
                      ),

                      //include number
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                        child: Row(
                          children: [
                            Icon(
                              hasNumber
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: checkboxColor(hasNumber),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Include a number",
                              style: TextStyle(color: textColor(hasNumber)),
                            ),
                          ],
                        ),
                      ),
                     
                      //include 1 special char
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                        child: Row(
                          children: [
                            Icon(
                              hasSpecial
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: checkboxColor(hasSpecial),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Include 1 special character",
                              style: TextStyle(color: textColor(hasSpecial)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height:  10),
                      
                      //agree to terms
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: agreeTerms,
                              onChanged: (value) {
                                setState(() {
                                  agreeTerms = value ?? false;
                                });
                              },
                              activeColor: Colors.pinkAccent,
                              checkColor: Colors.white,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree to the ',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: [
                                    TextSpan(
                                        text: 'Terms of Service',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pinkAccent)),
                                    TextSpan(text: ' and ', style: Theme.of(context).textTheme.bodyLarge,),
                                    TextSpan(
                                        text: 'Privacy Policy',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pinkAccent)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      //register button
                      CustomButton(
                        text: "Create account  ",
                        onTap : agreeTerms ? () => register(context) : null,
                      ),

                      const SizedBox(height: 15),

                      // Have an account login now
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Have an account?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              " Login now",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 251, 87, 141),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                    ]
                  ),
                ),
              ),
              
            ],
          ),
        ),
      );
  }
}
