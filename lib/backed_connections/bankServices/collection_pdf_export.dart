import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../model/TransactionModel.dart';
import '../../model/collections_model.dart';


// ─────────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────────
const _kPrimary    = PdfColor.fromInt(0xFF1A237E); // deep indigo
const _kAccent     = PdfColor.fromInt(0xFF3949AB); // lighter indigo
const _kGreenBg    = PdfColor.fromInt(0xFFE8F5E9);
const _kGreen      = PdfColor.fromInt(0xFF2E7D32);
const _kRedBg      = PdfColor.fromInt(0xFFFFEBEE);
const _kRed        = PdfColor.fromInt(0xFFC62828);
const _kAmberBg    = PdfColor.fromInt(0xFFFFF8E1);
const _kAmber      = PdfColor.fromInt(0xFFF57F17);
const _kGrey100    = PdfColor.fromInt(0xFFF5F5F5);
const _kGrey300    = PdfColor.fromInt(0xFFE0E0E0);
const _kGrey600    = PdfColor.fromInt(0xFF757575);
const _kWhite      = PdfColors.white;

final _fmt = NumberFormat('#,##0.00', 'en_IN');

String _rupees(double v) => '₹${_fmt.format(v)}';

String _fmtDate(dynamic d) {
  try {
    if (d == null) return '—';
    final dt = d is DateTime ? d : DateTime.parse(d.toString());
    return DateFormat('dd MMM yyyy').format(dt);
  } catch (_) {
    return '—';
  }
}

String _fmtDateTime(dynamic d) {
  try {
    if (d == null) return '—';
    final dt = d is DateTime ? d : DateTime.parse(d.toString());
    return DateFormat('dd MMM yy  HH:mm').format(dt);
  } catch (_) {
    return '—';
  }
}

// ─────────────────────────────────────────────
// PUBLIC ENTRY POINT
// ─────────────────────────────────────────────
Future<void> exportCollectionPdf(
  BuildContext context,
  CollectionDetailsModel details,
  List<SplitModel> splits,
  List<BalanceModel> balances,
) async {
  try {
    final bytes = await _buildPdf(details, splits, balances);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  } catch (e) {
    debugPrint('exportCollectionPdf error: $e');
  }
}

// ─────────────────────────────────────────────
// PDF BUILDER
// ─────────────────────────────────────────────
Future<Uint8List> _buildPdf(
  CollectionDetailsModel details,
  List<SplitModel> splits,
  List<BalanceModel> balances,
) async {
  final pdf = pw.Document(
    title: details.collection.name,
    author: 'StakePlot',
  );

  final col = details.collection;
  final isShared = col.type.toUpperCase() == 'SHARED';

  // ── Collect all transactions ──
  final List<TransactionModel> allTxns = isShared
      ? splits.expand((s) => s.transactionIds).toList()
      : details.transactions;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      header: (ctx) => _pageHeader(col, ctx),
      footer: (ctx) => _pageFooter(ctx),
      build: (ctx) => [
        // 1. SUMMARY CARDS
        _sectionTitle('Collection Summary'),
        pw.SizedBox(height: 6),
        _summaryCards(col),
        pw.SizedBox(height: 18),

        // 2. MEMBERS
        if (details.members.isNotEmpty) ...[
          _sectionTitle('Members  (${details.members.length})'),
          pw.SizedBox(height: 6),
          _membersTable(details.members),
          pw.SizedBox(height: 18),
        ],

        // 3. TRANSACTIONS
        if (allTxns.isNotEmpty) ...[
          _sectionTitle('Transactions  (${allTxns.length})'),
          pw.SizedBox(height: 6),
          _transactionsTable(allTxns),
          pw.SizedBox(height: 18),
        ],

        // 4. SPLITS (shared only)
        if (isShared && splits.isNotEmpty) ...[
          _sectionTitle('Splits  (${splits.length})'),
          pw.SizedBox(height: 6),
          ...splits.map((s) => _splitCard(s)).toList(),
          pw.SizedBox(height: 18),
        ],

        // 5. BALANCES
        if (balances.isNotEmpty) ...[
          _sectionTitle('Balance Summary'),
          pw.SizedBox(height: 6),
          _balancesTable(balances),
          pw.SizedBox(height: 10),
        ],
      ],
    ),
  );

  return pdf.save();
}

