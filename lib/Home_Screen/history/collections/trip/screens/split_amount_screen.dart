// // // ─── screens/split_amount_screen.dart ────────────────────────────────────────
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import '../../../../../model/collections_model.dart';
// // import '../models/models.dart';
// // import '../utils/app_theme.dart';
// // import '../widgets/common_widgets.dart';
// // import 'split_confirmation_screen.dart';

// // class SplitAmountScreen extends StatefulWidget {
// //   final List<Transaction> selectedTransactions;
// //   final List<MemberModel> selectedMembers;
// //   final double totalAmount;

// //   const SplitAmountScreen({
// //     super.key,
// //     required this.selectedTransactions,
// //     required this.selectedMembers,
// //     required this.totalAmount,
// //   });

// //   @override
// //   State<SplitAmountScreen> createState() =>
// //       _SplitAmountScreenState();
// // }

// // class _SplitAmountScreenState extends State<SplitAmountScreen> {
// //   late List<SplitEntry> _splitEntries;
// //   late List<TextEditingController> _controllers;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initEqualSplit();
// //   }

// //   void _initEqualSplit() {
// //     final count = widget.selectedMembers.length;
// //     final equalShare =
// //         double.parse((widget.totalAmount / count).toStringAsFixed(2));

// //     _splitEntries = widget.selectedMembers
// //         .map((m) => SplitEntry(
// //               member: m,
// //               amount: equalShare,
// //               isManuallyEdited: false,
// //             ))
// //         .toList();

// //     _controllers = _splitEntries
// //         .map((e) =>
// //             TextEditingController(text: e.amount.toStringAsFixed(2)))
// //         .toList();

// //     // Attach listeners
// //     for (var i = 0; i < _controllers.length; i++) {
// //       final idx = i;
// //       _controllers[idx].addListener(() => _onAmountChanged(idx));
// //     }
// //   }

// //   void _onAmountChanged(int editedIndex) {
// //     final text = _controllers[editedIndex].text;
// //     final newVal = double.tryParse(text);
// //     if (newVal == null) return;

// //     setState(() {
// //       _splitEntries[editedIndex].amount = newVal;
// //       _splitEntries[editedIndex].isManuallyEdited = true;
// //       _redistributeRemaining();
// //     });
// //   }

// //   void _redistributeRemaining() {
// //     final manualTotal = _splitEntries
// //         .where((e) => e.isManuallyEdited)
// //         .fold(0.0, (s, e) => s + e.amount);

// //     final nonManual =
// //         _splitEntries.where((e) => !e.isManuallyEdited).toList();

// //     if (nonManual.isEmpty) return; // all manually edited, show leftover

// //     final remaining = widget.totalAmount - manualTotal;
// //     if (remaining < 0) return;

// //     final share =
// //         double.parse((remaining / nonManual.length).toStringAsFixed(2));

// //     for (var entry in nonManual) {
// //       final idx = _splitEntries.indexOf(entry);
// //       entry.amount = share;
// //       // Update text without triggering listener
// //       _controllers[idx].removeListener(() => _onAmountChanged(idx));
// //       _controllers[idx].text = share.toStringAsFixed(2);
// //       _controllers[idx].addListener(() => _onAmountChanged(idx));
// //     }
// //   }

// //   double get _currentTotal =>
// //       _splitEntries.fold(0.0, (s, e) => s + e.amount);

// //   double get _leftover =>
// //       double.parse(
// //           (widget.totalAmount - _currentTotal).toStringAsFixed(2));

// //   bool get _allManual =>
// //       _splitEntries.every((e) => e.isManuallyEdited);

// //   bool get _canProceed => _leftover.abs() < 0.01;

// //   void _settleAndSplit() {
// //     if (_leftover.abs() < 0.01) {
// //       _proceedToConfirmation();
// //       return;
// //     }
// //     // Distribute leftover equally
// //     setState(() {
// //       final perPerson =
// //           double.parse((_leftover / _splitEntries.length).toStringAsFixed(2));
// //       for (var i = 0; i < _splitEntries.length; i++) {
// //         _splitEntries[i].amount += perPerson;
// //         _splitEntries[i].isManuallyEdited = true;
// //         _controllers[i].text =
// //             _splitEntries[i].amount.toStringAsFixed(2);
// //       }
// //     });
// //     Future.delayed(
// //         const Duration(milliseconds: 100), _proceedToConfirmation);
// //   }

