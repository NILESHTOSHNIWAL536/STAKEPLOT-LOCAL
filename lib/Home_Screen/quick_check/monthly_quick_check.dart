import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';
import '../../Utils/snackBar.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/helper.dart';
import '../../constants/app_styles.dart';
import '../../controllers/quick_check_controller.dart';
import '../../finvu_screens/shareAccountLogin.dart';
import '../../image_service/avatarProfile.dart';
import '../../model/bank_model.dart';
import '../../model/quick_check_model.dart';
import '../../repository/bankinfo.dart';
import 'package:intl/intl.dart';

class BalanceScreen extends StatefulWidget {
  BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final controller = Get.find<QuickCheckController>();
  final RxnInt expandedBankIndex = RxnInt();
  var isInsightsLoading = true.obs;
  final List<String> months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  var selectedMonth = DateFormat('MMMM').format(DateTime.now()).obs;
  var selectedYear = DateTime.now().year.obs;

  static const Color _addBankBg = Color(0xFFE5F6F5);
  static const Color _addBankText = Color(0xFF2A9D8F);
  static const Color _darkCard = Color(0xFF1C1C3A);
  static const Color _tealAccent = Color(0xFF7ECECE);

  final Map<int, RxnInt> _selectedBarPerBank = {};

  @override
  void initState() {
    super.initState();
    fetchMonthlyInsights(year: DateTime.now().year, monthName: selectedMonth.value);
  }

  Future<void> fetchMonthlyInsights({required int year, String? monthName}) async {
    isInsightsLoading.value = true;
    try {
      final int month =
          monthName != null ? _monthNumberFromName(monthName) : DateTime.now().month;
      await controller.getQuickCheck(
        view: 'monthly',
        month: _monthNumberFromName(selectedMonth.value),
        year: year,
      );
      selectedMonth.value = monthName ?? months[month - 1];
    } finally {
      isInsightsLoading.value = false;
    }
  }

