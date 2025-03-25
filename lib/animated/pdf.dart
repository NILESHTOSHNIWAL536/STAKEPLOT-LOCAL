import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;



 void getPdf(BuildContext context,RxString selectedValue,RxString selectedValueType) async
  {
          var response=await getDataApiCall("${url}/transactionauto/get-previous-transactions/${getPreviousDate(int.parse(selectedValue.value), selectedValueType.value)}");                            
          if(getFlagOfResponse(response))
          {
              var obj=jsonDecode(response.body);
              List list=obj['data'];
              if(list.length>0)
              {
                generatePdf(PdfPageFormat.legal,"StakePlot",list,context);
              }
          }
}



Future<pw.MemoryImage> loadLogo() async {
  final ByteData bytes = await rootBundle.load('assets/app_icon.png'); // Correct path
  final Uint8List byteList = bytes.buffer.asUint8List();
  return pw.MemoryImage(byteList);
}


 Future<void> generatePdf(PdfPageFormat format, String title,List data,contextBui) async {
    final pdf = pw.Document();
    final logo = await loadLogo(); // Load the logo
try{
    pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
              orientation: pw.PageOrientation.portrait,
              header: (context) =>tableHeaderCell1(logo),
              footer: (context) => tableFootercell(logo,context),
              build: (context) {
                return[   
                      buildPDFTable(data,contextBui),
                ];
              },
            ),
          );
      }catch(e){
          print("error"+e.toString());
      }
   getPdgLoader.value=false;
  
      Printing.layoutPdf(onLayout: (PdfPageFormat format) async=> pdf.save() );  

    //  pdf.save();
 }
 
pw.Widget tableFootercell(pw.MemoryImage logo,context) {
 return pw.Container(
  padding: pw.EdgeInsets.all(8),
  decoration: pw.BoxDecoration(
    border: pw.Border(
      top: pw.BorderSide(color: PdfColors.black, width: 1), // Bottom border for header
    ),
  ),
  child:  pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, // Adjust alignment
    children: [
      pw.Text(
        "Page ${context.pageNumber} of ${context.pagesCount}", // Page number
        style: pw.TextStyle(fontSize: 10),
      ),
      pw.Row(
        children: [
          pw.Image(logo, width: 30, height: 30), 
          pw.SizedBox(width: 10), 
          pw.Text(
            "StakePlot",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ],
  ),
);
 }



 printDoc(data,context,title){
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
            Header(),
            pw.SizedBox(height: 10,),
         
    ]);
 }

pw.Widget buildPDFTable(data,context) {
  final pdfContainers = <pw.Widget>[];
  int no=18;
  for (var i = 0; i < data.length; i += no) {
  List chunk = data.sublist(i, (i + no > data.length) ? data.length : i + no);
  pdfContainers.add(
    pw.Container(
      width: double.infinity, // Replace MediaQuery
      margin: pw.EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: tableContent(chunk), // Ensure tableContent handles chunk properly
    ),
  );
}

  return pw.Column(
    children: pdfContainers,
  );
}


  pw.Widget Header() {
       
       return  pw.Column(
        children:[
            TextStyleD("StakePlot",Colors.red,15.0),
            // TextStyleD("rice & broken rice canvassing agent",Colors.black,13.0),
            pw.SizedBox(height: 5,),

        ]
       );
  }


   pw.Widget TextStyleD(text,Color color,size){
      return  pw.Text(text,style: pw.TextStyle(
                              fontSize: size+4,
                              // color:,
                              fontWeight: pw.FontWeight.bold,
                              decoration: pw.TextDecoration.none,
                           ),
                          
                );
  }
 
 
tableContent(transactions) {
  
  return pw.Table(
    border: pw.TableBorder.all(
      color: PdfColors.black,
      width: 1,
    ),
    children: [
      // Table Header
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: PdfColors.blue300,
          border: pw.Border.all(width: .2),
        ),
        children: [
          tableHeaderCell("Date"),
          tableHeaderCell("Transaction Details"),
          tableHeaderCell("Type"),
          tableHeaderCell("Amount"),
          tableHeaderCell("Balance"),
        ],
      ),
      // Table Rows
      ...transactions.map((item) {
        return pw.TableRow(
          children: [
            tableCell(formatTimestamp(item['transactionTimestamp'])),
            tableMultilineCell(getDetails(item['narration'].toString(), item['type'],item['txnId'])), 
            tableCell(item['type'].toString()),
            tableCell(item['amount'].toString()),
            tableCell(item['currentBalance'].toString()),
          ],
        );
      }).toList(),
    ],
  );
}

