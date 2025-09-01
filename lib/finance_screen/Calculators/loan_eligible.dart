import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class LoanEligibilityScreen extends StatefulWidget {
  const LoanEligibilityScreen({super.key});

  @override
  State<LoanEligibilityScreen> createState() => _LoanEligibilityScreenState();
}

class _LoanEligibilityScreenState extends State<LoanEligibilityScreen> {
  final TextEditingController incomeController = TextEditingController(text: "₹ 3000.00");
  final TextEditingController existingEmiController = TextEditingController();
  String selectedCreditScore = "650-700";
  String selectedLoanType = "Personal";

  @override
  Widget build(BuildContext context) {
    return  Container(
        width: MediaQuery.sizeOf(context).width * 0.85,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x3AFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income
            Text("Income", style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 14, color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: incomeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(height: 12),

            // Existing EMI
            Text("Existing EMI", style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 14, color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: existingEmiController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(height: 12),

            // Credit Score Dropdown
            Text("Credit score", style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 14, color: Colors.white)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCreditScore,
              dropdownColor: AppColors.primaryColor,
              items: ["<650", "650-700", "700-750", "750+"]
                  .map((score) => DropdownMenuItem(
                        value: score,
                        child: Text(score,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCreditScore = value!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const SizedBox(height: 12),

            // Loan Type
            Text("Loan type", style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal, fontSize: 14, color: Colors.white)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Personal", "Car", "Home"].map((type) {
                return ChoiceChip(
                  label: Text(type,
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.normal,
                          fontSize: 14,
                          color: selectedLoanType == type
                              ? AppColors.primaryColor
                              : Colors.white)),
                  selected: selectedLoanType == type,
                  selectedColor: Colors.white,
                  onSelected: (_) {
                    setState(() {
                      selectedLoanType = type;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Calculate Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add your calculation logic here
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  "Calculate",
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Suggested Timeline
            _infoBox(context, "3 years  →  EMI = ₹ 3433/month"),
            const SizedBox(height: 8),
            _infoBox(context, "5 years  →  EMI = ₹ 11244/month"),
            const SizedBox(height: 16),

            // Safe EMI Range & Max Loan Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _smallInfoBox(context, "Safe EMI Range\n₹ 3433 - ₹ 11244"),
                _smallInfoBox(context, "Max Loan Amount\n₹ 4.43 Lakh"),
              ],
            ),
            const SizedBox(height: 16),

            // Expected EMI & Interest Bracket
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _smallInfoBox(context, "Expected EMI\n₹ 11244/month"),
                _smallInfoBox(context, "Interest Bracket\n16% - 20%"),
              ],
            ),
            const SizedBox(height: 20),

            // Suggestions
            _bulletText(context,
                "If you clear your current EMIs of ₹20000, you'll qualify for more loan eligibility."),
            _bulletText(context,
                "Improving your credit score by 50 points can lower your interest by ~2%."),
            _bulletText(context,
                "If you save ₹58488 more each month for 6 months, you will be EMI-ready for ~₹350928 extra loan without stress."),
          ],
        ),
      
    );
  }

  Widget _infoBox(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white24,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: 14,
              color: Colors.white)),
    );
  }

  Widget _smallInfoBox(BuildContext context, String text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white24,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.white)),
      ),
    );
  }

  Widget _bulletText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.white, fontSize: 18)),
          Expanded(
            child: Text(text,
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
