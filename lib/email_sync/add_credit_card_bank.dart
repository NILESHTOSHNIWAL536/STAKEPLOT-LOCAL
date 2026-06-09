import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../components/helper.dart';
import '../Constants/booleanFlag.dart';
import '../components/shared_utils.dart';

import '../model/credit-card-bank.dart';
import 'custom_steps.dart';
import 'email_signin.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

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
    cardController.selectedBankName.value = "";
    cardController.selectedBankId.value = "";
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
    cardController.selectedBankName.value = bank.name;
    cardController.selectedBankId.value = bank.id;
    _focusNode.unfocus();
    // Scroll feedback — keep selection visible
    // setState(() {});
  }

  Future<void> _showPendingStatements() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Pending Statements",
          style: FontManager().getTextStyle(context,
              fontSize: 17,
              lWeight: FontWeight.w700,
              color: AppColors.primaryColor),
        ),
        content: Obx(() {
          if (cardController.pendingStatementsLoading.value) {
            return const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (cardController.pendingStatements.isEmpty) {
            return Text(
              "No statements are waiting for a password.",
              style: FontManager().getTextStyle(context,
                  fontSize: 13, color: Colors.grey.shade600),
            );
          }

          return SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: cardController.pendingStatements.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.grey.shade200,
                height: 1,
              ),
              itemBuilder: (_, index) {
                final pending = cardController.pendingStatements[index];
                final title = pending["bankName"]?.toString().isNotEmpty == true
                    ? pending["bankName"].toString()
                    : "Bank statement";
                final subtitle =
                    pending["filename"]?.toString().isNotEmpty == true
                        ? pending["filename"].toString()
                        : pending["accountHint"]?.toString() ?? "";

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_outline_rounded,
                      color: Color(0xFF37344F)),
                  title: Text(
                    title,
                    style: FontManager().getTextStyle(context,
                        fontSize: 14,
                        lWeight: FontWeight.w600,
                        color: const Color(0xFF37344F)),
                  ),
                  subtitle: subtitle.isEmpty
                      ? null
                      : Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontManager().getTextStyle(context,
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _showPendingPasswordDialog(pending);
                  },
                );
              },
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              "Close",
              style: FontManager().getTextStyle(context,
                  fontSize: 14,
                  lWeight: FontWeight.w600,
                  color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showPendingPasswordDialog(Map<String, dynamic> pending) {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    cardController.statementPasswordError.value = "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bankName = pending["bankName"]?.toString().isNotEmpty == true
              ? pending["bankName"].toString()
              : "Bank statement";
          final accountHint = pending["accountHint"]?.toString() ?? "";

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              bankName,
              style: FontManager().getTextStyle(context,
                  fontSize: 17,
                  lWeight: FontWeight.w700,
                  color: AppColors.primaryColor),
            ),
            content: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (accountHint.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        accountHint,
                        style: FontManager().getTextStyle(context,
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: "PDF password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setDialogState(
                            () => obscurePassword = !obscurePassword),
                      ),
                    ),
                  ),
                  if (cardController.statementPasswordError.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        cardController.statementPasswordError.value,
                        style: FontManager().getTextStyle(context,
                            fontSize: 12, color: Colors.red.shade600),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: cardController.statementPasswordSubmitting.value
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text("Cancel"),
              ),
              Obx(
                () => ElevatedButton(
                  onPressed: cardController.statementPasswordSubmitting.value
                      ? null
                      : () async {
                          final ok = await cardController
                              .savePasswordForPendingStatement(
                            context,
                            pending,
                            passwordController.text,
                          );
                          if (ok && mounted) {
                            Navigator.of(dialogContext).pop();
                            snackBarCalled(
                              context,
                              "Statement processed successfully",
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37344F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: cardController.statementPasswordSubmitting.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Process"),
                ),
              ),
            ],
          );
        },
      ),
    );
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
              style: FontManager().getTextStyle(context,
                  fontSize: 14, color: Colors.grey.shade600),
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
            Obx(() => cardController.selectedBankName.value.isNotEmpty
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
                          cardController.selectedBankName.value,
                          style: FontManager().getTextStyle(context,
                              fontSize: 13,
                              lWeight: FontWeight.w600,
                              color: AppColors.primaryColor),
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
                          final isSelected =
                              cardController.selectedBankId.value == bank.id;
                          return Obx(() => _BankTile(
                                bank: bank,
                                isFirst: i == 0,
                                isLast: i == filteredBanks.length - 1,
                                isSelected:
                                    cardController.selectedBankId.value ==
                                        bank.id,
                                onTap: () => _selectBank(bank),
                              ));
                        },
                      ),
                    ),
            ),

            SizedBox(height: AppSizes.h14),

            Obx(
              () => cardController.pendingStatements.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _showPendingStatements,
                        icon: const Icon(Icons.lock_clock_rounded, size: 18),
                        label: Text(
                          "Pending Statements",
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 14,
                            lWeight: FontWeight.w600,
                            color: const Color(0xFF37344F),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF37344F),
                          side: BorderSide(
                            color: const Color(0xFF37344F).withOpacity(0.35),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
            ),

            SizedBox(height: AppSizes.h10),

            // ── CTA ───────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (cardController.selectedBankName.value.isEmpty ||
                      cardController.selectedBankId.value.isEmpty) {
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
                child: Text(
                  "Continue",
                  style: FontManager().getTextStyle(context,
                      fontSize: 16,
                      lWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.4),
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
            style: FontManager().getTextStyle(context,
                fontSize: 15,
                lWeight: FontWeight.w600,
                color: Colors.grey.shade400),
          ),
          const SizedBox(height: 4),
          Text(
            "Try a different search term",
            style: FontManager().getTextStyle(context,
                fontSize: 13, color: Colors.grey.shade400),
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
                  style: FontManager().getTextStyle(context,
                      fontSize: 14,
                      lWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: const Color(0xFF37344F)),
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
