import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/model/collections_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../routes/route_collections.dart';
import '../apiAutomations/curd.dart';
import 'pdf.dart';

/// 🔥 MAIN FUNCTION (CALL THIS)
Future<void> exportCollectionPdf(
  BuildContext context,
  String collectionId,
) async {
  try {
    /// API CALL
    // var response = await getDataApiCall(
    //   CollectionsRoute.getAllTransactionsCollectionById(collectionId),
    // );

    // if (!getFlagOfResponse(response)) return;

    // final decoded = jsonDecode(response.body);
    // final data = decoded['data'];

    // final collection = data['collection'];
    // final splits = data['splits'] ?? [];

    // /// 🔥 CONVERT SPLITS → TRANSACTIONS LIST
    List<TransactionModel> transactions = [];

    CollectionDetailsModel? collections =
        collectionsController.collectionDetails.value;

    if (collections == null) return;

    if (collections.collection.type == "PERSONAL") {
      transactions.addAll(collections.transactions);
    } else {
      collectionsController.splitsList
          .forEach((split) => transactions.addAll(split.transactionIds));
    }

    await _generatePdf(
      context,
      collections.collection,
      transactions,
    );
  } catch (e) {
    debugPrint("PDF Error: $e");
  }
}

/// ---------------- PDF GENERATOR ----------------
Future<void> _generatePdf(
  BuildContext context,
  CollectionModel collection,
  List<TransactionModel> transactions,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),

      /// 🔥 HEADER
      header: (ctx) => _header(collection),

      /// 🔥 FOOTER
      footer: (ctx) => _footer(ctx),

      build: (ctx) => [
        pw.SizedBox(height: 10),
        pw.Text(
          "Collection Transactions",
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        _table(transactions),
      ],
    ),
  );

  Uint8List bytes = await pdf.save();

  await Printing.layoutPdf(onLayout: (_) async => bytes);
}

/// ---------------- HEADER ----------------
pw.Widget _header(CollectionModel collection) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              collection.name ?? "",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text("Type: ${collection.type}"),
            pw.Text("Status: ${collection.status}"),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "Total: ₹${collection.totalAmount}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "Date: ${_formatDate(collection.expiryAt?.toIso8601String())}",
            ),
          ],
        ),
      ],
    ),
  );
}

/// ---------------- FOOTER ----------------
pw.Widget _footer(pw.Context ctx) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 10),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(width: 0.5)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          "Page ${ctx.pageNumber} / ${ctx.pagesCount}",
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          "StakePlot",
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

/// ---------------- TABLE ----------------
///
// pw.Widget _table(List<TransactionModel> data) {
//   return pw.TableHelper.fromTextArray(
//     headers: ["Date", "User", "Paid By", "Type", "Amount"],
//     data: data.map((e) {
//       return [
//         // _formatDate(e.createdAt),
//         e.narration,
//         // e.paidBy,
//         e.type,
//         "₹${e.amount}",
//       ];
//     }).toList(),
//     headerStyle: pw.TextStyle(
//       fontWeight: pw.FontWeight.bold,
//       color: PdfColors.white,
//     ),
//     headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
//     cellStyle: const pw.TextStyle(fontSize: 10),
//     cellHeight: 20,
//   );
pw.Widget _table(List<TransactionModel> data) {
  final headers = ["Date", "Details", "Type", "Amount", "Balance"];

  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: data.map((e) {
      return [
        formatTimestamp(e.transactionTimestamp.toString()),
        getDetails(e.narration, e.type, e.txnId ?? "").join("\n"),
        e.type.toString(),
        e.amount.toString(),
        (e.currentBalance ?? 0).toString(),
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

/// ---------------- DATE FORMAT ----------------
String _formatDate(String? date) {
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(date ?? ""));
  } catch (e) {
    return "";
  }
}
