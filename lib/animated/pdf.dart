import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:convert';
import 'package:printing/printing.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';

import '../routes/route_transactions.dart';

RxInt startIndex = 0.obs;

void getPdf3(BuildContext context, RxString selectedValue, RxString selectedValueType) async {
  var response = await getDataApiCall(
     BankTransactionRoutes.getPreviousTransactions(accountId: accountIdPdf.value,date:getPreviousDate(int.parse(selectedValue.value), selectedValueType.value) ),
  );

  startIndex.value = 0;
  bankLogo.value = getBankLogo();

  if (getFlagOfResponse(response)) {
    var obj = jsonDecode(response.body);
    List list = obj['data']['transactions'];
    if (list.isNotEmpty) {
      generatePdf(
        PdfPageFormat.a4,
        "StakePlot",
        list,
        context,
        obj['data']['profile'][0],
        obj['data']['summary'][0],
        obj['data']['bankAddress'],
        obj['data']['bankName'],
        obj['data']['account']['maskedAccNumber'],
      );
    }
  }
}

/// ✅ Load local logo
Future<pw.MemoryImage> loadLogo(String path) async {
  final ByteData bytes = await rootBundle.load(path);
  return pw.MemoryImage(bytes.buffer.asUint8List());
}

/// ✅ Load network logo
Future<pw.MemoryImage> loadLogoNetwork(String url) async {
  final response = await getDataApiCall(url)  ;
  if (getFlagOfResponse(response)) {
    return pw.MemoryImage(response.bodyBytes);
  } else {
    throw Exception('Failed to load image from $url');
  }
}

/// ✅ Generate PDF
Future<void> generatePdf(
  PdfPageFormat format,
  String title,
  List data,
  BuildContext context,
  Map<String, dynamic> profile,
  Map<String, dynamic> summary,
  String address,
  String bankName,
  String accountNo,
) async {
  final pdf = pw.Document();
  final logo = await loadLogo('assets/app_icon.png');
  final logo2 = await loadLogoNetwork(bankLogo.value);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      header: (ctx) => pdfHeader(
        ctx,
        logo2,
        bankName,
        profile,
        summary,
        address,
        accountNo,
      ),
      footer: (ctx) => pdfFooter(logo, ctx),
      build: (ctx) => [
        pw.SizedBox(height: 10),
        pw.Text(
          "Transaction Statement",
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(color: PdfColors.grey700, thickness: 0.5),
        buildTransactionTable(data),
      ],
    ),
  );

  final Uint8List bytes = await pdf.save();
  await Printing.layoutPdf(onLayout: (format) async => bytes);
}

/// ✅ Header
pw.Widget pdfHeader(
  pw.Context ctx,
  pw.MemoryImage logo,
  String bankName,
  Map<String, dynamic> profile,
  Map<String, dynamic> summary,
  String address,
  String accountNo,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8, top: 6), // top spacing added
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey700, width: 0.5)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        /// ✅ Left side (Bank info)
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,

          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2), // small gap from top
              child: pw.Image(logo, width: 35, height: 35),
            ),
            pw.SizedBox(width: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  bankName,
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text("Account No: $accountNo", style: const pw.TextStyle(fontSize: 10)),
                pw.Text("IFSC: ${summary['data']['ifscCode'] ?? summary['data']['ifsc'] ??'-'}",
                    style: const pw.TextStyle(fontSize: 10)),

                // ✅ Bank address only on first page
                if (ctx.pageNumber == 1)
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 8, top: 6), 
                  width: 200,
                  child: pw.Text(address, style: const pw.TextStyle(fontSize: 10,),textAlign: pw.TextAlign.left,),
                )
              ],
            ),
          ],
        ),

        /// ✅ Right side (User info)
        pw.Container(
          width: 200,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                profile['holder']['name'] ?? "",
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold,),
              ),

              if (profile['holder']['email'] != null)
              pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 6, top: 6), 
                 child: pw.Text(profile['holder']['email'], style: const pw.TextStyle(fontSize: 10),textAlign: pw.TextAlign.right,),
              ),
              // ✅ Address only on first page
              if (ctx.pageNumber == 1 &&
                  profile['holder']['address'] != null &&
                  profile['holder']['address'] is String)
                   pw.Text(profile['holder']['address'], style: const pw.TextStyle(fontSize: 10),textAlign: pw.TextAlign.right,),
            ],
          ),
        ),
      ],
    ),
  );
}

/// ✅ Footer
pw.Widget pdfFooter(pw.MemoryImage logo, pw.Context ctx) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 10),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: PdfColors.grey700, width: 0.5)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text("Page ${ctx.pageNumber} of ${ctx.pagesCount}",
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Row(
          children: [
            pw.Image(logo, width: 20, height: 20),
            pw.SizedBox(width: 5),
            pw.Text(
              "StakePlot",
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// ✅ Modern Transaction Table
pw.Widget buildTransactionTable(List data) {
  final headers = ["Date", "Details", "Type", "Amount", "Balance"];

  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: data.map((e) {
      return [
        formatTimestamp(e['transactionTimestamp']),
        getDetails(e['narration'].toString(), e['type'], e['txnId']).join("\n"),
        e['type'].toString(),
        e['amount'].toString(),
        (e['currentBalance'] ?? e['transactionalBalance'] ?? 0).toString(),
      ];
    }).toList(),
    cellAlignment: pw.Alignment.centerLeft,
    headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
    headerStyle: pw.TextStyle(
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
    ),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellHeight: 18,
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(width: 0.2, color: PdfColors.grey500),
      verticalInside: pw.BorderSide(width: 0.2, color: PdfColors.grey500),
      top: pw.BorderSide(width: 0.5, color: PdfColors.grey700),
      bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey700),
    ),
    oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
  );
}

/// ✅ Date formatting helper
String formatTimestamp(String timestamp) {
  try {
    DateTime dt = DateTime.parse(timestamp);
    return DateFormat('dd-MM-yyyy').format(dt);
  } catch (_) {
    return timestamp;
  }
}

/// ✅ Transaction detail parser
List<String> getDetails(String transaction, String type, String id) {
  try {
    final parts = transaction.split(RegExp(r'[/\\\-& ]+'));
    final bankCode = parts.length > 3 ? parts[3] : "";
    final paidTo = type == "DEBIT" ? "Paid to $bankCode" : "Received from $bankCode";
    return [if (bankCode.isNotEmpty) paidTo, "Txn ID: $id"];
  } catch (e) {
    return ["Txn ID: $id"];
  }
}
