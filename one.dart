import 'package:flutter/material.dart';

void main() => runApp(const MyFormApp());

class MyFormApp extends StatelessWidget {
  const MyFormApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext c) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Stylish Form",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.deepPurple.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            labelStyle: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: const FormPage(),
      );
}

class FormPage extends StatefulWidget {
  const FormPage({Key? key}) : super(key: key);
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(), _emailCtrl = TextEditingController(), _passCtrl = TextEditingController();
  String? _gender;
  bool _agree = false;

  @override
  Widget build(BuildContext c) => Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(title: const Text("Registration Form"), elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Enter Your Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 20),
              _field(_nameCtrl, "Full Name", Icons.person, (v) => v!.isEmpty ? "Please enter your name" : null),
              const SizedBox(height: 15),
              _field(_emailCtrl, "Email", Icons.email, (v) => v!.contains('@') ? null : "Enter valid email", keyboard: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _field(_passCtrl, "Password", Icons.lock, (v) => v!.length < 6 ? "Password too short" : null, obscure: true),
              const SizedBox(height: 20),
              const Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Row(
                children: ["Male", "Female"]
                    .map((g) => Expanded(
                          child: RadioListTile<String>(
                            title: Text(g),
                            value: g,
                            groupValue: _gender,
                            activeColor: Colors.deepPurple,
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                        ))
                    .toList(),
              ),
              CheckboxListTile(
                title: const Text("I agree to the Terms & Conditions"),
                value: _agree,
                activeColor: Colors.deepPurple,
                onChanged: (v) => setState(() => _agree = v!),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(onPressed: _submit, child: const Text("Submit")),
              ),
            ]),
          ),
        ),
      );

  Widget _field(TextEditingController ctrl, String label, IconData icon, String? Function(String?) validator,
          {bool obscure = false, TextInputType keyboard = TextInputType.text}) =>
      TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.deepPurple)),
        obscureText: obscure,
        keyboardType: keyboard,
        validator: validator,
      );

  void _submit() {
    if (_formKey.currentState!.validate() && _agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("✅ Submitted: ${_nameCtrl.text}, ${_emailCtrl.text}, $_gender")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("❌ Please complete all fields!")),
      );
    }
  }
}
