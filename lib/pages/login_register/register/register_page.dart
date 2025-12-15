import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/themes/theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  // controllers
  final formKey = GlobalKey<FormState>();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthController _authController = Get.find<AuthController> ();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // VALIDATION + TEARMS
  bool agreeTerms = false;
  bool isFormValid = false;
  String password = '';
  bool get isLengthValid => password.length >= 6;
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
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  const SizedBox(height: 20),
              
                  // logo 
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
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
              
                  const SizedBox(height: 25),
              
                  //name textfield
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: TextFormField(
                  //         controller: firstnameController,
                  //         decoration: InputDecoration(
                  //           labelText: 'First name',
                  //           prefixIcon: Icon(
                  //             Icons.person,
                  //             color: Theme.of(context).colorScheme.primary,
                  //           ),
                  //           hintText: "First name",
                  //         ),
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return 'Enter first name';
                  //           }
                  //           return null;
                  //         },
                  //       ),
                  //     ),
              
                  //     const SizedBox(width: 10), // khoảng cách giữa 2 ô
              
                  //     Expanded(
                  //       child: TextFormField(
                  //         controller: lastnameController,
                  //         decoration: InputDecoration(
                  //           labelText: 'Last name',
                  //           prefixIcon: Icon(
                  //             Icons.person,
                  //             color: Theme.of(context).colorScheme.primary,
                  //           ),
                  //           hintText: "Last name",
                  //         ),
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return 'Enter last name';
                  //           }
                  //           return null;
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
               
                  const SizedBox(height: 15),
                        
                  // email textfield
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      hintText: "Email",
                    ),
                    onChanged: (value) {
                      setState(() {
                        isFormValid = (formKey.currentState?.validate() ?? false);
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                                      
                  const SizedBox(height: 15),
              
                  // pw textfield
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(
                        Icons.password,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      hintText: "Password",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        password = value;
                        isFormValid = (formKey.currentState?.validate() ?? false);
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Password must contain at least one number';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*]'))) {
                        return 'Password must contain at least one special character';
                      }
                      return null;
                    },
                  ),
              
                  const SizedBox(height: 15),
              
                  // confirm pw textfield
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: Icon(
                        Icons.password,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      hintText: "Confirm password",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        isFormValid = (formKey.currentState?.validate() ?? false);
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value!= passwordController.text) {
                        return 'Passwords do not match';
                      };
                      return null;
                    },
                  ),
              
                  const SizedBox(height: 20),
              
                  // pw  checklist
                  //include 8 char
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                          "At least 6 characters",
                          style: TextStyle(color: textColor(isLengthValid)),
                        ),
                      ],
                    ),
                  ),
              
                  //include number
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  Row(
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
                                      color: Colors.pinkAccent),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {Get.toNamed('/');}
                              ),
                              TextSpan(text: ' and ', style: Theme.of(context).textTheme.bodyLarge,),
                              TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pinkAccent),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {Get.toNamed('/');}
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                            
                  const SizedBox(height: 20),
              
                  //register button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading ? null : () {
                          if (formKey.currentState?.validate() ?? false) {
                            if (!agreeTerms) {
                              return;
                            }
                            _authController.registerWithEmailPassword(
                              emailController.text.trim(), 
                              passwordController.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (!_authController.isLoading && isFormValid && agreeTerms)
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        ),
                        child: _authController.isLoading 
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text("Create account"),
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 20),
              
                  //line
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.borderColor)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(child: Divider(color: AppTheme.borderColor))
                    ],
                  ),
              
                  const SizedBox(height: 20),
              
                  // Have an account login now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Have an account ? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.login),
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
      ),
    );  
  }
}
