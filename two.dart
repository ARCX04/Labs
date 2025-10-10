import 'package:flutter/material.dart';

void main() => runApp(const MyFormApp());

class MyFormApp extends StatelessWidget {
  const MyFormApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext c) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Form Validation",
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.deepPurple.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            labelStyle: const TextStyle(color: Colors.deepPurple),
            errorStyle: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
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
  final _name = TextEditingController(), _email = TextEditingController(), _pass = TextEditingController();
  String? _gender;
  bool _agree = false;

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text("Form with Validation"), elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Enter Your Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 20),
              _input(_name, "Full Name", Icons.person, (v) => v == null || v.isEmpty ? "Name is required" : v.length < 3 ? "Name must be at least 3 characters" : null),
              const SizedBox(height: 15),
              _input(_email, "Email", Icons.email, (v) => v == null || v.isEmpty ? "Email is required" : !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v) ? "Enter a valid email" : null, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _input(_pass, "Password", Icons.lock, (v) => v == null || v.isEmpty ? "Password is required" : v.length < 6 ? "Must be at least 6 characters" : !RegExp(r'[0-9]').hasMatch(v) ? "Include at least 1 number" : null, obscure: true),
              const SizedBox(height: 20),
              const Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Row(children: ["Male", "Female"].map((g) => _radio(g)).toList()),
              if (_gender == null)
                const Padding(padding: EdgeInsets.only(left: 12, top: 4), child: Text("Please select a gender", style: TextStyle(color: Colors.red, fontSize: 13))),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text("I agree to the Terms & Conditions"),
                value: _agree,
                activeColor: Colors.deepPurple,
                onChanged: (v) => setState(() => _agree = v!),
              ),
              if (!_agree)
                const Padding(padding: EdgeInsets.only(left: 12), child: Text("You must accept terms", style: TextStyle(color: Colors.red, fontSize: 13))),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Submit"),
                ),
              ),
            ]),
          ),
        ),
      );

  Widget _input(TextEditingController c, String label, IconData icon, String? Function(String?) v,
          {bool obscure = false, TextInputType keyboard = TextInputType.text}) =>
      TextFormField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.deepPurple)),
        validator: v,
      );

  Widget _radio(String val) => Expanded(
        child: RadioListTile<String>(
          value: val,
          groupValue: _gender,
          activeColor: Colors.deepPurple,
          title: Text(val),
          onChanged: (v) => setState(() => _gender = v),
        ),
      );

  void _submit() {
    if (_formKey.currentState!.validate() && _gender != null && _agree) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text("✅ Submitted: ${_name.text}, ${_email.text}, $_gender"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text("❌ Please correct the errors above!"),
      ));
    }
  }
}