// //   void _proceedToConfirmation() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => SplitConfirmationScreen(
// //           selectedTransactions: widget.selectedTransactions,
// //           splitEntries: _splitEntries,
// //           totalAmount: widget.totalAmount,
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     for (var c in _controllers) {
// //       c.dispose();
// //     }
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final leftover = _leftover;
// //     final hasLeftover = leftover.abs() >= 0.01;
// //     final allManual = _allManual;

// //     return Scaffold(
// //       backgroundColor: AppColors.background,
// //       appBar: AppBar(
// //         backgroundColor: AppColors.background,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Container(
// //             width: 36,
// //             height: 36,
// //             decoration: BoxDecoration(
// //               color: AppColors.surface,
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //             child: const Icon(Icons.arrow_downward,
// //                 size: 18, color: AppColors.textPrimary),
// //           ),
// //           onPressed: () => Navigator.pop(context),
// //           padding: const EdgeInsets.all(8),
// //         ),
// //         title: Text(
// //           '${widget.selectedMembers.length} Selected People',
// //           style: AppTextStyles.heading3,
// //         ),
// //         actions: [
// //           Padding(
// //             padding: const EdgeInsets.only(right: 12),
// //             child: Container(
// //               width: 36,
// //               height: 36,
// //               decoration: BoxDecoration(
// //                 color: AppColors.primaryDark,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: const Icon(Icons.space_dashboard_outlined,
// //                   size: 18, color: Colors.white),
// //             ),
// //           ),
// //         ],
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Title
// //             Padding(
// //               padding: const EdgeInsets.symmetric(vertical: 8),
// //               child: Text(
// //                 'Enter Amounts (Total: ${widget.totalAmount.toStringAsFixed(2)})',
// //                 style: AppTextStyles.bodyMedium,
// //               ),
// //             ),

// //             // Warning banner (leftover)
// //             AnimatedSize(
// //               duration: const Duration(milliseconds: 250),
// //               child: hasLeftover && allManual
// //                   ? Container(
// //                       width: double.infinity,
// //                       margin: const EdgeInsets.only(bottom: 12),
// //                       padding: const EdgeInsets.symmetric(
// //                           horizontal: 16, vertical: 12),
// //                       decoration: BoxDecoration(
// //                         color: AppColors.leftoverWarning,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(
// //                             color: const Color(0xFFE6C84A), width: 1),
// //                       ),
// //                       child: const Text(
// //                         'There is still some amount left over, please split the amount remained.',
// //                         style: TextStyle(
// //                           fontSize: 13,
// //                           color: Color(0xFF7A5A00),
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     )
// //                   : const SizedBox.shrink(),
// //             ),

// //             // Split entries
// //             Expanded(
// //               child: ListView.separated(
// //                 itemCount: _splitEntries.length,
// //                 separatorBuilder: (_, __) =>
// //                     const SizedBox(height: 10),
// //                 itemBuilder: (ctx, i) {
// //                   final entry = _splitEntries[i];
// //                   return _SplitEntryRow(
// //                     entry: entry,
// //                     controller: _controllers[i],
// //                     onReset: () {
// //                       setState(() {
// //                         entry.isManuallyEdited = false;
// //                         _redistributeRemaining();
// //                       });
// //                     },
// //                   );
// //                 },
// //               ),
// //             ),

// //             // Current total & leftover
// //             Container(
// //               margin: const EdgeInsets.symmetric(vertical: 12),
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                           horizontal: 14, vertical: 12),
// //                       decoration: BoxDecoration(
// //                         color: AppColors.surface,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(color: AppColors.divider),
// //                       ),
// //                       child: Text(
// //                         'Current Total: ₹ ${_currentTotal.toStringAsFixed(2)}',
// //                         style: AppTextStyles.labelBold,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 10),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                         horizontal: 14, vertical: 12),
// //                     decoration: BoxDecoration(
// //                       color: _canProceed
// //                           ? const Color(0xFFEBF9F0)
// //                           : AppColors.leftoverWarning,
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(
// //                         color: _canProceed
// //                             ? AppColors.successGreen
// //                             : const Color(0xFFE6C84A),
// //                       ),
// //                     ),
// //                     child: Text(
// //                       'Leftover: ₹ ${leftover.toStringAsFixed(2)}',
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w600,
// //                         color: _canProceed
// //                             ? AppColors.successGreen
// //                             : const Color(0xFFB8860B),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             // Help text
// //             if (!_canProceed)
// //               const Padding(
// //                 padding: EdgeInsets.only(bottom: 8),
// //                 child: Center(
// //                   child: Text(
// //                     'Click Settle to split leftover amount equally among all',
// //                     style: AppTextStyles.bodySmall,
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 ),
// //               ),

// //             // Buttons
// //             PrimaryButton(
// //               label: 'Settle & Split',
// //               onPressed: _settleAndSplit,
// //             ),
// //             const SizedBox(height: 10),
// //             PrimaryButton(
// //               label: 'Split',
// //               isOutlined: true,
// //               onPressed: _canProceed ? _proceedToConfirmation : null,
// //             ),
// //             const SizedBox(height: 20),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ── Split Entry Row ───────────────────────────────────────────────────────────
// // class _SplitEntryRow extends StatelessWidget {
// //   final SplitEntry entry;
// //   final TextEditingController controller;
// //   final VoidCallback onReset;

