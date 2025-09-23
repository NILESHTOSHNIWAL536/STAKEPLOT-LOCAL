import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/pdfStrings.dart';
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
import 'package:http/http.dart' as http;

RxInt startIndex = 0.obs;

void getPdf(BuildContext context, RxString selectedValue,
    RxString selectedValueType) async {
  var response = await getDataApiCall(
    "${url}/transactionauto/get-previous-transactions/${getPreviousDate(int.parse(selectedValue.value), selectedValueType.value)}/${accountIdPdf.value}",
  );
  startIndex.value = 0;
  bankLogo.value = getBankLogo();

  if (getFlagOfResponse(response)) {
    var obj = jsonDecode(response.body);
    List list = obj['data']['transactions'];
    if (list.length > 0) {
      generatePdf(
          PdfPageFormat.legal,
          "StakePlot",
          list,
          context,
          obj['data']['profile'][0],
          obj['data']['summary'][0],
          obj['data']['bankAddress'],
          obj['data']['bankName'],
          obj['data']['account']['maskedAccNumber']);
    }
  }
}

Future<pw.MemoryImage> loadLogoNetwork(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return pw.MemoryImage(response.bodyBytes);
  } else {
    throw Exception('Failed to load image from $url');
  }
}

Future<pw.MemoryImage> loadLogo(path) async {
  final ByteData bytes = await rootBundle.load(path); // Correct path
  final Uint8List byteList = bytes.buffer.asUint8List();
  return pw.MemoryImage(byteList);
}

Future<void> generatePdf(
    PdfPageFormat format,
    String title,
    List data,
    contextBui,
    profile,
    summary,
    String address,
    String BankName,
    String accountNo) async {
  final pdf = pw.Document();
  final logo = await loadLogo('assets/app_icon.png'); // Load the logo
  final logo2 = await loadLogoNetwork(bankLogo.value); // Load the logo
  try {
    pdf.addPage(
      pw.MultiPage(
        pageFormat:
            PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        orientation: pw.PageOrientation.portrait,
        header: (context) =>
            firstPage(logo2, profile, summary, address, BankName, accountNo),
        footer: (context) => tableFootercell(logo, context),
        build: (context) {
          return [
            buildPDFTable(data, contextBui, startIndex.value, true),
          ];
        },
      ),
    );

    while (startIndex.value < data.length) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat:
              PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
          orientation: pw.PageOrientation.portrait,
          header: (context) =>
              tableHeaderCell1(logo2, profile, summary, address, BankName),
          footer: (context) => tableFootercell(logo, context),
          build: (context) {
            return [
              buildPDFTable(data, contextBui, startIndex.value, false),
            ];
          },
        ),
      );
    }
  } catch (e) {}

  getPdgLoader.value = false;
  final Uint8List pdfBytes = await pdf.save(); // Save once

  // pdfBytes.addAll(pdfBytes);
  Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);

  //  pdf.save();
}

pw.Widget tableFootercell(pw.MemoryImage logo, context) {
  return pw.Container(
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(
            color: PdfColors.black, width: 1), // Bottom border for header
      ),
    ),
    child: pw.Row(
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

printDoc(data, context, title) {
  return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        Header(),
        pw.SizedBox(
          height: 10,
        ),
      ]);
}

pw.Widget buildPDFTable(data, context, start, bool flag) {
  final pdfContainers = <pw.Widget>[];
  int no = flag
      ? PdfStrings().firstPage
      : selectedValue.value == "6"
          ? PdfStrings().secoundPage
          : PdfStrings().thirdPage;

  for (var i = start; i < data.length; i += no) {
    List chunk = data.sublist(i, (i + no > data.length) ? data.length : i + no);
    startIndex.value += chunk.length;
    pdfContainers.add(
      pw.Container(
        width: double.infinity, // Replace MediaQuery
        margin: pw.EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child:
            tableContent(chunk), // Ensure tableContent handles chunk properly
      ),
    );

    if (flag || pdfContainers.length == 18) break;
  }

  return pw.Column(
    children: pdfContainers,
  );
}

pw.Widget Header() {
  return pw.Column(children: [
    TextStyleD("StakePlot", Colors.red, 15.0),
    pw.SizedBox(
      height: 5,
    ),
  ]);
}

