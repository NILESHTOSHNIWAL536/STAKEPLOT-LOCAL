import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../routes/route_collections.dart';
import '../apiAutomations/curd.dart';


/// 🔥 MAIN FUNCTION (CALL THIS)
Future<void> exportCollectionPdf(
  BuildContext context,
  String collectionId,
) async {
  try {
    /// API CALL
    var response = await getDataApiCall(
      CollectionsRoute.getAllTransactionsCollectionById(collectionId),
    );

    if (!getFlagOfResponse(response)) return;

    final decoded = jsonDecode(response.body);
    final data = decoded['data'];

    final collection = data['collection'];
    final splits = data['splits'] ?? [];

    /// 🔥 CONVERT SPLITS → TRANSACTIONS LIST
    List<Map<String, dynamic>> transactions = [];

    for (var split in splits) {
      for (var item in split['splits']) {
        transactions.add({
          "date": split['createdAt'],
          "name": item['user']?['name'] ?? "User",
          "amount": item['amount'],
          "paidBy": split['paidByUser']?['name'] ?? "",
          "type": split['splitType'],
        });
      }
    }

    await _generatePdf(
      context,
      collection,
      transactions,
    );
  } catch (e) {
    debugPrint("PDF Error: $e");
  }
}

/// ---------------- PDF GENERATOR ----------------
Future<void> _generatePdf(
  BuildContext context,
  Map collection,
  List transactions,
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
pw.Widget _header(Map collection) {
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
              collection['name'] ?? "",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text("Type: ${collection['type']}"),
            pw.Text("Status: ${collection['status']}"),
          ],
        ),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "Total: ₹${collection['totalAmount']}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "Date: ${_formatDate(collection['createdAt'])}",
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
pw.Widget _table(List data) {
  return pw.TableHelper.fromTextArray(
    headers: ["Date", "User", "Paid By", "Type", "Amount"],

    data: data.map((e) {
      return [
        _formatDate(e['date']),
        e['name'],
        e['paidBy'],
        e['type'],
        "₹${e['amount']}",
      ];
    }).toList(),

    headerStyle: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    ),

    headerDecoration:
        const pw.BoxDecoration(color: PdfColors.blueGrey800),

    cellStyle: const pw.TextStyle(fontSize: 10),
    cellHeight: 20,
  );
}

/// ---------------- DATE FORMAT ----------------
String _formatDate(String? date) {
  try {
    return DateFormat('dd MMM yyyy')
        .format(DateTime.parse(date ?? ""));
  } catch (e) {
    return "";
  }
}