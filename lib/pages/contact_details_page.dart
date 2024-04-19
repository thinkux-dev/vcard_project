import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vcard_project/models/contact_model.dart';
import 'package:vcard_project/providers/contact_provider.dart';
import 'package:vcard_project/utils/helper_function.dart';

class ContactDetailsPage extends StatefulWidget {
  static const String routeName = 'contact_details';
  final int id;
  const ContactDetailsPage({super.key, required this.id});

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  late int id;

  @override
  void initState() {
    id = widget.id;
    print('id:  $id');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child) => FutureBuilder<ContactModel>(
          future: provider.getContactById(id),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              final contact = snapshot.data!;
              print(contact);
              return ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  Image.file(File(contact.image), width: double.infinity, height: 250, fit: BoxFit.cover,),
                  ListTile(
                    title: Text(contact.mobile),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            callContact(contact.mobile);
                          },
                          icon: const Icon(Icons.call),
                        ),
                        IconButton(
                          onPressed: () {
                            smsContact(contact.mobile);
                          },
                          icon: const Icon(Icons.sms),
                        )
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(contact.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            mailContact(contact.email);
                          },
                          icon: const Icon(Icons.mail),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(contact.website),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            contactWebsite(contact.website);
                          },
                          icon: const Icon(Icons.language),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(contact.address),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showContactMap(contact.address);
                          },
                          icon: const Icon(Icons.map),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            if(snapshot.hasError) {
              return const Center(
                child: Text('Failed to load data please check your connection and try again',),
              );
            }
            return const Center(child: Text('Please wait...'),);
          }
        ),
      ),
    );
  }

  void callContact(String mobile) async{
    final url = 'tel:$mobile';
    if(await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      showMsg(context, 'Cannot perform this task');
    }
  }

  void smsContact(String mobile) async {
    final url = 'sms:$mobile';
    if(await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      showMsg(context, 'Cannot perform this task');
    }
  }

  void mailContact(String email) async {
    final url = 'mailto:$email';
    if(await canLaunchUrlString(url)) {
      await canLaunchUrlString(url);
    } else {
      showMsg(context, 'Cannot perform this task');
    }
  }

  void contactWebsite(String website) async {
    final url = 'https://$website';
    if(await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      showMsg(context, 'Cannot perform this task');
    }
  }

  void showContactMap(String address) async {
    String mapUrl = '';
    if(Platform.isAndroid) {
      mapUrl = 'geo:0,0?q=$address';
    } else {
      mapUrl = 'http://maps.apple.com/?q=$address';
    }
    if(await canLaunchUrlString(mapUrl)) {
      await launchUrlString(mapUrl);
    } else {
      showMsg(context, 'Cannot perform this task');
    }
  }
}
