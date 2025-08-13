import 'package:fkdatahub/retaildata/payment/afapayment_page.dart';
import 'package:fkdatahub/retaildata/style/colors.dart';
import 'package:fkdatahub/retaildata/style/custom_date_range_picker.dart';
import 'package:fkdatahub/retaildata/style/utils/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {



  TextEditingController rphoneController = TextEditingController();
  TextEditingController alertphoneController = TextEditingController();
  TextEditingController occupController = TextEditingController();
  TextEditingController fnameController = TextEditingController();
  TextEditingController gcardController = TextEditingController();
  var dob1,dob2;
  var selbtn="ishare",alerttext="", receivetext,_selectedDate = "",_selectedDatefinal = "",
                                      _selectedFullDate="";
  final FocusNode _focusReceive = FocusNode();
  final FocusNode _focusAlert = FocusNode();
  final FocusNode _focusOccup = FocusNode();
  final FocusNode _focusGCard = FocusNode();
  final FocusNode _focusFName = FocusNode();
  DateTime? startDate;
  DateTime? endDate;



  registerDialog(String netimage, mytitle) {
    return showDialog(
        //barrierColor: Colors.transparent,
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
            return SizedBox(
                // height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
              //ainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "MTN AFA \nREGISTRATION",
                        style: TextStyle(
                          fontSize: 22,
                          color:  Color.fromARGB(255, 85, 78, 15),
                          fontWeight: FontWeight.bold,
                          //decoration: TextDecoration.underline,
                          //decorationThickness: 2
                        ),
                      ),
                    )),
                    InkWell(
                        onTap: () {
                          //if (mounted) {
                          setDialogState(() {
                            rphoneController.text = "";
                            alertphoneController.text = "";
                            //}
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Card(
                            color: Colors.red,
                            child: SizedBox(
                              height: 35,
                              child: Center(
                                  child: Text(
                                "   X   ",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                            )))
                  ],
                ),
                //Divider(color: Colors.black),
                //Text(mytext)

                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Card(
                          elevation: 5,
                          child: Image.asset(
                            "assets/mtnafa.jpeg",
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Full Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                     
                      const SizedBox(height: 10.0),
                      TextFormField(

                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: fnameController,
                        focusNode: _focusFName,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: 'Enter Full name ',
                          labelStyle: const TextStyle(
                              color: Colors.black54, fontSize: 16.0),
                        ),
                      ),
                     
                      const SizedBox(height: 20.0),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Phone Number",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      
                      const SizedBox(height: 10.0),
                      TextFormField(

                        // Optional: Remove spaces while typing
          onChanged: (text) async {
            String noSpacesText = text.replaceAll(RegExp(r'\s+'), '');
            if (text != noSpacesText) {
              rphoneController.value = TextEditingValue(
                text: noSpacesText,
                selection: TextSelection.collapsed(offset: noSpacesText.length),
              );
            }
            
             final clipboardData = await Clipboard.getData('text/plain');
        final clipboardText = clipboardData?.text ?? '';
        
        // Check if the new text contains clipboard content
        if (clipboardText.isNotEmpty && text.contains(clipboardText)) {
         if(rphoneController.text.length>9){
        String finalnumber = rphoneController.text .substring(rphoneController.text.length - 9);
        setDialogState(() {
          rphoneController.text = "0$finalnumber";
        });
          }
        }
          else{
            if(rphoneController.text.length>10){
              setDialogState(() {
                
                rphoneController.text=receivetext;
              });
            }else{
              setState(() {
                receivetext=rphoneController.text;
              });
              
            }
          }
          },
          /*inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Block manual non-number input
          LengthLimitingTextInputFormatter(10),// set entry length to 10
        ],*/
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: rphoneController,
                        focusNode: _focusReceive,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.local_phone),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: 'The Number',
                          labelStyle: const TextStyle(
                              color: Colors.black54, fontSize: 16.0),
                        ),
                      ),
                    
                    
                      const SizedBox(height: 20.0),
                      
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Ghana Card Number",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                     
                      const SizedBox(height: 10.0),
                      TextFormField(
                        onChanged: (text) async {
            String noSpacesText = text.replaceAll(RegExp(r'\s+'), '');
            if (text != noSpacesText) {
              gcardController.value = TextEditingValue(
                text: noSpacesText,
                selection: TextSelection.collapsed(offset: noSpacesText.length),
              );
            }
            
      
            if(gcardController.text.length==9){
              setDialogState(() {
                
                gcardController.text="${gcardController.text}-";
              });
            
          }
          },
          /*inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Block manual non-number input
          LengthLimitingTextInputFormatter(10),// set entry length to 10
        ],*/
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: gcardController,
                        focusNode: _focusGCard,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.local_phone),
                          prefixText: "GHA-",
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: 'GHA-xxxxxxxxx-x',
                          labelStyle: const TextStyle(
                              color: Colors.black54, fontSize: 16.0),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Occupation",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                     
                      const SizedBox(height: 10.0),
                      TextFormField(

                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: occupController,
                        focusNode: _focusOccup,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: 'Enter the occupation ',
                          labelStyle: const TextStyle(
                              color: Colors.black54, fontSize: 16.0),
                        ),
                      ),

                      const SizedBox(height: 20,),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Date of Birth",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.newClr1,)),
                                child: Center(
                                  child: Text(
                                    _selectedFullDate,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: AppColors.newClr1,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            InkWell(
                                onTap: () async {
                                  DateTime? mydate = await selectDate();

                                  if (mydate != null) {
                                    setDialogState(() {
                                      _selectedDate = DateFormat("dd-MM-yyyy")
                                          .format(mydate);
                                     _selectedDatefinal = DateFormat("yyyy-mm-dd")
                                          .format(mydate);
                                      _selectedFullDate =
                                          DateFormat('d MMM, yyyy')
                                              .format(mydate);
                                      /*_selectedDay =
                                          DateFormat("d").format(mydate);
                                      _selectedMonth =
                                          DateFormat("MMM").format(mydate);
                                      _selectedFMonth =
                                          DateFormat("MMMM").format(mydate);
                                      _selectedYear =
                                          DateFormat("yyyy").format(mydate);*/
                                    });

                                    /*if (_selectedDate ==
                                        DateFormat("dd-MM-yyyy")
                                            .format(DateTime.now())) {
                                      title = "Today";
                                    } else {
                                      title = "History";
                                    }*/
                                    //showDialogLoading();
                                    //getUsersPastTripsStreamSnapshots();
                                    //
                                  }

                                  // print(_selectedFullDate.toString());
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>DropDown()));
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: AppColors.newClr1,
                                      //border: Border.all(
                                        //  color: Colors.yellow, width: 3),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(
                                    Icons.calendar_month,
                                    color: Colors.white,
                                  ),
                                )),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),


                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(height: 20.0),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "SMS Alert & Status Check",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Enter Phone Number"),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        onChanged: (text) async {
            String noSpacesText = text.replaceAll(RegExp(r'\s+'), '');
            if (text != noSpacesText) {
              alertphoneController.value = TextEditingValue(
                text: noSpacesText,
                selection: TextSelection.collapsed(offset: noSpacesText.length),
              );
            }
            
             final clipboardData = await Clipboard.getData('text/plain');
        final clipboardText = clipboardData?.text ?? '';
        
        // Check if the new text contains clipboard content
        if (clipboardText.isNotEmpty && text.contains(clipboardText)) {
         if(alertphoneController.text.length>9){
        String finalnumber = alertphoneController.text .substring(alertphoneController.text.length - 9);
        setDialogState(() {
          alertphoneController.text = "0$finalnumber";
        });
          }
        }
          else{
            if(alertphoneController.text.length>10){
              setDialogState(() {
                
                alertphoneController.text=alerttext;
              });
            }else{
              setState(() {
                alerttext=alertphoneController.text;
              });
              
            }
          }
          },
          /*inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Block manual non-number input
          LengthLimitingTextInputFormatter(10),// set entry length to 10
        ],*/
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: alertphoneController,
                        focusNode: _focusAlert,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.local_phone),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: 'eg. 0553123698',
                          labelStyle: const TextStyle(
                              color: Colors.black54, fontSize: 16.0),
                        ),
                      ),

                      const SizedBox(height: 20,),
                      const Divider(),

                      Card(
                        color: AppColors.secondaryBg,
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            const SizedBox(height: 10,),
                            const Text("Payment Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                            ),
                            const SizedBox(height: 5,),
                            const Divider(),
                            Row(
                          children: [
                            Expanded(child: Container(
                              child: const Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Registration")),
                            Align(
                              alignment: Alignment.centerLeft,
                              child:Text("Fee : ")),
                          ],
                        ),
                            )),
                            Container(
                              child:  const Column(
                          children: [
                            Text("GH₵",
                            style: TextStyle(
                              color: Color.fromARGB(255, 207, 27, 14),
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ),
                            ),
                            Text("8.0",
                            style: TextStyle(
                              color: Color.fromARGB(255, 207, 27, 14),
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ),
                            )
                          ],
                        ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5,),
                          ],
                        ),
                      )),

                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                          onTap: () async {
                            if(rphoneController.text.trim().isEmpty){
                              setDialogState(() {
                                FocusScope.of(context).requestFocus(_focusReceive);
                              });
                              
                            }else if(alertphoneController.text.trim().isEmpty){
                              setDialogState(() {
                              FocusScope.of(context).requestFocus(_focusAlert);
                              }); 
                            }else{
                            showDialogProcessing();
                             Future.delayed(const Duration(seconds: 2), () async {
                              Navigator.of(context).pop();
                              //Navigator.of(context).pop();
                              var orderid =
                                DateFormat("ayyMdhms").format(DateTime.now());
                               // showPayInfoDialog(orderid);
                               
                             final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AFAPaystackPaymentPage(
                            amount:10,
                            email:"${orderid.toLowerCase()}@gmail.com",
                            reference:orderid,
                           // network: mytitle=="MTN"?'mtn':mytitle=="TELECEL"?'telecel':selbtn,
                                receiver: rphoneController.text,
                               //capacity : selcapacity,
                                alert_sms:
                                    alertphoneController.text,
                                date : DateFormat("dd-mm-yyyy")
                                    .format(DateTime.now()),
                                time: DateFormat("h:mm aa")
                                    .format(DateTime.now()),
                          ),
                        ),
                             );

                             result=="No Payment"?
                             null
                             :
                             setDialogState(() {
                              // title2 = "-- Choose Bundle --";
                            rphoneController.text = "";
                            alertphoneController.text = "";
                           // getbalance();
                            Navigator.of(context).pop();
                             });

                            });
                            
                            }
                          },
                          child: const Card(
                              color:Color.fromARGB(255, 253, 229, 11),
                              elevation: 5,
                              child: SizedBox(
                                height: 40,
                                child: Center(
                                  child:Text("Buy Now",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                ),
                              ))),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                )),
              ],
            ));
          }));
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register AFA', 
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),
        ),
        centerTitle: true,
        foregroundColor: AppColors.newClr1,
       backgroundColor: AppColors.secondaryBg,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Action Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // AFA Registration Card
                _buildActionCard(
                  context,
                  icon: Icons.person_add_alt_rounded,
                  title: 'AFA Registration',
                  subtitle: 'Register new members',
                  color: Colors.blue,
                  onTap: () {
                    registerDialog("","");
                  },
                ),
                const SizedBox(height: 16),
                
                // Check Status Card
                _buildActionCard(
                  context,
                  icon: Icons.assignment_turned_in_rounded,
                  title: 'Check Status',
                  subtitle: 'View registration details',
                  color: Colors.green,
                  onTap: () {
                    showStatusCheck();
                   /*showCustomDateRangePicker(
            context,
            dismissible: true,
            minimumDate: DateTime.now().subtract(const Duration(days: 30)),
            maximumDate: DateTime.now().add(const Duration(days: 30)),
            endDate: endDate,
            startDate: startDate,
            backgroundColor: Colors.white,
            primaryColor: Colors.green,
            onApplyClick: (start, end) {
              setState(() {
                endDate = end;
                startDate = start;
              });
            },
            onCancelClick: () {
              setState(() {
                endDate = null;
                startDate = null;
              });
            },
          );*/
        },
        //tooltip: 'choose date Range',
        //child: const Icon(Icons.calendar_today_outlined, color: Colors.white),
      //),
    ),
              ]),
          ),
              
  
          
          // Divider
          const Divider(height: 1),
          
          // Recent Registrations Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Registrations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Empty State
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No registrations found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
  ],
            ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }


     Future<DateTime?> selectDate() async {
    return await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      initialDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: secondaryColor,
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: const ColorScheme.light(primary: secondaryColor)
                .copyWith(secondary: secondaryColor),
          ),
          child: child ?? const SizedBox(),
        );
      },
      firstDate: DateTime.now().subtract(const Duration(days: 300000)),
      lastDate: DateTime.now(),
    );
  }


  showDialogProcessing() {
    return showDialog(
        context: context,
        //barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              content: Container(
            height: 80,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/process.gif'), fit: BoxFit.fill)),
          ));
        });
  }

  showStatusCheck() {
    return showDialog(
        context: context,
        //barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return  AlertDialog(content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
            return SizedBox(
                // height: MediaQuery.of(context).size.height * 0.6,
                child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                const SizedBox(height: 30.0),
                     
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Enter Phone Number"),
                      ),
                                          
                      const SizedBox(height: 10.0),
                      TextFormField(

                        // Optional: Remove spaces while typing
          onChanged: (text) async {
            String noSpacesText = text.replaceAll(RegExp(r'\s+'), '');
            if (text != noSpacesText) {
              rphoneController.value = TextEditingValue(
                text: noSpacesText,
                selection: TextSelection.collapsed(offset: noSpacesText.length),
              );
            }
            
             final clipboardData = await Clipboard.getData('text/plain');
        final clipboardText = clipboardData?.text ?? '';
        
        // Check if the new text contains clipboard content
        if (clipboardText.isNotEmpty && text.contains(clipboardText)) {
         if(rphoneController.text.length>9){
        String finalnumber = rphoneController.text .substring(rphoneController.text.length - 9);
        setDialogState(() {
          rphoneController.text = "0$finalnumber";
        });
          }
        }
          else{
            if(rphoneController.text.length>10){
              setDialogState(() {
                
                rphoneController.text=receivetext;
              });
            }else{
              setState(() {
                receivetext=rphoneController.text;
              });
              
            }
          }
          },
          /*inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // Block manual non-number input
          LengthLimitingTextInputFormatter(10),// set entry length to 10
        ],*/
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        controller: rphoneController,
                        focusNode: _focusReceive,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.local_phone),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: 'eg. 0553123698',
                          labelStyle: const TextStyle(
                              color: Colors.black54, fontSize: 16.0),
                        ),
                      ),
              ],)
              );
              }
              )
              );
        
        });
  }

}