// ─────────────────────────────────────────────
// PAGE HEADER
// ─────────────────────────────────────────────
pw.Widget _pageHeader(CollectionModel col, pw.Context ctx) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 10),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(width: 1.5, color: _kPrimary)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              col.name,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: _kPrimary,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Row(children: [
              _badge(col.type, _kAccent, _kWhite),
              pw.SizedBox(width: 6),
              _badge(
                col.status.toUpperCase(),
                col.status.toLowerCase() == 'active' ? _kGreen : _kGrey600,
                _kWhite,
              ),
            ]),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'StakePlot',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: _kAccent,
              ),
            ),
            pw.Text(
              'Generated: ${_fmtDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: _kGrey600),
            ),
          ],
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// PAGE FOOTER
// ─────────────────────────────────────────────
pw.Widget _pageFooter(pw.Context ctx) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 6),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(width: 0.5, color: _kGrey300)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'StakePlot — Confidential',
          style: const pw.TextStyle(fontSize: 8, color: _kGrey600),
        ),
        pw.Text(
          'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: _kGrey600),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────
pw.Widget _sectionTitle(String title) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    decoration: const pw.BoxDecoration(
      color: _kPrimary,
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: _kWhite,
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// SUMMARY CARDS
// ─────────────────────────────────────────────
pw.Widget _summaryCards(CollectionModel col) {
  return pw.Row(
    children: [
      _statCard('Total Spend',    _rupees(col.totalAmount),      _kGrey100,   _kPrimary),
      pw.SizedBox(width: 8),
      _statCard('Total Credit',   _rupees(col.totalCredit),      _kGreenBg,   _kGreen),
      pw.SizedBox(width: 8),
      _statCard('Total Debit',    _rupees(col.totalDebit),       _kRedBg,     _kRed),
      pw.SizedBox(width: 8),
      _statCard('Outstanding',    _rupees(col.outStandingAmount),_kAmberBg,   _kAmber),
      pw.SizedBox(width: 8),
      _statCard('Expiry',         _fmtDate(col.expiryAt),        _kGrey100,   _kGrey600),
    ].map((w) => pw.Expanded(child: w)).toList(),
  );
}

pw.Widget _statCard(
    String label, String value, PdfColor bg, PdfColor textColor) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
    decoration: pw.BoxDecoration(
      color: bg,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      border: pw.Border.all(color: _kGrey300, width: 0.5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 7.5, color: _kGrey600)),
        pw.SizedBox(height: 3),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: textColor)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// MEMBERS TABLE
// ─────────────────────────────────────────────
pw.Widget _membersTable(List<MemberModel> members) {
  const hdStyle = pw.TextStyle(fontSize: 9);
  final hdDec = pw.BoxDecoration(color: _kAccent);

  return pw.Table(
    border: pw.TableBorder.all(color: _kGrey300, width: 0.5),
    columnWidths: {
      0: const pw.FlexColumnWidth(3),
      1: const pw.FlexColumnWidth(2),
      2: const pw.FlexColumnWidth(2),
      3: const pw.FlexColumnWidth(2),
    },
    children: [
      // header
      pw.TableRow(
        decoration: hdDec,
        children: [
          _cell('Member Name', hdStyle, _kWhite, isHeader: true),
          _cell('Role',        hdStyle, _kWhite, isHeader: true),
          _cell('Limit',       hdStyle, _kWhite, isHeader: true, align: pw.Alignment.centerRight),
          _cell('Spent',       hdStyle, _kWhite, isHeader: true, align: pw.Alignment.centerRight),
        ],
      ),
      // rows
      ...members.asMap().entries.map((entry) {
        final i = entry.key;
        final m = entry.value;
        final bg = i.isEven ? _kGrey100 : _kWhite;
        final spent = double.tryParse(m.amountSpend) ?? 0;
        final limit = double.tryParse(m.setAmount) ?? 0;
        final over = limit > 0 && spent > limit;

        return pw.TableRow(
          decoration: pw.BoxDecoration(color: bg),
          children: [
            _cell(m.name, const pw.TextStyle(fontSize: 9), PdfColors.black),
            _cell(m.role, const pw.TextStyle(fontSize: 9), _kGrey600),
            _cell(_rupees(limit), const pw.TextStyle(fontSize: 9), PdfColors.black,
                align: pw.Alignment.centerRight),
            _cell(
              _rupees(spent),
              pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: over ? _kRed : _kGreen),
              over ? _kRed : _kGreen,
              align: pw.Alignment.centerRight,
            ),
          ],
        );
      }).toList(),
    ],
  );
}