// Helper function for table header
pw.Widget tableHeaderCell(String text) {
  return pw.Container(
    padding: pw.EdgeInsets.all(4),
    alignment: pw.Alignment.center,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
    ),
  );
}


pw.Widget tableHeaderCell1(logo) {
  return  pw.Container(
  padding: pw.EdgeInsets.all(8),
  decoration: pw.BoxDecoration(
    border: pw.Border(
      bottom: pw.BorderSide(color: PdfColors.black, width: 1), // Bottom border for header
    ),
  ),
  child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    children: [
      pw.Image(logo, width: 30, height: 30), 
      pw.SizedBox( width: 10), 
        pw.Text(
        "Transaction Statement for 8978958221",
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
      // Logo on the left
    ],
  ),
);
}

// Helper function for single-line table cells
pw.Widget tableCell(String text) {
  return pw.Container(
    padding: pw.EdgeInsets.all(4),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 6),
    ),
  );
}

// Helper function for multi-line table cells
pw.Widget tableMultilineCell(List<String> data) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: data.map((line) {
      return pw.Container(
        padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  child: pw.Text(
      line,
      style: pw.TextStyle(fontSize: 6),));
    }).toList(),
  );
}



String formatTimestamp(String timestamp) {
  try {
    DateTime dateTime = DateTime.parse(timestamp); // Parse string to DateTime
    return DateFormat('dd-MM-yyyy').format(dateTime); // Format as "YYYY-MM-DD h:mm a"
    // return DateFormat('yyyy-MM-dd h:mm a').format(dateTime); // Format as "YYYY-MM-DD h:mm a"
  } catch (e) {
    return timestamp; // Fallback value if parsing fails
  }
}


List<String> getDetails(transaction,type,id){
    try {
      List<String> parts = transaction.split('-');
      // print(parts);
      String txnType = ""+parts[0]; // UPI-DR or UPI-CR
      String txnId = ""+parts[1];
      String name = ""+parts[2];
      String bankCode = ""+parts[3];
      String paidto=type=="DEBIT"? "Paid to "+"$bankCode":"Received from "+"$bankCode";
      String accountNumber = (parts.length > 5 ? parts[4] : "");
      String description = (parts.length > 6 ? parts[5] : "");
      List<String> list=[];

      list.add(paidto);
      list.add(id);

    return   list;
    // return "Type: $txnType\nID: $txnId\nName: $name\nBank: $bankCode\nAccount: $accountNumber\nDesc: $description";
    } catch (e) {
       return [];
    }



}


// pw.Widget _buildNestedDetailsTable(List<Bill> details) {
//   double totalAmount=0;
//   List<List<String>> data = details.map<List<String>>((detail) {
//        double total= ( (double.parse(detail.bags.toString()) * double.parse(detail.rate.toString())* double.parse(detail.kg.toString())) / 100 ).toDouble();
//        double q= ( (double.parse(detail.bags.toString()) * double.parse(detail.kg.toString())) / 100 ).toDouble();
//        totalAmount += total;
//       return [
//         detail.rice.toString(),
//         q.toString(),
//         // detail.kg.toString(),
//         detail.rate.toString(),
//         total.toString()
      
//       ];
//     }).toList();

//    data.add(["", "", "", totalAmount.toString()]);
  
//   return pw.Table.fromTextArray(
//     headers: [
//       'Rice',    // Define nested table headers
//       'Quan',    // Define nested table headers
//       // 'Kg',
//       'Rate',
//       'Total'
//     ],
//     data: data,
    
//     border: pw.TableBorder.all(
//       color: PdfColors.grey,
//       width: 1,
//     ),
//     cellStyle: pw.TextStyle(fontSize: 12),
//     headerStyle: pw.TextStyle(
//       fontWeight: pw.FontWeight.bold,
//       fontSize: 12,
//       color: PdfColors.black,
//     ),
//     headerDecoration: pw.BoxDecoration(
//       color: PdfColors.grey300,
//     ),
//   );
// }
