// ─── data/dummy_data.dart ────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../models/models.dart';

class DummyData {
  // ── Members ──────────────────────────────────────────────────────────────
  // static final List<TripMember> members = [
  //   const TripMember(
  //     id: 'm1',
  //     name: 'Meena',
  //     avatarInitial: 'M',
  //     avatarColor: Color(0xFF3D4F7C),
  //     spent: 385,
  //     budget: 400,
  //   ),
  //   const TripMember(
  //     id: 'm2',
  //     name: 'Reena',
  //     avatarInitial: 'R',
  //     avatarColor: Color(0xFF7B4F9E),
  //     spent: 385,
  //     budget: 400,
  //   ),
  //   const TripMember(
  //     id: 'm3',
  //     name: 'Riya',
  //     avatarInitial: 'R',
  //     avatarColor: Color(0xFF2E7D32),
  //     spent: 320,
  //     budget: 400,
  //   ),
  //   const TripMember(
  //     id: 'm4',
  //     name: 'Arjun',
  //     avatarInitial: 'A',
  //     avatarColor: Color(0xFF00838F),
  //     spent: 280,
  //     budget: 400,
  //   ),
  //   const TripMember(
  //     id: 'm5',
  //     name: 'Karan',
  //     avatarInitial: 'K',
  //     avatarColor: Color(0xFF6D4C41),
  //     spent: 240,
  //     budget: 400,
  //   ),
  //   const TripMember(
  //     id: 'm6',
  //     name: 'Priya',
  //     avatarInitial: 'P',
  //     avatarColor: Color(0xFF455A64),
  //     spent: 190,
  //     budget: 400,
  //   ),
  //   const TripMember(
  //     id: 'm7',
  //     name: 'Anu',
  //     avatarInitial: 'A',
  //     avatarColor: Color(0xFF3D4F7C),
  //     spent: 150,
  //     budget: 400,
  //   ),
  //   const TripMember(
  //     id: 'm8',
  //     name: 'Anusri',
  //     avatarInitial: 'A',
  //     avatarColor: Color(0xFF7B4F9E),
  //     spent: 100,
  //     budget: 400,
  //   ),
  // ];

  // ── Balance entries ───────────────────────────────────────────────────────
  // static List<BalanceEntry> get balances => [
  //       BalanceEntry(
  //         member: members[2],
  //         amount: 600,
  //         type: BalanceType.toPay,
  //       ),
  //       BalanceEntry(
  //         member: members[3],
  //         amount: 450,
  //         type: BalanceType.toPay,
  //       ),
  //       BalanceEntry(
  //         member: members[0],
  //         amount: 800,
  //         type: BalanceType.toReceive,
  //       ),
  //       BalanceEntry(
  //         member: members[4],
  //         amount: 350,
  //         type: BalanceType.toReceive,
  //       ),
  //     ];

  // ── Fixed Bills ───────────────────────────────────────────────────────────
  static final List<FixedBill> fixedBills = [
    const FixedBill(
      id: 'b1',
      title: 'Electricity Bill',
      iconKey: 'electricity',
      amount: 1200,
      dueDate: 'Due: 30 May 2024',
      status: BillStatus.paid,
    ),
    const FixedBill(
      id: 'b2',
      title: 'Rent',
      iconKey: 'rent',
      amount: 8000,
      dueDate: 'Due: 1 Jun 2024',
      status: BillStatus.pending,
    ),
    const FixedBill(
      id: 'b3',
      title: 'Coffee Fund',
      iconKey: 'coffee',
      amount: 500,
      dueDate: 'Due: 15 Jun 2024',
      status: BillStatus.pending,
    ),
    const FixedBill(
      id: 'b4',
      title: 'Internet Bill',
      iconKey: 'internet',
      amount: 999,
      dueDate: 'Due: 20 Jun 2024',
      status: BillStatus.pending,
    ),
  ];

  // ── Transactions ─────────────────────────────────────────────────────────
  static final List<Transaction> transactions = [
    Transaction(
      id: 't1',
      title: 'Meena',
      date: '25 oct',
      amount: 15.00,
      category: 'Food',
      addedBy: 'Meena',
      taggedMemberId: 'm2',
    ),
    Transaction(
      id: 't2',
      title: 'Aarav',
      date: '26 oct',
      amount: 30.00,
      category: 'Beverage',
      addedBy: 'Aarav',
      taggedMemberId: 'm6',
    ),
    Transaction(
      id: 't3',
      title: 'Saanvi',
      date: '26 oct',
      amount: 20.00,
      category: 'Food',
      addedBy: 'Saanvi',
      taggedMemberId: 'm1',
    ),
    Transaction(
      id: 't4',
      title: 'Lunch at Beach',
      date: '27 oct',
      amount: 450.00,
      category: 'Food',
      addedBy: 'Meena',
      taggedMemberId: 'm0',
    ),
    Transaction(
      id: 't5',
      title: 'Taxi to Hotel',
      date: '27 oct',
      amount: 280.00,
      category: 'Travel',
      addedBy: 'Reena',
      taggedMemberId: 'm1',
    ),
    Transaction(
      id: 't6',
      title: 'Grocery Run',
      date: '28 oct',
      amount: 620.00,
      category: 'Grocery',
      addedBy: 'Arjun',
      taggedMemberId: 'm3',
    ),
    Transaction(
      id: 't7',
      title: 'Night Club Entry',
      date: '28 oct',
      amount: 1500.00,
      category: 'Entertainment',
      addedBy: 'Karan',
      taggedMemberId: 'm4',
    ),
    Transaction(
      id: 't8',
      title: 'Breakfast',
      date: '29 oct',
      amount: 340.00,
      category: 'Food',
      addedBy: 'Priya',
      taggedMemberId: 'm5',
    ),
    Transaction(
      id: 't9',
      title: 'Bike Rental',
      date: '29 oct',
      amount: 800.00,
      category: 'Travel',
      addedBy: 'Meena',
      taggedMemberId: 'm0',
    ),
    Transaction(
      id: 't10',
      title: 'Sunset Cruise',
      date: '30 oct',
      amount: 2200.00,
      category: 'Entertainment',
      addedBy: 'Reena',
      taggedMemberId: 'm1',
    ),
  ];

  static double get combinedAmount =>
      transactions.fold(0, (sum, t) => sum + t.amount);
}
