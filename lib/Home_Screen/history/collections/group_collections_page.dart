import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────

class GroupMember {
  final String id;
  final String name;
  final double spent;
  final double limit;

  const GroupMember({
    required this.id,
    required this.name,
    required this.spent,
    required this.limit,
  });
}

class BalanceEntry {
  final String id;
  final String name;
  final double amount;

  const BalanceEntry(
      {required this.id, required this.name, required this.amount});
}

class FixedBill {
  final String icon; // emoji or icon key
  final String title;
  final String dueDate;
  final double amount;
  final bool isPaid;

  const FixedBill({
    required this.icon,
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.isPaid,
  });
}

class Transaction {
  final String id;
  final String personName;
  final String date;
  final String category;
  final String taggedPerson;
  final double amount;
  final String addedBy;

  const Transaction({
    required this.id,
    required this.personName,
    required this.date,
    required this.category,
    required this.taggedPerson,
    required this.amount,
    required this.addedBy,
  });
}

// ─────────────────────────────────────────
// DUMMY DATA
// ─────────────────────────────────────────

final List<GroupMember> dummyMembers = [
  GroupMember(id: 'M', name: 'Meena', spent: 385, limit: 400),
  GroupMember(id: 'R', name: 'Reena', spent: 385, limit: 400),
  GroupMember(id: 'K', name: 'Karan', spent: 290, limit: 400),
  GroupMember(id: 'A', name: 'Arjun', spent: 310, limit: 400),
];

final List<BalanceEntry> toPayList = [
  BalanceEntry(id: 'R', name: 'Riya', amount: 600),
  BalanceEntry(id: 'A', name: 'Arjun', amount: 450),
];

final List<BalanceEntry> toReceiveList = [
  BalanceEntry(id: 'M', name: 'Meena', amount: 800),
  BalanceEntry(id: 'K', name: 'Karan', amount: 350),
];

final List<FixedBill> dummyBills = [
  FixedBill(
      icon: 'electricity',
      title: 'Electricity Bill',
      dueDate: '30 May 2024',
      amount: 1200,
      isPaid: true),
  FixedBill(
      icon: 'home',
      title: 'Rent',
      dueDate: '1 Jun 2024',
      amount: 8000,
      isPaid: false),
  FixedBill(
      icon: 'coffee',
      title: 'Coffee Fund',
      dueDate: '15 Jun 2024',
      amount: 500,
      isPaid: false),
];

final List<Transaction> dummyTransactions = [
  Transaction(
      id: '1',
      personName: 'Meena',
      date: '25 Oct',
      category: 'Food',
      taggedPerson: 'Roshan',
      amount: 15.00,
      addedBy: 'Meena'),
  Transaction(
      id: '2',
      personName: 'Aarav',
      date: '26 Oct',
      category: 'Beverage',
      taggedPerson: 'Priya',
      amount: 30.00,
      addedBy: 'Aarav'),
  Transaction(
      id: '3',
      personName: 'Saanvi',
      date: '20 Oct',
      category: 'Snacks',
      taggedPerson: 'Karan',
      amount: 20.00,
      addedBy: 'Saanvi'),
  Transaction(
      id: '4',
      personName: 'Reena',
      date: '18 Oct',
      category: 'Transport',
      taggedPerson: 'Arjun',
      amount: 45.00,
      addedBy: 'Reena'),
  Transaction(
      id: '5',
      personName: 'Karan',
      date: '17 Oct',
      category: 'Food',
      taggedPerson: 'Meena',
      amount: 60.00,
      addedBy: 'Karan'),
];

// ─────────────────────────────────────────
// THEME / CONSTANTS
// ─────────────────────────────────────────

const Color kBg = Color(0xFFF5F0E8);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kNavy = Color(0xFF2B2F42);
const Color kNavyLight = Color(0xFF3D4159);
const Color kRed = Color(0xFFD94040);
const Color kRedLight = Color(0xFFFDE8E8);
const Color kGreenLight = Color(0xFFE8F5F0);
const Color kGreen = Color(0xFF2E8B6E);
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF8A8A9A);
const Color kOrange = Color(0xFFE8793A);
const Color kOrangeLight = Color(0xFFFFF0E6);
const Color kDivider = Color(0xFFEEEBE4);

class GroupCoolectionsPage extends StatefulWidget {
  const GroupCoolectionsPage({super.key});

  @override
  State<GroupCoolectionsPage> createState() => _GoaTripPageState();
}

class _GoaTripPageState extends State<GroupCoolectionsPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ──
            // SliverToBoxAdapter(child: _buildAppBar(context)),

            // ── Search + Add ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _SearchAddRow(controller: _searchCtrl),
              ),
            ),

            // ── Group Info Badge ──
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _GroupInfoBadge(),
              ),
            ),

            // ── Combined Amount Card + Members Scroll ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CombinedAmountCard(members: dummyMembers),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Balance Status ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _BalanceStatusSection(
                  toPay: toPayList,
                  toReceive: toReceiveList,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Fixed Bills ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(title: 'Fixed Bills', onViewAll: () {}),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _BillCard(bill: dummyBills[i]),
                ),
                childCount: dummyBills.length,
              ),
            ),

            // ── Add Bill Button ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: _AddBillButton(onTap: () {}),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Text(
                    'Bills are automatically split between members.',
                    style: TextStyle(fontSize: 12, color: kTextSecondary),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: Divider(color: kDivider, height: 1)),

            // ── Transactions ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _TransactionCard(tx: dummyTransactions[i]),
                ),
                childCount: dummyTransactions.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}



