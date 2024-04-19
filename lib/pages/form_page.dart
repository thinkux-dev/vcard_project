import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vcard_project/models/contact_model.dart';
import 'package:vcard_project/pages/home_page.dart';
import 'package:vcard_project/providers/contact_provider.dart';
import 'package:vcard_project/utils/constants.dart';
import 'package:vcard_project/utils/helper_function.dart';

class FormPage extends StatefulWidget {
  static const String routeName = 'form';
  final ContactModel contactModel;
  const FormPage({super.key, required this.contactModel});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final webController = TextEditingController();
  final designationController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.contactModel.name;
    mobileController.text = widget.contactModel.mobile;
    emailController.text = widget.contactModel.email;
    addressController.text = widget.contactModel.address;
    companyController.text = widget.contactModel.company;
    webController.text = widget.contactModel.website;
    designationController.text = widget.contactModel.designation;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Details'),
        actions: [
          IconButton(
            onPressed: saveContact,
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Contact Name',
                icon: Icon(Icons.person)
              ),
              validator: (value) {
                if(value == null || value.isEmpty) {
                  return emptyFieldErrMsg;
                }
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: mobileController,
              decoration: InputDecoration(
                  labelText: 'Mobile Contact',
                  icon: Icon(Icons.phone)
              ),
              validator: (value) {
                if(value == null || value.isEmpty) {
                  return emptyFieldErrMsg;
                }
                return null;
              },
            ),
            TextFormField(
              controller: designationController,
              decoration: InputDecoration(
                  labelText: 'Designation',
                  icon: Icon(Icons.lightbulb_circle),
              ),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              decoration: InputDecoration(
                  labelText: 'Contact Email',
                  icon: Icon(Icons.email)
              ),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                  labelText: 'Street Address',
                  icon: Icon(Icons.location_city)
              ),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              controller: companyController,
              decoration: InputDecoration(
                  labelText: 'Company',
                  icon: Icon(Icons.business_center)
              ),
              validator: (value) {
                return null;
              },
            ),
            TextFormField(
              controller: webController,
              decoration: InputDecoration(
                  labelText: 'Website',
                  icon: Icon(Icons.language)
              ),
              validator: (value) {
                return null;
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    companyController.dispose();
    designationController.dispose();
    webController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void saveContact() async {
    if(_formKey.currentState!.validate()) {
      widget.contactModel.name = nameController.text;
      widget.contactModel.mobile = mobileController.text;
      widget.contactModel.email = emailController.text;
      widget.contactModel.address = addressController.text;
      widget.contactModel.company = companyController.text;
      widget.contactModel.designation = designationController.text;
      widget.contactModel.website = webController.text;
    }
    
    // print(widget.contactModel);
    Provider.of<ContactProvider>(context, listen: false)
      .insertContact(widget.contactModel)
      .then((value) {
        if(value > 0) {
          showMsg(context, 'Saved');
          context.goNamed(HomePage.routeName);
        }
      })
      .catchError((onError) {
        showMsg(context, 'Failed to save');
      }
    );
  }
}
