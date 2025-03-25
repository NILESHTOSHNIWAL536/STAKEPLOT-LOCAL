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


RxInt startIndex=0.obs;

 void getPdf(BuildContext context,RxString selectedValue,RxString selectedValueType) async
  {
          var response=await getDataApiCall("${url}/transactionauto/get-previous-transactions/${getPreviousDate(int.parse(selectedValue.value), selectedValueType.value)}");                            
        
          if(getFlagOfResponse(response))
          {
              var obj=jsonDecode(response.body);
              List list=obj['data'];
              print(list);
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
    
     while(startIndex.value<data.length)
     {
            print(startIndex.value);
            pdf.addPage(
                  pw.MultiPage(
                    pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
                    orientation: pw.PageOrientation.portrait,
                    header: (context) =>tableHeaderCell1(logo),
                    footer: (context) => tableFootercell(logo,context),
                    build: (context) {
                      return[   
                            buildPDFTable(data,contextBui,startIndex.value),
                      ];
                    },
                  ),
            );
            
       }
      }catch(e){
          print("error"+e.toString());
      }

    getPdgLoader.value=false;
    final Uint8List pdfBytes = await pdf.save(); // Save once

      // pdfBytes.addAll(pdfBytes);
      Printing.layoutPdf(onLayout: (PdfPageFormat format) async=> pdfBytes );  

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

pw.Widget buildPDFTable(data,context,start) {
  final pdfContainers = <pw.Widget>[];
  int no=   selectedValue.value=="6"? 22 : 15;
  for (var i = start; i < data.length; i += no)
  {
            List chunk = data.sublist(i, (i + no > data.length) ? data.length : i + no);
            startIndex.value += chunk.length;
            pdfContainers.add(
              pw.Container(
                width: double.infinity, // Replace MediaQuery
                margin: pw.EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: tableContent(chunk), // Ensure tableContent handles chunk properly
              ),
            );
            if(pdfContainers.length==18)break;
 }

  return pw.Column(
    children: pdfContainers,
  );
}


  pw.Widget Header() {
       
       return  pw.Column(
        children:[
            TextStyleD("StakePlot",Colors.red,15.0),
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
        fontSize: selectedValue.value=="6"? 10 : 14,
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
      style: pw.TextStyle(fontSize: selectedValue.value=="6"? 8:12),
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
      style: pw.TextStyle(fontSize:  selectedValue.value=="6"? 8:12),));
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
      List<String> parts = transaction.split('/');
       print(parts);
      // String txnType = ""+parts[0]; // UPI-DR or UPI-CR
      // String txnId = ""+parts[1];
      // String name = ""+parts[2];
      String bankCode = ""+parts[3];
      String paidto=type=="DEBIT"? "Paid to "+"$bankCode":"Received from "+"$bankCode";
      // String accountNumber = (parts.length > 5 ? parts[4] : "");
      // String description = (parts.length > 6 ? parts[5] : "");
      List<String> list=[];

      list.add(paidto);
      list.add(id);

      print(list);

    return list;
    // return "Type: $txnType\nID: $txnId\nName: $name\nBank: $bankCode\nAccount: $accountNumber\nDesc: $description";
    } catch (e) {
       return [];
    }



}