// //   const _SplitEntryRow({
// //     required this.entry,
// //     required this.controller,
// //     required this.onReset,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       children: [
// //         MemberAvatar(member: entry.member),
// //         const SizedBox(width: 12),
// //         Expanded(
// //           child: Text(entry.member.name, style: AppTextStyles.labelBold),
// //         ),
// //         if (entry.isManuallyEdited)
// //           GestureDetector(
// //             onTap: onReset,
// //             child: const Padding(
// //               padding: EdgeInsets.only(right: 6),
// //               child: Icon(Icons.refresh,
// //                   size: 16, color: AppColors.textLight),
// //             ),
// //           ),
// //         Container(
// //           width: 130,
// //           height: 44,
// //           decoration: BoxDecoration(
// //             color: AppColors.surface,
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(
// //               color: entry.isManuallyEdited
// //                   ? AppColors.primaryBlue
// //                   : AppColors.divider,
// //               width: entry.isManuallyEdited ? 1.5 : 1,
// //             ),
// //           ),
// //           child: Row(
// //             children: [
// //               const SizedBox(width: 10),
// //               const Text('₹', style: AppTextStyles.labelBold),
// //               const SizedBox(width: 4),
// //               Expanded(
// //                 child: TextField(
// //                   controller: controller,
// //                   keyboardType: const TextInputType.numberWithOptions(
// //                       decimal: true),
// //                   inputFormatters: [
// //                     FilteringTextInputFormatter.allow(
// //                         RegExp(r'^\d+\.?\d{0,2}')),
// //                   ],
// //                   style: AppTextStyles.labelBold,
// //                   decoration: const InputDecoration(
// //                     border: InputBorder.none,
// //                     isDense: true,
// //                     contentPadding: EdgeInsets.zero,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // ─── screens/split_amount_screen.dart ────────────────────────────────────────
// // FILE TO CHANGE: lib/Home_Screen/history/collections/trip/screens/split_amount_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../../../model/collections_model.dart';
// import '../models/models.dart';
// import '../utils/app_theme.dart';
// import '../widgets/common_widgets.dart';
// import 'split_confirmation_screen.dart';

// // ─── Color palette (uses AppColors + local overrides) ────────────────────────
// class _C {
//   static const bg = Color(0xFFF5F3EF); // app background
//   static const surface = Colors.white;
//   static const primary = Color(0xFF2D2B5B); // dark navy
//   static const accent = Color(0xFF4B4D73); // medium navy
//   static const success = Color(0xFF22C55E);
//   static const warning = Color(0xFFF59E0B);
//   static const warningBg = Color(0xFFFFFBEB);
//   static const warningBorder = Color(0xFFFDE68A);
//   static const border = Color(0xFFEBEBEB);
//   static const textDark = Color(0xFF1A1832);
//   static const textMid = Color(0xFF6B7280);
//   static const textLight = Color(0xFFACACAC);
//   static const edited = Color(0xFF2D2B5B);
//   static const editedBg = Color(0xFFEEF2FF);
// }

// class SplitAmountScreen extends StatefulWidget {
//   final List<Transaction> selectedTransactions;
//   final List<MemberModel> selectedMembers;
//   final double totalAmount;

//   const SplitAmountScreen({
//     super.key,
//     required this.selectedTransactions,
//     required this.selectedMembers,
//     required this.totalAmount,
//   });

//   @override
//   State<SplitAmountScreen> createState() => _SplitAmountScreenState();
// }

// class _SplitAmountScreenState extends State<SplitAmountScreen>
//     with TickerProviderStateMixin {
//   late List<SplitEntry> _splitEntries;
//   late List<TextEditingController> _controllers;
//   late List<FocusNode> _focusNodes;
//   late AnimationController _headerAnim;
//   late AnimationController _bannerAnim;
//   late Animation<double> _headerFade;

//   @override
//   void initState() {
//     super.initState();
//     _headerAnim = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 600));
//     _bannerAnim = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 300));
//     _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
//     _headerAnim.forward();
//     _initEqualSplit();
//   }

//   // ─────────────────────── LOGIC (UNCHANGED) ──────────────────────────────
//   void _initEqualSplit() {
//     final count = widget.selectedMembers.length;
//     final equalShare =
//         double.parse((widget.totalAmount / count).toStringAsFixed(2));

//     _splitEntries = widget.selectedMembers
//         .map((m) => SplitEntry(
//               member: m,
//               amount: equalShare,
//               isManuallyEdited: false,
//             ))
//         .toList();

//     _controllers = _splitEntries
//         .map((e) => TextEditingController(text: e.amount.toStringAsFixed(2)))
//         .toList();

//     _focusNodes = List.generate(_splitEntries.length, (_) => FocusNode());

//     for (var i = 0; i < _controllers.length; i++) {
//       final idx = i;
//       _controllers[idx].addListener(() => _onAmountChanged(idx));
//     }
//   }

//   void _onAmountChanged(int editedIndex) {
//     final text = _controllers[editedIndex].text;
//     final newVal = double.tryParse(text);
//     if (newVal == null) return;

//     setState(() {
//       _splitEntries[editedIndex].amount = newVal;
//       _splitEntries[editedIndex].isManuallyEdited = true;
//       _redistributeRemaining();
//     });
//   }

//   void _redistributeRemaining() {
//     final manualTotal = _splitEntries
//         .where((e) => e.isManuallyEdited)
//         .fold(0.0, (s, e) => s + e.amount);

//     final nonManual = _splitEntries.where((e) => !e.isManuallyEdited).toList();

//     if (nonManual.isEmpty) return;

//     final remaining = widget.totalAmount - manualTotal;
//     if (remaining < 0) return;

//     final share =
//         double.parse((remaining / nonManual.length).toStringAsFixed(2));

//     for (var entry in nonManual) {
//       final idx = _splitEntries.indexOf(entry);
//       entry.amount = share;
//       _controllers[idx].removeListener(() => _onAmountChanged(idx));
//       _controllers[idx].text = share.toStringAsFixed(2);
//       _controllers[idx].addListener(() => _onAmountChanged(idx));
//     }
//   }

//   double get _currentTotal => _splitEntries.fold(0.0, (s, e) => s + e.amount);

//   double get _leftover =>
//       double.parse((widget.totalAmount - _currentTotal).toStringAsFixed(2));

//   bool get _canProceed => _leftover.abs() < 0.01;

//   void _settleAndSplit() {
//     if (_leftover.abs() < 0.01) {
//       _proceedToConfirmation();
//       return;
//     }
//     setState(() {
//       final perPerson =
//           double.parse((_leftover / _splitEntries.length).toStringAsFixed(2));
//       for (var i = 0; i < _splitEntries.length; i++) {
//         _splitEntries[i].amount += perPerson;
//         _splitEntries[i].isManuallyEdited = true;
//         _controllers[i].text = _splitEntries[i].amount.toStringAsFixed(2);
//       }
//     });
//     Future.delayed(const Duration(milliseconds: 100), _proceedToConfirmation);
//   }

//   void _proceedToConfirmation() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SplitConfirmationScreen(
//           selectedTransactions: widget.selectedTransactions,
//           splitEntries: _splitEntries,
//           totalAmount: widget.totalAmount,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _headerAnim.dispose();
//     _bannerAnim.dispose();
//     for (var c in _controllers) c.dispose();
//     for (var f in _focusNodes) f.dispose();
//     super.dispose();
//   }

//   // ─────────────────────── BUILD ─────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final leftover = _leftover;
//     final hasLeftover = leftover.abs() >= 0.01;

//     return Scaffold(
//       backgroundColor: _C.bg,
//       body: Column(
//         children: [
//           // ── HEADER ──────────────────────────────────────────────────────
//           _buildHeader(context),

//           // ── LEFTOVER BANNER ──────────────────────────────────────────────
//           AnimatedSize(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             child: hasLeftover
//                 ? _LeftoverBanner(leftover: leftover)
//                 : const SizedBox.shrink(),
//           ),

//           // ── MEMBER LIST ─────────────────────────────────────────────────
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//               itemCount: _splitEntries.length,
//               itemBuilder: (ctx, i) {
//                 final entry = _splitEntries[i];
//                 return _SplitMemberCard(
//                   entry: entry,
//                   controller: _controllers[i],
//                   focusNode: _focusNodes[i],
//                   totalAmount: widget.totalAmount,
//                   onReset: () => setState(() {
//                     entry.isManuallyEdited = false;
//                     _redistributeRemaining();
//                   }),
//                 );
//               },
//             ),
//           ),

//           // ── BOTTOM BAR ──────────────────────────────────────────────────
//           _BottomBar(
//             leftover: leftover,
//             currentTotal: _currentTotal,
//             totalAmount: widget.totalAmount,
//             canProceed: _canProceed,
//             onSettle: _settleAndSplit,
//             onSplit: _canProceed ? _proceedToConfirmation : null,
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────── HEADER ────────────────────────────────────────────
//   Widget _buildHeader(BuildContext context) {
//     return FadeTransition(
//       opacity: _headerFade,
//       child: Container(
//         decoration: BoxDecoration(
//           color: _C.surface,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           bottom: false,
//           child: Column(
//             children: [
//               // Nav row
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Row(
//                   children: [
//                     _NavButton(
//                       icon: Icons.keyboard_arrow_down_rounded,
//                       onTap: () => Navigator.pop(context),
//                     ),
//                     Expanded(
//                       child: Column(
//                         children: [
//                           Text(
//                             '${widget.selectedMembers.length} People',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: _C.textDark,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             '${widget.selectedTransactions.length} transaction${widget.selectedTransactions.length != 1 ? 's' : ''}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: _C.textMid,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Distribution badge
//                     _DistributionChip(
//                       distributed: _currentTotal,
//                       total: widget.totalAmount,
//                     ),
//                   ],
//                 ),
//               ),

//               // Total amount card
//               _TotalAmountCard(totalAmount: widget.totalAmount),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────── TOTAL AMOUNT CARD ─────────────────────────────────
// class _TotalAmountCard extends StatelessWidget {
//   final double totalAmount;
//   const _TotalAmountCard({required this.totalAmount});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF2D2B5B), Color(0xFF4B4D73)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFF2D2B5B).withOpacity(0.30),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Total to Split',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white.withOpacity(0.65),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '₹${totalAmount.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//               ],
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.call_split_rounded,
//                       size: 14, color: Colors.white),
//                   const SizedBox(width: 5),
//                   Text(
//                     'Split',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────── DISTRIBUTION CHIP ─────────────────────────────────
// class _DistributionChip extends StatelessWidget {
//   final double distributed;
//   final double total;
//   const _DistributionChip({required this.distributed, required this.total});

//   @override
//   Widget build(BuildContext context) {
//     final ratio = total == 0 ? 0.0 : (distributed / total).clamp(0.0, 1.0);
//     final isComplete = (total - distributed).abs() < 0.01;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: isComplete ? const Color(0xFFDCFCE7) : const Color(0xFFEEF2FF),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: isComplete ? const Color(0xFF86EFAC) : const Color(0xFFC7D2FE),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             isComplete ? Icons.check_circle_rounded : Icons.pending_rounded,
//             size: 14,
//             color: isComplete ? _C.success : _C.accent,
//           ),
//           const SizedBox(width: 5),
//           Text(
//             isComplete ? 'Done' : '${(ratio * 100).toStringAsFixed(0)}%',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               color: isComplete ? _C.success : _C.accent,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────── LEFTOVER BANNER ───────────────────────────────────
// class _LeftoverBanner extends StatelessWidget {
//   final double leftover;
//   const _LeftoverBanner({required this.leftover});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: _C.warningBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _C.warningBorder),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.info_outline_rounded, size: 16, color: _C.warning),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               '₹${leftover.toStringAsFixed(2)} remaining — edit or tap "Settle & Split"',
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Color(0xFF92400E),
//                 fontWeight: FontWeight.w500,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────── MEMBER SPLIT CARD ─────────────────────────────────
// class _SplitMemberCard extends StatelessWidget {
//   final SplitEntry entry;
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final double totalAmount;
//   final VoidCallback onReset;

//   const _SplitMemberCard({
//     required this.entry,
//     required this.controller,
//     required this.focusNode,
//     required this.totalAmount,
//     required this.onReset,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final pct =
//         totalAmount == 0 ? 0.0 : (entry.amount / totalAmount).clamp(0.0, 1.0);
//     final isEdited = entry.isManuallyEdited;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: _C.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isEdited ? _C.edited.withOpacity(0.4) : _C.border,
//           width: isEdited ? 1.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           children: [
//             // Top row: avatar + name + input
//             Row(
//               children: [
//                 // Avatar
//                 _MemberAvatar(name: entry.member.name, isEdited: isEdited),
//                 const SizedBox(width: 12),

//                 // Name + role tag
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         entry.member.name,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: _C.textDark,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Text(
//                             '${(pct * 100).toStringAsFixed(1)}%',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w500,
//                               color: isEdited ? _C.edited : _C.textLight,
//                             ),
//                           ),
//                           if (isEdited) ...[
//                             const SizedBox(width: 6),
//                             GestureDetector(
//                               onTap: onReset,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 7, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: _C.editedBg,
//                                   borderRadius: BorderRadius.circular(6),
//                                   border: Border.all(
//                                       color: _C.edited.withOpacity(0.3)),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: const [
//                                     Icon(Icons.refresh_rounded,
//                                         size: 10, color: _C.edited),
//                                     SizedBox(width: 3),
//                                     Text(
//                                       'Reset',
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         color: _C.edited,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Amount input
//                 _AmountInput(
//                   controller: controller,
//                   focusNode: focusNode,
//                   isEdited: isEdited,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // Progress bar
//             _ProgressBar(value: pct, isEdited: isEdited),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────── MEMBER AVATAR ─────────────────────────────────────
// class _MemberAvatar extends StatelessWidget {
//   final String name;
//   final bool isEdited;
//   const _MemberAvatar({required this.name, required this.isEdited});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 42,
//       height: 42,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: isEdited
//               ? [_C.edited, const Color(0xFF818CF8)]
//               : [_C.primary, _C.accent],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: (isEdited ? _C.edited : _C.primary).withOpacity(0.25),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Text(
//           name.isNotEmpty ? name[0].toUpperCase() : 'U',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────── AMOUNT INPUT ──────────────────────────────────────
// class _AmountInput extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final bool isEdited;

//   const _AmountInput({
//     required this.controller,
//     required this.focusNode,
//     required this.isEdited,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 120,
//       height: 44,
//       decoration: BoxDecoration(
//         color: isEdited ? _C.editedBg : const Color(0xFFF5F3EF),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isEdited ? _C.edited : _C.border,
//           width: isEdited ? 1.5 : 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 10),
//           Text(
//             '₹',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: isEdited ? _C.edited : _C.textMid,
//             ),
//           ),
//           const SizedBox(width: 4),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               focusNode: focusNode,
//               keyboardType:
//                   const TextInputType.numberWithOptions(decimal: true),
//               inputFormatters: [
//                 FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//               ],
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: isEdited ? _C.edited : _C.textDark,
//               ),
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
//                 isDense: true,
//                 contentPadding: EdgeInsets.zero,
//               ),
//             ),
//           ),
//           const SizedBox(width: 6),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────── PROGRESS BAR ──────────────────────────────────────
// class _ProgressBar extends StatelessWidget {
//   final double value;
//   final bool isEdited;
//   const _ProgressBar({required this.value, required this.isEdited});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           height: 5,
//           decoration: BoxDecoration(
//             color: _C.border,
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         FractionallySizedBox(
//           widthFactor: value.clamp(0.0, 1.0),
//           child: Container(
//             height: 5,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isEdited
//                     ? [_C.edited, const Color(0xFF818CF8)]
//                     : [_C.primary, _C.accent],
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────── BOTTOM BAR ────────────────────────────────────────
// class _BottomBar extends StatelessWidget {
//   final double leftover;
//   final double currentTotal;
//   final double totalAmount;
//   final bool canProceed;
//   final VoidCallback onSettle;
//   final VoidCallback? onSplit;

//   const _BottomBar({
//     required this.leftover,
//     required this.currentTotal,
//     required this.totalAmount,
//     required this.canProceed,
//     required this.onSettle,
//     required this.onSplit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _C.surface,
//         border: const Border(top: BorderSide(color: _C.border)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Totals summary row
//               _TotalSummaryRow(
//                 currentTotal: currentTotal,
//                 leftover: leftover,
//                 canProceed: canProceed,
//               ),
//               const SizedBox(height: 12),

//               // Buttons row
//               Row(
//                 children: [
//                   // Settle & Split — always enabled
//                   Expanded(
//                     child: _ActionButton(
//                       label: 'Settle & Split',
//                       icon: Icons.auto_fix_high_rounded,
//                       primary: _C.primary,
//                       onTap: onSettle,
//                       enabled: true,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   // Split — only enabled if balanced
//                   Expanded(
//                     child: _ActionButton(
//                       label: 'Split',
//                       icon: Icons.call_split_rounded,
//                       primary: canProceed ? _C.success : _C.border,
//                       textColor: canProceed ? Colors.white : _C.textLight,
//                       onTap: onSplit,
//                       enabled: canProceed,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────── TOTAL SUMMARY ROW ─────────────────────────────────
// class _TotalSummaryRow extends StatelessWidget {
//   final double currentTotal;
//   final double leftover;
//   final bool canProceed;

//   const _TotalSummaryRow({
//     required this.currentTotal,
//     required this.leftover,
//     required this.canProceed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: _C.bg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _C.border),
//       ),
//       child: Row(
//         children: [
//           _SummaryChip(
//             label: 'Distributed',
//             value: '₹${currentTotal.toStringAsFixed(2)}',
//             color: _C.accent,
//           ),
//           Container(
//             width: 1,
//             height: 28,
//             margin: const EdgeInsets.symmetric(horizontal: 12),
//             color: _C.border,
//           ),
//           _SummaryChip(
//             label: 'Remaining',
//             value: '₹${leftover.toStringAsFixed(2)}',
//             color: canProceed ? _C.success : _C.warning,
//             isBold: true,
//           ),
//           if (canProceed) ...[
//             const Spacer(),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFDCFCE7),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.check_rounded, size: 12, color: _C.success),
//                   SizedBox(width: 4),
//                   Text(
//                     'Balanced',
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: _C.success,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _SummaryChip extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;
//   final bool isBold;

//   const _SummaryChip({
//     required this.label,
//     required this.value,
//     required this.color,
//     this.isBold = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 10,
//             color: _C.textLight,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 1),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────── ACTION BUTTON ─────────────────────────────────────
// class _ActionButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color primary;
//   final Color textColor;
//   final VoidCallback? onTap;
//   final bool enabled;

//   const _ActionButton({
//     required this.label,
//     required this.icon,
//     required this.primary,
//     this.textColor = Colors.white,
//     required this.onTap,
//     required this.enabled,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         height: 50,
//         decoration: BoxDecoration(
//           color: primary,
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: enabled
//               ? [
//                   BoxShadow(
//                     color: primary.withOpacity(0.30),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 16, color: textColor),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: textColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────── NAV BUTTON ────────────────────────────────────────
// class _NavButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _NavButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 38,
//         height: 38,
//         decoration: BoxDecoration(
//           color: _C.bg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _C.border),
//         ),
//         child: Icon(icon, size: 20, color: _C.textDark),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../model/collections_model.dart';
import '../models/collection_helper_models.dart';
import '../utils/app_theme_collections.dart';
import '../widgets/common_widgets.dart';
import 'split_confirmation_screen.dart';

// ─── Color palette (uses AppColors + local overrides) ────────────────────────
class _C {
  static const bg = Color(0xFFF5F3EF);
  static const surface = Colors.white;
  static const primary = Color(0xFF2D2B5B);
  static const accent = Color(0xFF4B4D73);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const border = Color(0xFFEBEBEB);
  static const textDark = Color(0xFF1A1832);
  static const textMid = Color(0xFF6B7280);
  static const textLight = Color(0xFFACACAC);
  static const edited = Color(0xFF2D2B5B);
  static const editedBg = Color(0xFFEEF2FF);
}

class SplitAmountScreen extends StatefulWidget {
  final List<TransactionForCollections> selectedTransactions;
  final List<MemberModel> selectedMembers;
  final double totalAmount;

  const SplitAmountScreen({
    super.key,
    required this.selectedTransactions,
    required this.selectedMembers,
    required this.totalAmount,
  });

  @override
  State<SplitAmountScreen> createState() => _SplitAmountScreenState();
}

class _SplitAmountScreenState extends State<SplitAmountScreen>
    with TickerProviderStateMixin {
  late List<SplitEntry> _splitEntries;
  late List<TextEditingController> _controllers;
  late List<VoidCallback> _controllerListeners;
  late List<FocusNode> _focusNodes;
  late AnimationController _headerAnim;
  late AnimationController _bannerAnim;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bannerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerAnim.forward();
    _initEqualSplit();
  }

  void _initEqualSplit() {
    final count = widget.selectedMembers.length;
    final equalShare =
        double.parse((widget.totalAmount / count).toStringAsFixed(2));

    _splitEntries = widget.selectedMembers
        .map(
          (m) => SplitEntry(
            member: m,
            amount: equalShare,
            isManuallyEdited: false,
          ),
        )
        .toList();

    _controllers = _splitEntries
        .map((e) => TextEditingController(text: e.amount.toStringAsFixed(2)))
        .toList();

    _focusNodes = List.generate(_splitEntries.length, (_) => FocusNode());
    _controllerListeners = List.generate(
      _controllers.length,
      (i) => () => _onAmountChanged(i),
    );

    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(_controllerListeners[i]);
    }
  }

  void _onAmountChanged(int editedIndex) {
    final text = _controllers[editedIndex].text.trim();
    final newVal = double.tryParse(text);
    if (newVal == null) return;

    setState(() {
      _splitEntries[editedIndex].amount = newVal;
      _splitEntries[editedIndex].isManuallyEdited = true;
      _redistributeRemaining();
    });
  }

  void _redistributeRemaining() {
    final manualTotal = _splitEntries
        .where((e) => e.isManuallyEdited)
        .fold(0.0, (s, e) => s + e.amount);

    final nonManualIndexes = <int>[];
    for (var i = 0; i < _splitEntries.length; i++) {
      if (!_splitEntries[i].isManuallyEdited) {
        nonManualIndexes.add(i);
      }
    }

    if (nonManualIndexes.isEmpty) return;

    final remaining = widget.totalAmount - manualTotal;
    if (remaining < 0) return;

    final share =
        double.parse((remaining / nonManualIndexes.length).toStringAsFixed(2));

    for (final idx in nonManualIndexes) {
      _splitEntries[idx].amount = share;
      _controllers[idx].removeListener(_controllerListeners[idx]);
      _controllers[idx].text = share.toStringAsFixed(2);
      _controllers[idx].addListener(_controllerListeners[idx]);
    }
  }

  double get _currentTotal => _splitEntries.fold(0.0, (s, e) => s + e.amount);

  double get _leftover =>
      double.parse((widget.totalAmount - _currentTotal).toStringAsFixed(2));

  bool get _canProceed => _leftover.abs() < 0.01;

  void _settleAndSplit() {
    if (_leftover.abs() < 0.01) {
      _proceedToConfirmation();
      return;
    }

    setState(() {
      final perPerson =
          double.parse((_leftover / _splitEntries.length).toStringAsFixed(2));
      for (var i = 0; i < _splitEntries.length; i++) {
        _splitEntries[i].amount += perPerson;
        _splitEntries[i].isManuallyEdited = true;
        _controllers[i].text = _splitEntries[i].amount.toStringAsFixed(2);
      }
    });

    Future.delayed(const Duration(milliseconds: 100), _proceedToConfirmation);
  }

  void _proceedToConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SplitConfirmationScreen(
          selectedTransactions: widget.selectedTransactions,
          splitEntries: _splitEntries,
          totalAmount: widget.totalAmount,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _bannerAnim.dispose();
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].removeListener(_controllerListeners[i]);
      _controllers[i].dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftover = _leftover;
    final hasLeftover = leftover.abs() >= 0.01;

    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(
        children: [
          _buildHeader(context),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: hasLeftover
                ? _LeftoverBanner(leftover: leftover)
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _splitEntries.length,
              itemBuilder: (ctx, i) {
                final entry = _splitEntries[i];
                return _SplitMemberCard(
                  entry: entry,
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  totalAmount: widget.totalAmount,
                  onReset: () => setState(() {
                    entry.isManuallyEdited = false;
                    _redistributeRemaining();
                  }),
                );
              },
            ),
          ),
          _BottomBar(
            leftover: leftover,
            currentTotal: _currentTotal,
            totalAmount: widget.totalAmount,
            canProceed: _canProceed,
            onSettle: _settleAndSplit,
            onSplit: _canProceed ? _proceedToConfirmation : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeTransition(
      opacity: _headerFade,
      child: Container(
        decoration: BoxDecoration(
          color: _C.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _NavButton(
                      icon: Icons.keyboard_arrow_down_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${widget.selectedMembers.length} People',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _C.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.selectedTransactions.length} transaction${widget.selectedTransactions.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _C.textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _DistributionChip(
                      distributed: _currentTotal,
                      total: widget.totalAmount,
                    ),
                  ],
                ),
              ),
              _TotalAmountCard(totalAmount: widget.totalAmount),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        child: Icon(
          icon,
          color: _C.textDark,
          size: 24,
        ),
      ),
    );
  }
}