class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, size: 18, color: kTextPrimary),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String initial;
  final double size;
  final Color bg;
  final Color textColor;

  const _AvatarCircle({
    required this.initial,
    this.size = 36,
    this.bg = kNavy,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary)),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: const Text('View All',
                  style: TextStyle(
                      fontSize: 13, color: kNavy, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SEARCH + ADD ROW
// ─────────────────────────────────────────

class _SearchAddRow extends StatelessWidget {
  final TextEditingController controller;
  const _SearchAddRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14, color: kTextPrimary),
              decoration: const InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: kTextSecondary, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search_rounded, color: kTextSecondary, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: const Icon(Icons.add_rounded, color: kTextPrimary, size: 22),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// GROUP INFO BADGE
// ─────────────────────────────────────────

class _GroupInfoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: kNavy.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          '4 Members  |  Active since May 2024',
          style: TextStyle(
              fontSize: 13, color: kNavy, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// COMBINED AMOUNT CARD
// ─────────────────────────────────────────

class _CombinedAmountCard extends StatelessWidget {
  final List<GroupMember> members;
  const _CombinedAmountCard({required this.members});

  double get totalAmount => members.fold(0.0, (sum, m) => sum + m.spent * 10);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 0, 18),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${13330.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary),
                ),
                const SizedBox(height: 2),
                const Text('Combined Amount',
                    style: TextStyle(fontSize: 13, color: kTextSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Horizontal scrollable member cards
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: members.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) => _MemberSpendCard(member: members[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberSpendCard extends StatelessWidget {
  final GroupMember member;
  const _MemberSpendCard({required this.member});

  double get progress => (member.spent / member.limit).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AvatarCircle(initial: member.id, size: 30),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  member.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${member.spent.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary),
                ),
                TextSpan(
                  text: '/${member.limit.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, color: kTextSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: kDivider,
              valueColor: const AlwaysStoppedAnimation<Color>(kNavy),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BALANCE STATUS SECTION
// ─────────────────────────────────────────

class _BalanceStatusSection extends StatelessWidget {
  final List<BalanceEntry> toPay;
  final List<BalanceEntry> toReceive;
  const _BalanceStatusSection({required this.toPay, required this.toReceive});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Balance Status',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextPrimary)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _BalanceCard(
                    title: 'To Pay', entries: toPay, isPayment: true)),
            const SizedBox(width: 12),
            Expanded(
                child: _BalanceCard(
                    title: 'To Receive', entries: toReceive, isPayment: false)),
          ],
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final List<BalanceEntry> entries;
  final bool isPayment;
  const _BalanceCard(
      {required this.title, required this.entries, required this.isPayment});

  @override
  Widget build(BuildContext context) {
    final bg = isPayment ? kRedLight : kGreenLight;
    final iconBg = isPayment ? kRed : kGreen;
    final amtClr = isPayment ? kRed : kGreen;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration:
                    BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(
                  isPayment
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _AvatarCircle(initial: e.id, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(e.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: kTextPrimary)),
                  ),
                  Text(
                    '₹${e.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: amtClr),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BILL CARD
// ─────────────────────────────────────────

class _BillCard extends StatelessWidget {
  final FixedBill bill;
  const _BillCard({required this.bill});

  IconData get _icon {
    switch (bill.icon) {
      case 'electricity':
        return Icons.lightbulb_outline_rounded;
      case 'home':
        return Icons.home_outlined;
      case 'coffee':
        return Icons.coffee_rounded;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: kBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(_icon, size: 20, color: kNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary)),
                const SizedBox(height: 2),
                Text('Due: ${bill.dueDate}',
                    style:
                        const TextStyle(fontSize: 12, color: kTextSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${bill.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary)),
              const SizedBox(height: 4),
              _StatusBadge(isPaid: bill.isPaid),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPaid;
  const _StatusBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isPaid ? kGreenLight : kOrangeLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Pending',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPaid ? kGreen : kOrange,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ADD BILL BUTTON
// ─────────────────────────────────────────

class _AddBillButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBillButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kNavy, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 20, color: kNavy),
            SizedBox(width: 6),
            Text('Add Bill',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: kNavy)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// TRANSACTION CARD
// ─────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final Transaction tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arrow icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: kBg, borderRadius: BorderRadius.circular(10)),
            child:
                const Icon(Icons.arrow_outward_rounded, size: 18, color: kNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tx.personName,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kTextPrimary)),
                    Text(
                      '- ₹${tx.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(tx.date,
                    style:
                        const TextStyle(fontSize: 12, color: kTextSecondary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _Tag(label: tx.category, isOutlined: true),
                        const SizedBox(width: 6),
                        _Tag(label: tx.taggedPerson, isOutlined: false),
                      ],
                    ),
                    Text(
                      '${tx.addedBy} Added',
                      style: const TextStyle(
                          fontSize: 11,
                          color: kTextSecondary,
                          fontStyle: FontStyle.italic),
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
}

class _Tag extends StatelessWidget {
  final String label;
  final bool isOutlined;
  const _Tag({required this.label, required this.isOutlined});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : kNavy,
        borderRadius: BorderRadius.circular(6),
        border: isOutlined ? Border.all(color: kDivider) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isOutlined ? kTextSecondary : Colors.white,
        ),
      ),
    );
  }
}
