import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/themes/theme.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });


  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>{
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController> ();

  bool obscureText = true;
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                //message
                Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
            
                const SizedBox(height: 25),
                  
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
                                    
                const SizedBox(height: 20),
            
                // pw textfield
                TextFormField(
                  controller: passwordController,
                  obscureText: obscureText,
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
                          obscureText = !obscureText;
                        });
                      },
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    };
                    return null;
                  },
                ),
            
                const SizedBox(height: 10),
                
                // Remember me checkbox
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                      activeColor: Colors.pinkAccent,
                      checkColor: Colors.white,
                    ),
                    const Text(
                      "Remember me",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
            
                // login button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authController.isLoading ? null : () {
                        if (formKey.currentState?.validate() ?? false) {
                          _authController.signInWithEmailPassword(
                            emailController.text.trim(), 
                            passwordController.text,
                          );
                        }
                      },
                      child: _authController.isLoading 
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Sign in"),
                    ),
                  ),
                ),
            
                const SizedBox(height: 10),
            
                //forgot password
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.forgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  )
                ),
            
                //line
                const SizedBox(height: 20),
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
            
                // Not a member? Sign up now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member ? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.register), 
                      //->gọi tên route, chuyển sang register page
                      child: Text(
                        "Sign up now",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                    ),
                  ],
                )
            
              ],
            ),
          ),
        ),
      ),
    );
  } 
}