pw.Widget TextStyleD(text, Color color, size) {
  return pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: size + 4,
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
            tableMultilineCell(getDetails(
                item['narration'].toString(), item['type'], item['txnId'])),
            tableCell(item['type'].toString()),
            tableCell(item['amount'].toString()),
            tableCell(
                (item['currentBalance'] ?? item['transactionalBalance'] ?? 0)
                    .toString()),
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
        fontSize: selectedValue.value == "6" ? 10 : 14,
        color: PdfColors.white,
      ),
    ),
  );
}

pw.Widget tableHeaderCell1(logo, profile, s, address, BankName) {
  return pw.Container(
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(
            color: PdfColors.black, width: 1), // Bottom border for header
      ),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Image(logo, width: 30, height: 30),
        pw.SizedBox(width: 10),
        pw.Text(
          BankName,
          // "Transaction Statement for ${profile['holder']['name']}",
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        // Logo on the left
      ],
    ),
  );
}

pw.Widget firstPage(
  logo,
  Map<String, dynamic> profile,
  Map<String, dynamic> summary,
  String address,
  String bankName,
  String accountNo,
) {
  return pw.Container(
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.black, width: 1),
      ),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Bank logo and name row
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Image(logo, width: 40, height: 40),
            pw.SizedBox(width: 10),
            pw.Text(
              bankName,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),

        pw.SizedBox(height: 12),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Account No: $accountNo"),
            pw.Text("Branch: ${summary['data']['branch']}"),
            pw.Text(
                "IFSC: ${summary['data']['ifscCode'] ?? summary['data']['ifsc']}"),
            pw.Text(
                "Opening Date: ${summary['data']['openingDate'].toString().split('T')[0]}"),
          ],
        ),

        pw.SizedBox(height: 12),

        // Account Info Row
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text("Name: ${profile['holder']['name']}"),
                if (profile['holder']['address'] is String &&
                    profile['holder']['address'].toString().trim().isNotEmpty)
                  pw.Container(
                    width: PdfPageFormat.a4.availableWidth / 2,
                    child: pw.Text("Address: ${profile['holder']['address']}"),
                  ),
                pw.SizedBox(height: 12),
                if (profile['holder']['email'] is String &&
                    profile['holder']['email'].toString().trim().isNotEmpty)
                  pw.Text("Email: ${profile['holder']['email']}"),
                pw.Text("DOB: ${profile['holder']['dob']}"),
              ],
            ),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    // alignment: pw.Alignment.topRight,
                    child: pw.Text(
                      "Bank Address : ",
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Container(
                    width: 200,
                    // alignment: pw.Alignment.topRight,
                    child: pw.Text(
                      address,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ]),
          ],
        ),
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
      style: pw.TextStyle(fontSize: selectedValue.value == "6" ? 8 : 12),
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
            style: pw.TextStyle(fontSize: selectedValue.value == "6" ? 8 : 12),
          ));
    }).toList(),
  );
}

String formatTimestamp(String timestamp) {
  try {
    DateTime dateTime = DateTime.parse(timestamp); // Parse string to DateTime
    return DateFormat('dd-MM-yyyy')
        .format(dateTime); // Format as "YYYY-MM-DD h:mm a"
    // return DateFormat('yyyy-MM-dd h:mm a').format(dateTime); // Format as "YYYY-MM-DD h:mm a"
  } catch (e) {
    return timestamp; // Fallback value if parsing fails
  }
}

List<String> getDetails(transaction, type, id) {
  try {
    List<String> parts = transaction.split('/');
    if (parts.isEmpty) parts = transaction.split('-');
    if (parts.isEmpty) parts = transaction.split('&');
    if (parts.isEmpty) parts = transaction.split(' ');

    List<String> list = [];
    String bankCode = parts.length > 3 ? parts[3] : "";
    String paidto = type == "DEBIT"
        ? "Paid to " + "$bankCode"
        : "Received from " + "$bankCode";

    if (bankCode != "") list.add(paidto);
    list.add(id);

    return list;
    // return "Type: $txnType\nID: $txnId\nName: $name\nBank: $bankCode\nAccount: $accountNumber\nDesc: $description";
  } catch (e) {
    return [];
  }
}
