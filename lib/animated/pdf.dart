import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


 Future<void> generatePdf(PdfPageFormat format, String title,List data,contextBui) async {
    final pdf = pw.Document();

    // final font = await PdfGoogleFonts.nunitoExtraLight();
try{
    pdf.addPage(
      pw.MultiPage(
        // pageFormat: PdfPageFormat.a,
        // orientation: ,

        build: (context) {
          return[   
                printDoc(data,contextBui,title),
                buildPDFTable(data,contextBui),
          ];
        },
      ),
    );
}catch(e){
    print("error"+e.toString());
}
  
     Printing.layoutPdf(onLayout: (PdfPageFormat format) async=> pdf.save() );  

//     final Uint8List pdfBytes = await pdf.save();

//     Navigator.push(
//   contextBui,
//   MaterialPageRoute(
//     builder: (context) => Scaffold(
//       appBar: AppBar(title: Text("Preview PDF")),
//       body: PdfPreview(
//         build: (format) => pdf.save(),
//       ),
//     ),
//   ),
// );

     
      // pdf.save();
  }



 printDoc(data,context,title){
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
            Header(),
            pw.SizedBox(height: 10,),
            // TextStyleD(title,Colors.red,15.0),
            pw.SizedBox(height: 10,),
          // pw.Container(
          //     // margin: pw.EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //      child: buildPDFTable(data)
          //  ),
    ]);
 }

pw.Widget buildPDFTable(data,context) {
  final pdfContainers = <pw.Widget>[];
  // Divide the data into chunks of 7
  int no=20;
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
  print(transactions);
  return pw.Table.fromTextArray(
    
    headers: [
      'Date',
      'Transaction Details',
      'Type',
      'Amount',
    ],
    data: transactions.map<List<dynamic>>(( item) {
      return [         
        formatTimestamp(item['transactionTimestamp']),                
        item['txnId'].toString(),       
        item['type'].toString(),       
        item['amount'].toString(),     

        // item['category'].toString()+"(${item['subcategory']??""})",       
        // item['type']=="DEBIT"?"" :item['amount'].toString(),       
        // item['type']!="DEBIT"?"" : item['amount'].toString(),       
      ];
    }).toList(), 
    
    border: pw.TableBorder.all(
      color: PdfColors.black,
      width: 1,
    ),
    cellStyle: pw.TextStyle(
      fontSize: 13
    ),
    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 12,
      color: PdfColors.black,
    ),
    headerDecoration: pw.BoxDecoration(
      color: PdfColors.greenAccent,
    ),
    
    columnWidths: {

    },
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
