import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../components/helper.dart';
import '../Constants/booleanFlag.dart';
import '../finance_screen/Budgets/Budget.dart';
import '../model/credit-card-bank.dart';
import 'custom_steps.dart';
import 'email_signin.dart';

RxString selectedBankName = "".obs;
RxString selectedBankId = "".obs;
RxList<CreditCardBank> creditCardBankList = <CreditCardBank>[].obs;

class AddCreditCardBankScreen extends StatefulWidget {
  @override
  State<AddCreditCardBankScreen> createState() =>
      _AddCreditCardBankScreenState();
}

class _AddCreditCardBankScreenState extends State<AddCreditCardBankScreen> {
  RxList<CreditCardBank> filteredBanks = <CreditCardBank>[].obs;
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    filteredBanks
      ..clear()
      ..addAll(creditCardBankList);
    selectedBankName.value = "";
    selectedBankId.value = "";
  }

  @override
  void dispose() {
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String v) {
    final query = v.toLowerCase();
    setState(() {
      filteredBanks
        ..clear()
        ..addAll(
          creditCardBankList.where(
            (e) => e.name.toLowerCase().contains(query),
          ),
        );
    });
  }

  void _selectBank(CreditCardBank bank) {
    controller.text = bank.name;
    selectedBankName.value = bank.name;
    selectedBankId.value = bank.id;
    _focusNode.unfocus();
    // Scroll feedback — keep selection visible
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          elevation: 0,
          backgroundColor: AppColors.backgroundColor,
          leading: leadIcon(context),
          title: textStyle(
            context: context,
            text: "Select Your Bank",
            c: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontsize: 18,
          ),
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomStepper(activeStep: 0),
            SizedBox(height: AppSizes.h10),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              "Which bank issued your credit card?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: AppSizes.h12),

            // ── Search field ──────────────────────────────────────────────
            TextField(
              controller: controller,
              focusNode: _focusNode,
              onChanged: _onSearch,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.grey.shade400, size: 20),
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller.clear();
                          _onSearch('');
                        },
                        child: Icon(Icons.clear_rounded,
                            color: Colors.grey.shade400, size: 18),
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: 'Search your bank…',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.primaryColor.withOpacity(0.4),
                      width: 1.5),
                ),
              ),
            ),

            SizedBox(height: AppSizes.h10),

            // ── Selected badge ────────────────────────────────────────────
            Obx(() => selectedBankName.value.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.primaryColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          selectedBankName.value,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),

            // ── Bank list ─────────────────────────────────────────────────
            Expanded(
              child: filteredBanks.isEmpty
                  ? _buildEmptyState()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, __) => Divider(
                          color: Colors.grey.shade200,
                          height: 1,
                          thickness: 1,
                        ),
                        itemCount: filteredBanks.length,
                        itemBuilder: (_, i) {
                          final bank = filteredBanks[i];
                          final isSelected = selectedBankId.value == bank.id;
                          return Obx(() => _BankTile(
                                bank: bank,
                                isFirst: i == 0,
                                isLast: i == filteredBanks.length - 1,
                                isSelected: selectedBankId.value == bank.id,
                                onTap: () => _selectBank(bank),
                              ));
                        },
                      ),
                    ),
            ),

            SizedBox(height: AppSizes.h14),

            // ── CTA ───────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedBankName.value.isEmpty ||
                      selectedBankId.value.isEmpty) {
                    snackBarCalledfail(context, "Please select your bank");
                  } else {
                    googleSignInBool.value = false;
                    pushnameToRoute(context, SignInScreen());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37344F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSizes.h30),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            "No banks found",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Try a different search term",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _BankTile extends StatelessWidget {
  final CreditCardBank bank;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;
  final VoidCallback onTap;

  const _BankTile({
    required this.bank,
    required this.isFirst,
    required this.isLast,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? const Color(0xFF37344F).withOpacity(0.06)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(14) : Radius.zero,
        bottom: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(14) : Radius.zero,
          bottom: isLast ? const Radius.circular(14) : Radius.zero,
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  bank.logo,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder: getErrorBankLogo(),
                ),
              ),
              const SizedBox(width: 14),
              // Name
              Expanded(
                child: Text(
                  bank.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF37344F),
                  ),
                ),
              ),
              // Checkmark
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF37344F), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

void pushnameToRoute(BuildContext context, Widget screen,
    [bool replace = true]) {
  if (replace) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => screen));
  } else {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