  List<int> get availableYears {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - index);
  }

  int _monthNumberFromName(String name) => months.indexOf(name) + 1;

  String _formatAmount(double amount) =>
      NumberFormat('#,##0').format(amount.round());

  String _formatAmountShort(double amount) {
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: globalbackArrow(),
            ),
            const Expanded(
              child: Text(
                'My Accounts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
            ),
            _downloadButton(context),
          ],
        ),
      ),
    );
  }

  Widget _downloadButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final len = bankAccountLinkedList.length;
        if (len == 0) {
          snackBarCalled(context, SnackbarData().noBankForLinking);
        } else {
          accountIdPdf.value = bankAccountLinkedList[0].accountId;
          showModalForPdfDownloadBankUiCheckBox(context);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: _tealAccent,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.download, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Combined Balance Card ─────────────────────────────────────────────────
  Widget _buildCombinedBalanceCard(BuildContext context) {
    return Obx(() {
      final balance = controller.quickCheck.value?.currentBalance ?? 0;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: _darkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -24,
              child: Text(
                '₹',
                style: TextStyle(
                  fontSize: 100,
                  color: Colors.white.withOpacity(0.06),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Combined Balance',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatAmount(balance),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ── Year Selector ─────────────────────────────────────────────────────────
  Widget _buildYearSelector(BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedYear.value,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              isDense: true,
              items: availableYears.map((y) {
                return DropdownMenuItem(
                  value: y,
                  child: Text(
                    y.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null || value == selectedYear.value) return;
                selectedYear.value = value;
                controller.getQuickCheck(view: 'yearly', year: value);
              },
            ),
          ),
        ));
  }

  // ── Account List (accordion) ───────────────────────────────────────────────
  Widget _buildAccountsList(BuildContext context) {
    return Obx(() {
      final banks = controller.quickCheck.value?.banks ?? [];
      return Column(
        children: banks.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildAccountRow(context, entry.value, entry.key),
          );
        }).toList(),
      );
    });
  }

  Widget _buildAccountRow(BuildContext context, QuickCheckBankData bank, int index) {
    final linked = bankAccountLinkedList.firstWhereOrNull(
      (a) => a.bankName.toLowerCase() == bank.bankName.toLowerCase(),
    );
    final logoUrl = linked?.bankLogo ?? '';
    final maskedAcc = linked?.maskedAccNumber ?? '';

    _selectedBarPerBank.putIfAbsent(index, () => RxnInt());
    final selectedBar = _selectedBarPerBank[index]!;

    return Obx(() {
      final isExpanded = expandedBankIndex.value == index;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:  Colors.grey.shade200,
            width: isExpanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Row header ──
            GestureDetector(
              onTap: () {
                expandedBankIndex.value = isExpanded ? null : index;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Real bank logo with fallback
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: logoUrl.isNotEmpty
                          ? Image.network(
                              logoUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.account_balance,
                                color: Color(0xFFE53935),
                                size: 22,
                              ),
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: _tealAccent,
                                            ),
                                          ),
                                        ),
                            )
                          : const Icon(
                              Icons.account_balance,
                              color: Color(0xFFE53935),
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bank.bankName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          if (maskedAcc.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              maskedAcc,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      _formatAmount(bank.currentBalance ?? 0),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Inline chart (shown when expanded) ──
            if (isExpanded) ...[
              Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
                child: _buildInlineBankChart(context, bank, linked: linked, selectedBar: selectedBar),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ── Per-bank inline chart ─────────────────────────────────────────────────
  Widget _buildInlineBankChart(
    BuildContext context,
    QuickCheckBankData bank, {
    required BankAccountModel? linked,
    required RxnInt selectedBar,
  }) {
    final List<Map<String, dynamic>> monthData =
        (bank.months ?? []).map<Map<String, dynamic>>((m) => {
              'month': m['month'] as int,
              'credit': (m['credit'] ?? 0).toDouble(),
              'debit': (m['debit'] ?? 0).toDouble(),
              'outstanding': (m['outstanding'] ?? 0).toDouble(),
            }).toList();

    if (monthData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ),
      );
    }

    final double maxVal = monthData.fold(0.0, (prev, m) {
      final total = (m['credit'] as double) +
          (m['debit'] as double) +
          (m['outstanding'] as double);
      return total > prev ? total : prev;
    });

    return Obx(() {
      final selectedIdx = selectedBar.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthData.asMap().entries.map((entry) {
                  final i = entry.key;
                  final m = entry.value;
                  final isSelected = selectedIdx == i;
                  final isAnySelected = selectedIdx != null;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      selectedBar.value = isSelected ? null : i;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: !isAnySelected || isSelected ? 1.0 : 0.3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildBar(
                              credited: m['credit'] as double,
                              debited: m['debit'] as double,
                              outstanding: m['outstanding'] as double,
                              maxTotal: maxVal,
                              isHighlighted: isSelected,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat.MMM()
                                  .format(DateTime(0, m['month'] as int)),
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected ? _darkCard : Colors.black54,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legendItem(
                symbol: '●',
                label: 'Credited',
                amount: selectedIdx != null
                    ? monthData[selectedIdx]['credit'] as double
                    : bank.credit,
                percent: bank.creditPercent.toDouble(),
                dotColor: _darkCard,
              ),
              _legendItem(
                symbol: '+',
                label: 'Debited',
                amount: selectedIdx != null
                    ? monthData[selectedIdx]['debit'] as double
                    : bank.debit,
                percent: bank.debitPercent.toDouble(),
                dotColor: _tealAccent,
              ),
              _legendItem(
                symbol: '●',
                label: 'Outstanding',
                amount: selectedIdx != null
                    ? monthData[selectedIdx]['outstanding'] as double
                    : bank.outstanding,
                percent: bank.outstandingPercent.toDouble(),
                dotColor: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Set As Primary — scoped to this account
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: linked == null
                  ? null
                  : () {
                      // Implement primary account setting logic here
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkCard,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Set As Primary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // ── Stacked bar ───────────────────────────────────────────────────────────
  Widget _buildBar({
    required double credited,
    required double debited,
    required double outstanding,
    required double maxTotal,
    bool isHighlighted = false,
  }) {
    final double barWidth = isHighlighted ? 32 : 28;
    const double maxBarHeight = 120;
    final double total = credited + debited + outstanding;

    if (total == 0 || maxTotal == 0) {
      return Container(
        height: 4,
        width: barWidth,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final double barHeight = maxBarHeight * (total / maxTotal);
    final double creditH = barHeight * (credited / total);
    final double debitH = barHeight * (debited / total);
    final double outstandingH = barHeight * (outstanding / total);

    return Container(
      decoration: isHighlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: _darkCard.withOpacity(0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: barHeight,
          width: barWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (outstanding > 0)
                Container(height: outstandingH, color: Colors.grey.shade300),
              if (debited > 0)
                Container(height: debitH, color: _tealAccent),
              if (credited > 0)
                Container(height: creditH, color: _darkCard),
            ],
          ),
        ),
      ),
    );
  }

  // ── Legend item ───────────────────────────────────────────────────────────
  Widget _legendItem({
    required String symbol,
    required String label,
    required double amount,
    required double percent,
    required Color dotColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              symbol,
              style: TextStyle(
                  color: dotColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              _formatAmountShort(amount),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,

                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                    fontSize: 9, color: Colors.green.shade700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Add Bank Account footer ───────────────────────────────────────────────
  Widget _buildAddAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ShareAccountLogin()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: const BoxDecoration(
          color: _addBankBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: _addBankText, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Bank Account',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _addBankText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCombinedBalanceCard(context),
                        const SizedBox(height: 12),
                        _buildYearSelector(context),
                        const SizedBox(height: 12),
                        _buildAccountsList(context),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  _buildAddAccountButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
