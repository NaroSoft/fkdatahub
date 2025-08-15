import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fkdatahub/retaildata/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class STATUSCHECK extends StatefulWidget {
  const STATUSCHECK({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<STATUSCHECK> {
  final TextEditingController _numberController = TextEditingController();
  String _searchType = 'Recipient Number';
  DateTime? _selectedDate;
  List _results = [];
  bool isChecked = false;
  bool isEnabled = true; // Control this based on your logic
  String seldate="dd-mm-yyyy";
  String seltype="Recipient Number";
  var chkload="done";

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        seldate=DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

   _search() async {
    //final uid = await Provider.of(context).au
    DateFormat dateFormat = DateFormat("EEE, MMM d, yyyy");
    DateFormat timeFormat = DateFormat("hh:mm a");
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
    List initdata=[];
    setState(() {
      _results=[];
      chkload="loading";
    });
    var data;
    if(_searchType=="Recipient Number"){
      data =
        await FirebaseFirestore.instance.collection('orderlist')
        .where("receiver", isEqualTo: _numberController.text)
        .where("month_no", isEqualTo: num.tryParse(DateFormat('M').format(DateTime.now())))
        .where("year", isEqualTo: DateFormat('yyyy').format(DateTime.now()))
        .orderBy('day', descending: true)
        .orderBy('timestamp', descending: true)
        .get();
    }else{
      data =
        await FirebaseFirestore.instance.collection('orderlist')
        .where("alert_sms", isEqualTo: _numberController.text)
        .where("month_no", isEqualTo: num.tryParse(DateFormat('M').format(DateTime.now())))
        .where("year", isEqualTo: DateFormat('yyyy').format(DateTime.now()))
        .orderBy('day', descending: true)
        .orderBy('timestamp', descending: true)
        .get();
    }
    
    setState(() {
      initdata = data.docs;
    });
    for(int k=0;k<initdata.length;k++){
      if(initdata[k]["status"]=="completed"){
        _results.add(initdata[k]);
      }else{

        const String authToken =
        "4|0B7htFoaRvAqWEO92DPI5F2H48Vc8PT3Hknh0quF10715605";
    //final dio = Dio();
    try {
      // var request = http.Request('GET', Uri.parse('http://127.0.0.1:8000/api/v1/walletBalance'));
      //Map<String, dynamic> getbal = [];
      final response = await http.get(
        Uri.parse('https://test.gdsonline.app/api/v1/checkOrderStatus/${initdata[k]["reference"]}'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      Map<String, dynamic> getbal = jsonDecode(response.body);

      //final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // 200 indicates success
        //String rawbalnce = getbal["status"].toString();
        _results.add({
          "receiver": initdata[k]["receiver"],
          "alert_sms": initdata[k]["alert_sms"],
          "amount": initdata[k]["amount"],
          "buy_price": initdata[k]["buy_price"],
          "full_date": initdata[k]["full_date"],
          "month_no": initdata[k]["month_no"],
          "network": initdata[k]["network"],
          "price": initdata[k]["price"],
          "profit": initdata[k]["profit"],
          "reference": initdata[k]["reference"],
          "status": getbal['data']['order']['status'].toString(),
          "time": initdata[k]["time"],
          "year": initdata[k]["year"],
      });
     Map<String, dynamic> orderlist =
                                    new Map<String, dynamic>();

                                
                                orderlist["status"] = getbal['data']['order']['status'].toString();
                                
                                FirebaseFirestore.instance
                                    .collection('orderlist')
                                    .doc(initdata[k]["reference"])
                                    .update(orderlist);

      } else{
          _results.add({
          "receiver": initdata[k]["receiver"],
          "alert_sms": initdata[k]["alert_sms"],
          "amount": initdata[k]["amount"],
          "buy_price": initdata[k]["buy_price"],
          "full_date": initdata[k]["full_date"],
          "month_no": initdata[k]["month_no"],
          "network": initdata[k]["network"],
          "price": initdata[k]["price"],
          "profit": initdata[k]["profit"],
          "reference": initdata[k]["reference"],
          "status": "pending",
          "time": initdata[k]["time"],
          "year": initdata[k]["year"],
      });
      }
    } catch (e) {
      print("Error: $e");
    }

      }
      }
    setState(() {
     // _results = data.docs;
      chkload="done";
    });
    return "complete";
      
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
                Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _searchType,
                        decoration: const InputDecoration(
                          labelText: 'Select Search Type',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Recipient Number', 'Alert Number']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) => setDialogState(() => _searchType = value!),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _numberController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Number (Max 10)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                      ),
                      const SizedBox(height: 5),

                      /*Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("  Select Date"),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(isChecked? "Enabled    ":"Disabled    ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isChecked?const Color.fromARGB(255, 27, 145, 31):const Color.fromARGB(255, 200, 56, 46)
                        ),
                        ),
                      ),
                        ]),
                      Row(
                        children: [
                          
                          /*Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.newClr1,
                              ),
                              onPressed: _pickDate,
                              icon: const Icon(Icons.date_range, color: Colors.white54,),
                              label: Text(_selectedDate == null ? 'Select Date' : '${_selectedDate!.toLocal()}'.split(' ')[0],
                              style: const TextStyle(
                                //fontSize: 12,
                                color: Colors.white
                              ),
                              ),
                            ),
                          ),*/
                          const SizedBox(width: 5),
                          SizedBox(
                            width: 100,
                            child: CheckboxListTile(
  //title: Text('Enable'),
  value: isChecked,
  activeColor: AppColors.newClr1,
  onChanged: (bool? value) {
    setDialogState(() {
              isChecked = value ?? false;
              seldate="dd-mm-yyyy";
            });
  },
)),
                        ],
                      ),

                       Card(
  color: isEnabled ? AppColors.secondaryBg : Colors.grey[300],
  elevation: isChecked ? 4 : 0,
  child: InkWell(
    onTap: isChecked
        ? () async {
            // Your onTap logic here
             DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setDialogState(() {
        _selectedDate = picked;
        seldate=DateFormat('MMM d, yyyy').format(picked);
      });
    }
          }
        : null, // Disables tap when false
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          
          Text(
            isEnabled ? seldate : 'Disabled',
            style: TextStyle(
              fontSize: 17,
              fontWeight: isChecked?FontWeight.bold:FontWeight.normal,
              color: isChecked ? Colors.black : Colors.grey),
          ),
        ],
      ),
    ),
  ),
),*/

                      const SizedBox(height: 20,),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.newClr1,
                              ),
                              onPressed: _search,
                              icon: const Icon(Icons.search, color: Colors.white54,),
                              label: const Text('Search',
                              style: TextStyle(color: Colors.white),
                              ),
                            ),
                      )
                    ],
                  ),
                ),
              ),
              ],)
              );
              }
              )
              );
        
        });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBg,
      appBar: AppBar(
        title: const Text('Status Check',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          
        ),
        ),
        foregroundColor: AppColors.newClr1,
        centerTitle: true,
        backgroundColor: AppColors.secondaryBg,
        elevation: 5,
        
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 4, 24, 83),
        elevation: 5,
        foregroundColor: Colors.white,
        onPressed: showStatusCheck, 
        label: const Row(children:[Icon(Icons.search, color: Colors.white54,), SizedBox(width: 5),Text("Search")]),
        
        ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5, left: 16,right: 16,bottom: 5),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             /* Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _searchType,
                        decoration: const InputDecoration(
                          labelText: 'Select Search Type',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Recipient Number', 'Alert Number']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) => setState(() => _searchType = value!),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _numberController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Number (Max 10)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                      ),
                      const SizedBox(height: 5),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("  Select Date"),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(isChecked? "Enabled    ":"Disabled    ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isChecked?const Color.fromARGB(255, 27, 145, 31):const Color.fromARGB(255, 200, 56, 46)
                        ),
                        ),
                      ),
                        ]),
                      Row(
                        children: [
                          Expanded(child: Card(
  color: isEnabled ? AppColors.secondaryBg : Colors.grey[300],
  elevation: isChecked ? 4 : 0,
  child: InkWell(
    onTap: isChecked
        ? () {
            // Your onTap logic here
            _pickDate();
          }
        : null, // Disables tap when false
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          
          Text(
            isEnabled ? seldate : 'Disabled',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isChecked?FontWeight.bold:FontWeight.normal,
              color: isChecked ? Colors.black : Colors.grey),
          ),
        ],
      ),
    ),
  ),
)),
                          /*Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.newClr1,
                              ),
                              onPressed: _pickDate,
                              icon: const Icon(Icons.date_range, color: Colors.white54,),
                              label: Text(_selectedDate == null ? 'Select Date' : '${_selectedDate!.toLocal()}'.split(' ')[0],
                              style: const TextStyle(
                                //fontSize: 12,
                                color: Colors.white
                              ),
                              ),
                            ),
                          ),*/
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 100,
                            child: CheckboxListTile(
  //title: Text('Enable'),
  value: isChecked,
  activeColor: AppColors.newClr1,
  onChanged: (bool? value) {
    setState(() {
              isChecked = value ?? false;
              seldate="dd-mm-yyyy";
            });
  },
)),
                        ],
                      ),

                      const SizedBox(height: 5,),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.newClr1,
                              ),
                              onPressed: _search,
                              icon: const Icon(Icons.search, color: Colors.white54,),
                              label: const Text('Search',
                              style: TextStyle(color: Colors.white),
                              ),
                            ),
                      )
                    ],
                  ),
                ),
              ),*/
              const SizedBox(height: 20),
              _results.isEmpty && chkload=="done"
                  ? const Expanded(child: SizedBox(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60,color: Color.fromARGB(255, 178, 39, 29),),
                      SizedBox(height: 15,),
                    Text(
                        'No Results found',
                        style: TextStyle(color: Colors.red, fontSize: 18,fontWeight: FontWeight.bold),
                      ),
                   ])))
                   :
                   _results.isEmpty && chkload=="loading"
                  ? const Expanded(child: SizedBox(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                      ),
                      SizedBox(height: 15,),
                    Text(
                        'Loading........',
                        style: TextStyle(color: AppColors.newClr1, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                   ])))
                  :  _results.isNotEmpty && chkload=="loading"
                  ? const Expanded(child: SizedBox(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                      ),
                      SizedBox(height: 15,),
                    Text(
                        'Loading........',
                        style: TextStyle(color: AppColors.newClr1, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                   ])))
                  : Expanded(child: Container(child: SingleChildScrollView(
          child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListView.separated(
                          separatorBuilder: (context, index) => const SizedBox(height: 15,),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _results.length,
                          itemBuilder: (context, index) => Card(
                            elevation: 5,
                            color: const Color.fromARGB(255, 197, 197, 219),
                            child: ListTile(
                              title: Column(
                                children: [
                                  Center(child: Text(_results[index]['full_date'],
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 75, 3, 116),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16
                                  ),
                                  ),),
                                  const Divider(color: Colors.black54,thickness: 2,),
                                  Row(
                                    children: [
                                      Card(
                          elevation: 5,
                          child: Image.asset(
                            _results[index]['network'] =="afa-talktime"?"assets/speak.png" :
                            _results[index]['network'] =="mtn"?"assets/mtn1.png" :
                            _results[index]['network'] =="mtn"?"assets/speak.png"
                            : _results[index]['network'] =="telecel"?"assets/telecel1.png":"assets/airtel1.jpeg",
                            height: 60,
                            width: 70,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(width: 5,),
                        SizedBox(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Receiver : ",
                                    style: TextStyle(
                                      color: Colors.black54
                                    )
                                  ),
                                  TextSpan(
                                    text: "${_results[index]['receiver']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.newClr1
                                    )
                                  )
                                ]
                              )
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Capacity : ",
                                    style: TextStyle(
                                      color: Colors.black54
                                    )
                                  ),
                                  TextSpan(
                                    text: _results[index]['network']=="afa-talktime"? "${_results[index]['amount']} mins":
                                    "${_results[index]['amount']} GIG",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 12, 67, 14)
                                    )
                                  )
                                ]
                              )
                            ),
                     Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Price : ",
                                    style: TextStyle(
                                      color: Colors.black54
                                    )
                                  ),
                                  TextSpan(
                                    text: "GH₵ ${_results[index]['price']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 202, 47, 35)
                                    )
                                  )
                                ]
                              )
                            ),
                          ],
                        ),)
                        
                                    ],
                                  ),
                                  const Divider(color: Colors.black54,thickness: 2,),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Ref# : ",
                                    style: TextStyle(
                                      color: Colors.black54
                                    )
                                  ),
                                  TextSpan(
                                    text: "${_results[index]['reference']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic
                                    )
                                  )
                                ]
                              )
                            ),
                            
                                   Row(children: [
                              Expanded(child: Container(
                                child: Column(
                                  children: [
                                    const Text("Status : "),
                                    Card(
                                      color: _results[index]['status']=="pending"?const Color.fromARGB(108, 255, 235, 59)
                                          :_results[index]['status']=="processing"?const Color.fromARGB(106, 6, 30, 153)
                                          :const Color.fromARGB(91, 9, 84, 11) ,
                                      elevation: 5,
                                      child: Container(
                                        height: 30,
                                        child: Center(child: Text(
                                          _results[index]['status']=="pending"?"pending"
                                          :_results[index]['status']=="processing"?"processing"
                                          :_results[index]['status'],
                                        style:  TextStyle(
                                          color: _results[index]['status']=="pending"?Colors.black:Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                        )),
                                      )
                                    )
                                  ],
                                ),
                              ),),
                              Expanded(child: Container( child: Column(
                                  children: [
                                    const Text("Time : "),
                                     Text(_results[index]['time'],
                                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 89, 94, 126)),
                                     ),
                                  
                                  ],
                                ),),),
                            ],),
                            const SizedBox(height: 10,),
                                _results[index]['status']=="completed"? 
                                InkWell(
                                  onTap: (){
                                    _launchWhatsApp(_results[index]['reference']);
                                    },
                                  child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Card(
                                      color: const Color.fromARGB(255, 74, 73, 73) ,
                                      elevation: 5,
                                      child: Container(
                                        width: 130,
                                        padding: const EdgeInsets.only(left: 10),
                                        height: 35,
                                        child:const Row(children: [
                                          Icon(Icons.person_sharp, color: Colors.white54,),
                                          Text(" Complain ",
                                        style:  TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                        ),
                                        Icon(Icons.arrow_forward_ios_rounded, color:Colors.white60,)
                                        ],)
                                      )
                                ))):const SizedBox(height: 1,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      ],
                  )))),


                    const SizedBox(height: 30,),
                    Align(
                          alignment: Alignment.centerLeft,
                          child: Text(chkload=="loading"? "    Loading ...":
                            '    Total Results: ${_results.length}',
                            style: const TextStyle(
                                color: AppColors.newClr1, fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 25,),
            ],
          ),
        ),
    );
  }

   _launchWhatsApp(String msg) async {
    const phoneNumber = '233553123698'; // WITHOUT '+'
     var whatsappUrl = Uri.parse(
                     "whatsapp://send?phone=$phoneNumber" 
                     "&text=${Uri.encodeComponent("**Hello FKDataHub!**.\nI have a complain on the Order Reference : *$msg*.\n\n")}");
     try {
       launchUrl(whatsappUrl);
     } catch (e) {
       debugPrint(e.toString());
     }}
}