// ─────────────────────────────────────────────
// TRANSACTIONS TABLE
// ─────────────────────────────────────────────
pw.Widget _transactionsTable(List<TransactionModel> txns) {
  const hdStyle = pw.TextStyle(fontSize: 8.5);
  final hdDec = pw.BoxDecoration(color: _kAccent);

  return pw.Table(
    border: pw.TableBorder.all(color: _kGrey300, width: 0.4),
    columnWidths: {
      0: const pw.FixedColumnWidth(70),   // Date & time
      1: const pw.FlexColumnWidth(4),     // Narration / details
      2: const pw.FixedColumnWidth(42),   // Type
      3: const pw.FixedColumnWidth(58),   // Amount
      4: const pw.FixedColumnWidth(60),   // Balance
    },
    children: [
      pw.TableRow(
        decoration: hdDec,
        children: [
          _cell('Date',    hdStyle, _kWhite, isHeader: true),
          _cell('Details', hdStyle, _kWhite, isHeader: true),
          _cell('Type',    hdStyle, _kWhite, isHeader: true),
          _cell('Amount',  hdStyle, _kWhite, isHeader: true, align: pw.Alignment.centerRight),
          _cell('Balance', hdStyle, _kWhite, isHeader: true, align: pw.Alignment.centerRight),
        ],
      ),
      ...txns.asMap().entries.map((entry) {
        final i   = entry.key;
        final txn = entry.value;
        final bg  = i.isEven ? _kGrey100 : _kWhite;
        final isCredit = (txn.type ?? '').toUpperCase().contains('CREDIT');

        return pw.TableRow(
          decoration: pw.BoxDecoration(color: bg),
          children: [
            _cell(
              _fmtDateTime(txn.transactionTimestamp),
              const pw.TextStyle(fontSize: 7.5),
              _kGrey600,
            ),
            _cell(
              txn.narration ?? '—',
              const pw.TextStyle(fontSize: 8),
              PdfColors.black,
            ),
            _cell(
              txn.type ?? '—',
              pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: isCredit ? _kGreen : _kRed),
              isCredit ? _kGreen : _kRed,
            ),
            _cell(
              _rupees(txn.amount ?? 0),
              pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: isCredit ? _kGreen : _kRed),
              isCredit ? _kGreen : _kRed,
              align: pw.Alignment.centerRight,
            ),
            _cell(
              _rupees(txn.currentBalance ?? 0),
              const pw.TextStyle(fontSize: 8),
              PdfColors.black,
              align: pw.Alignment.centerRight,
            ),
          ],
        );
      }).toList(),
    ],
  );
}

