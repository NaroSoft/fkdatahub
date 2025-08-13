import 'package:fkdatahub/retaildata/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String message = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  void _launchWhatsApp() async {
    const phoneNumber = '233553123698'; // WITHOUT '+'
     var whatsappUrl = Uri.parse(
                     "whatsapp://send?phone=$phoneNumber" 
                     "&text=${Uri.encodeComponent("Hello FKDataHub!")}");
     try {
       launchUrl(whatsappUrl);
     } catch (e) {
       debugPrint(e.toString());
     }}
  
void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'fkdatahub@gmail.com',
      query: Uri.encodeFull('subject=Customer Complaint&body=Write your complaint here...'),
    );

    if (!await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open Email client';
    }
  }


  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF003366); // Deep blue

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us",
        style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.secondaryBg,
        centerTitle: true,
        foregroundColor: AppColors.newClr1,
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: Colors.transparent,
        onPressed: _launchWhatsApp,
        child: Image.asset("assets/whatsapp.png",),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            // Info Section
            Card(
              color: primaryColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'FKDataHub is Ghana’s trusted platform for affordable mobile data bundles. We connect you with the best offers from MTN, Telecel, and AirtelTigo — all in one place!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Form Section
            const Text(
              'Email Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 12),
             // Email Info Card
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.email, color: primaryColor),
                title: const Text('Email Us Your Complaints'),
                subtitle: const Text('fkdatahub@gmail.com'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _launchEmail,
              ),
            ),
            const SizedBox(height: 50),

            // WhatsApp Section
            Center(
              child: ElevatedButton.icon(
                onPressed: _launchWhatsApp,
                icon: const Icon(Icons.chat_outlined, color: Colors.white60,),
                label: const Text("Chat with us on WhatsApp"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