class _TotalAmountCard extends StatelessWidget {
  final double totalAmount;
  const _TotalAmountCard({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D2B5B), Color(0xFF4B4D73)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D2B5B).withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total to Split',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.call_split_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Split',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionChip extends StatelessWidget {
  final double distributed;
  final double total;
  const _DistributionChip({required this.distributed, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (distributed / total).clamp(0.0, 1.0);
    final isComplete = (total - distributed).abs() < 0.01;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFFDCFCE7) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isComplete ? const Color(0xFF86EFAC) : const Color(0xFFC7D2FE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 14,
            color: isComplete ? _C.success : _C.accent,
          ),
          const SizedBox(width: 5),
          Text(
            isComplete ? 'Done' : '${(ratio * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isComplete ? _C.success : _C.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftoverBanner extends StatelessWidget {
  final double leftover;
  const _LeftoverBanner({required this.leftover});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _C.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.warningBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: _C.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '₹${leftover.toStringAsFixed(2)} remaining — edit or tap "Settle & Split"',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitMemberCard extends StatelessWidget {
  final SplitEntry entry;
  final TextEditingController controller;
  final FocusNode focusNode;
  final double totalAmount;
  final VoidCallback onReset;

  const _SplitMemberCard({
    required this.entry,
    required this.controller,
    required this.focusNode,
    required this.totalAmount,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final pct =
        totalAmount == 0 ? 0.0 : (entry.amount / totalAmount).clamp(0.0, 1.0);
    final isEdited = entry.isManuallyEdited;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEdited ? _C.edited.withOpacity(0.4) : _C.border,
          width: isEdited ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _MemberAvatar(name: entry.member.name, isEdited: isEdited),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.member.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _C.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${(pct * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isEdited ? _C.edited : _C.textLight,
                            ),
                          ),
                          if (isEdited) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: onReset,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _C.editedBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _C.edited.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.refresh_rounded,
                                      size: 10,
                                      color: _C.edited,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _C.edited,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _AmountInput(
                  controller: controller,
                  focusNode: focusNode,
                  isEdited: isEdited,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProgressBar(value: pct, isEdited: isEdited),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final String name;
  final bool isEdited;
  const _MemberAvatar({required this.name, required this.isEdited});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEdited
              ? [_C.edited, const Color(0xFF818CF8)]
              : [_C.primary, _C.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isEdited ? _C.edited : _C.primary).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEdited;

  const _AmountInput({
    required this.controller,
    required this.focusNode,
    required this.isEdited,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 44,
      decoration: BoxDecoration(
        color: isEdited ? _C.editedBg : const Color(0xFFF5F3EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEdited ? _C.edited : _C.border,
          width: isEdited ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Text(
            '₹',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isEdited ? _C.edited : _C.textMid,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+\.?\d{0,2}'),
                ),
              ],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isEdited ? _C.edited : _C.textDark,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final bool isEdited;
  const _ProgressBar({required this.value, required this.isEdited});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: _C.border,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEdited
                    ? [_C.edited, const Color(0xFF818CF8)]
                    : [_C.primary, _C.accent],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double leftover;
  final double currentTotal;
  final double totalAmount;
  final bool canProceed;
  final VoidCallback onSettle;
  final VoidCallback? onSplit;

  const _BottomBar({
    required this.leftover,
    required this.currentTotal,
    required this.totalAmount,
    required this.canProceed,
    required this.onSettle,
    required this.onSplit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        border: const Border(top: BorderSide(color: _C.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TotalSummaryRow(
                currentTotal: currentTotal,
                leftover: leftover,
                canProceed: canProceed,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Settle & Split',
                      icon: Icons.auto_fix_high_rounded,
                      primary: _C.primary,
                      onTap: onSettle,
                      enabled: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: 'Split',
                      icon: Icons.call_split_rounded,
                      primary: canProceed ? _C.success : _C.border,
                      textColor: canProceed ? Colors.white : _C.textLight,
                      onTap: onSplit,
                      enabled: canProceed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalSummaryRow extends StatelessWidget {
  final double currentTotal;
  final double leftover;
  final bool canProceed;

  const _TotalSummaryRow({
    required this.currentTotal,
    required this.leftover,
    required this.canProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Total',
                  style: TextStyle(
                    fontSize: 11,
                    color: _C.textMid,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${currentTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: canProceed ? const Color(0xFFECFDF5) : _C.warningBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: canProceed ? const Color(0xFF86EFAC) : _C.warningBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canProceed ? 'Balanced' : 'Leftover',
                  style: TextStyle(
                    fontSize: 11,
                    color: canProceed ? _C.success : const Color(0xFF92400E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${leftover.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: canProceed ? _C.success : const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color primary;
  final Color textColor;
  final VoidCallback? onTap;
  final bool enabled;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.primary,
    this.textColor = Colors.white,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.85,
      child: Material(
        color: primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