// ─────────────────────────────────────────────
// SPLIT CARD
// ─────────────────────────────────────────────
pw.Widget _splitCard(SplitModel split) {
  final totalPaid = split.transactionIds.fold<double>(
      0, (sum, t) => sum + (t.amount ?? 0));
  final paidByName =
      split.paidByUser?.name ?? split.paidBy;

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _kGrey300, width: 0.6),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── card header ──
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const pw.BoxDecoration(
            color: _kGrey100,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(6),
              topRight: pw.Radius.circular(6),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Paid by: $paidByName',
                    style: pw.TextStyle(
                        fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Date: ${_fmtDate(split.createdAt)}   Split: ${split.splitType}',
                    style:
                        const pw.TextStyle(fontSize: 8, color: _kGrey600),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Total Paid',
                      style: const pw.TextStyle(
                          fontSize: 7.5, color: _kGrey600)),
                  pw.Text(
                    _rupees(totalPaid),
                    style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: _kGreen),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── linked transactions ──
        if (split.transactionIds.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Linked Transactions',
                    style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _kAccent)),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.all(
                      color: _kGrey300, width: 0.4),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FixedColumnWidth(70),
                    2: const pw.FixedColumnWidth(60),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: _kGrey300),
                      children: [
                        _cell('Narration',
                            pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold),
                            PdfColors.black,
                            isHeader: true),
                        _cell('Date',
                            pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold),
                            PdfColors.black,
                            isHeader: true),
                        _cell('Amount',
                            pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold),
                            PdfColors.black,
                            isHeader: true,
                            align: pw.Alignment.centerRight),
                      ],
                    ),
                    ...split.transactionIds.map((txn) => pw.TableRow(
                          children: [
                            _cell(txn.narration ?? '—',
                                const pw.TextStyle(fontSize: 8),
                                PdfColors.black),
                            _cell(
                                _fmtDate(txn.transactionTimestamp),
                                const pw.TextStyle(fontSize: 8),
                                _kGrey600),
                            _cell(
                                _rupees(txn.amount ?? 0),
                                pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold),
                                PdfColors.black,
                                align: pw.Alignment.centerRight),
                          ],
                        )),
                  ],
                ),
              ],
            ),
          ),

        // ── member split breakdown ──
        if (split.splits.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(10, 2, 10, 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Split Breakdown',
                    style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: _kAccent)),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.all(
                      color: _kGrey300, width: 0.4),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FixedColumnWidth(80),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: _kGrey300),
                      children: [
                        _cell('User',
                            pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold),
                            PdfColors.black,
                            isHeader: true),
                        _cell('Share %',
                            pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold),
                            PdfColors.black,
                            isHeader: true,
                            align: pw.Alignment.center),
                        _cell('Amount Owed',
                            pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold),
                            PdfColors.black,
                            isHeader: true,
                            align: pw.Alignment.centerRight),
                      ],
                    ),
                    ...split.splits.map((item) {
                      final pct = totalPaid > 0
                          ? '${(item.amount / totalPaid * 100).toStringAsFixed(1)}%'
                          : '—';
                      final isSelf = item.userId == split.paidBy;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                            color: isSelf ? _kGreenBg : _kWhite),
                        children: [
                          _cell(
                            '${item.user?.name ?? item.userId}${isSelf ? '  (paid)' : ''}',
                            pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: isSelf
                                    ? pw.FontWeight.bold
                                    : pw.FontWeight.normal),
                            isSelf ? _kGreen : PdfColors.black,
                          ),
                          _cell(pct, const pw.TextStyle(fontSize: 8),
                              _kGrey600,
                              align: pw.Alignment.center),
                          _cell(
                            _rupees(item.amount),
                            pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: isSelf ? _kGreen : _kRed),
                            isSelf ? _kGreen : _kRed,
                            align: pw.Alignment.centerRight,
                          ),
                        ],
                      );
                    }).toList(),

                    // ── totals row ──
                    pw.TableRow(
                      decoration:
                          pw.BoxDecoration(color: _kAccent),
                      children: [
                        _cell('Total', pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), _kWhite, isHeader: true),
                        _cell('100%',  pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), _kWhite, isHeader: true, align: pw.Alignment.center),
                        _cell(_rupees(totalPaid), pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), _kWhite, isHeader: true, align: pw.Alignment.centerRight),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// BALANCES TABLE
// ─────────────────────────────────────────────
pw.Widget _balancesTable(List<BalanceModel> balances) {
  final toPay     = balances.where((b) => b.type == 'toPay').toList();
  final toReceive = balances.where((b) => b.type == 'toReceive').toList();

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(child: _balanceGroup('You Owe', toPay,     _kRedBg,   _kRed)),
      pw.SizedBox(width: 12),
      pw.Expanded(child: _balanceGroup('Owed to You', toReceive, _kGreenBg, _kGreen)),
    ],
  );
}

pw.Widget _balanceGroup(
  String title,
  List<BalanceModel> items,
  PdfColor bg,
  PdfColor accentColor,
) {
  if (items.isEmpty) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
          color: _kGrey100,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: _kGrey300, width: 0.5)),
      child: pw.Text('$title: All settled ✓',
          style: const pw.TextStyle(fontSize: 9, color: _kGrey600)),
    );
  }

  final total = items.fold<double>(0, (s, b) => s + b.amount);

  return pw.Container(
    decoration: pw.BoxDecoration(
      color: bg,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      border: pw.Border.all(color: accentColor, width: 0.6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // header
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: accentColor,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(6),
              topRight: pw.Radius.circular(6),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _kWhite)),
              pw.Text(_rupees(total),
                  style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _kWhite)),
            ],
          ),
        ),
        // rows
        ...items.map((b) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(width: 0.3, color: _kGrey300)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    b.user?.name ?? '—',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    _rupees(b.amount),
                    style: pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: accentColor),
                  ),
                ],
              ),
            )),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
pw.Widget _cell(
  String text,
  pw.TextStyle style,
  PdfColor color, {
  bool isHeader = false,
  pw.Alignment align = pw.Alignment.centerLeft,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    alignment: align,
    child: pw.Text(
      text,
      style: style.copyWith(color: isHeader ? color : null),
      overflow: pw.TextOverflow.clip,
    ),
  );
}

pw.Widget _badge(String label, PdfColor bg, PdfColor fg) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: pw.BoxDecoration(
      color: bg,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
    ),
    child: pw.Text(label,
        style: pw.TextStyle(
            fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: fg)),
  );
}