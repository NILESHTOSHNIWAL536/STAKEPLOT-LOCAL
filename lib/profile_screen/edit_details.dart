import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditDetails extends StatefulWidget {
  const EditDetails({super.key});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
final Map<String, TextEditingController> _controllers = {
    'Username': TextEditingController(text: userName.value),
    'Email': TextEditingController(text: email.value),
    'Address': TextEditingController(text: '6-10-128/3/A/5/A, Budwel, Telangana'),
  };

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed from the tree
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : AssetImage("assets/profile_picture.png")
                          as ImageProvider,
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Change Profile Picture',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: AppColors.mt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildNonEditableField(
                      Icons.phone, "Phone Number", Phone.value),
                      Divider(),
                  _buildEditableField(
                      Icons.alternate_email, "Username", userName.value),
                      Divider(),
                  _buildNonEditableField(
                      Icons.person, "Full Name", "Rohit Sharma"),
                      Divider(),
                  _buildNonEditableField(
                      Icons.calendar_today, "Date of Birth", "01 April 2000"),
                      Divider(),
                  _buildEditableField(Icons.email, "Email", email.value),
                  Divider(),
                  _buildEditableField(Icons.location_on, "Address",
                      "6-10-128/3/A/5/A, Budwel, Telangana"),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: Text('Account details'),
            ),
            // Account Details
            _buildAccountDetails("SBI", "SB1XXXXXXXX"),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(IconData icon, String label, String value) {
    final controller = _controllers[label] ?? TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: TextField(
        controller: controller, // Use the controller to manage the text
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          hintText: value,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: const Icon(Icons.edit, color: Colors.blueGrey),
        ),
      ),
    );
  }

  Widget _buildNonEditableField(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          //labelText: value,
          border: InputBorder.none, // No border
          enabledBorder: InputBorder.none, // No border when not focused
          focusedBorder: InputBorder.none,
          hintText: value,
        ),
      ),
    );
  }

  Widget _buildAccountDetails(String bankName, String accountNumber) {
    return Card(
      //elevation: 2,
      child: ListTile(
        leading: Icon(Icons.account_balance, color: Colors.blue),
        title: Text(bankName),
        subtitle: Text(accountNumber),
        trailing: TextButton(
          onPressed: () {
            // Implement add bank functionality
          },
          child: const Text("+ Add Bank"),
        ),
      ),
    );
  }
}
