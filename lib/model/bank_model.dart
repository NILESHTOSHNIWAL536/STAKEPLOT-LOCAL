// lib/model/bank_models.dart

class BankAccountModel {
  // -------- Bank info --------
  final String bankId;
  final String bankName;
  final String bankLogo;
  final String fipId;

  // -------- Account info --------
  final String accountId;
  final String maskedAccNumber;
  final String type;
  final double currentBalance;

  // -------- Fetch info --------
  final String lastFetch;
  final String nextFetch;
  final int fetchCount;

  // -------- User / holder profile --------
  final String name;
  final String pan;
  final String dob;
  final String mobile;
  final String address;

  // -------- Branch info --------
  final String ifscCode;
  final String branchAddress;

  BankAccountModel({
    required this.bankId,
    required this.bankName,
    required this.bankLogo,
    required this.fipId,
    required this.accountId,
    required this.maskedAccNumber,
    required this.type,
    required this.currentBalance,
    required this.lastFetch,
    required this.nextFetch,
    required this.fetchCount,
    required this.name,
    required this.pan,
    required this.dob,
    required this.mobile,
    required this.address,
    required this.ifscCode,
    required this.branchAddress,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      bankId: json['bankId']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      bankLogo: json['bankLogo']?.toString() ?? '',
      fipId: json['fipId']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      maskedAccNumber: json['maskedAccNumber']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      currentBalance:
          double.tryParse(json['currentBalance']?.toString() ?? '0') ?? 0.0,
      lastFetch: json['lastFetch']?.toString() ?? '',
      nextFetch: json['nextFetch']?.toString() ?? '',
      fetchCount: int.tryParse(json['fetchCount']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      pan: json['pan']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      ifscCode: json['ifscCode']?.toString() ?? '',
      branchAddress: json['branchAddress']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankId': bankId,
      'bankName': bankName,
      'bankLogo': bankLogo,
      'fipId': fipId,
      'accountId': accountId,
      'maskedAccNumber': maskedAccNumber,
      'type': type,
      'currentBalance': currentBalance,
      'lastFetch': lastFetch,
      'nextFetch': nextFetch,
      'fetchCount': fetchCount,
      'name': name,
      'pan': pan,
      'dob': dob,
      'mobile': mobile,
      'address': address,
      'ifscCode': ifscCode,
      'branchAddress': branchAddress,
    };
  }
}

class ConsentInfoModel {
  final String consentId;
  final String consendHandleId;
  final String sessionId;
  final String custId;

  final String lastFetch;
  final String nextFetch;
  final int fetchCount;

  final String accountId;
  final String bankName;
  final String fipId;

  ConsentInfoModel({
    required this.consentId,
    required this.consendHandleId,
    required this.sessionId,
    required this.custId,
    required this.lastFetch,
    required this.nextFetch,
    required this.fetchCount,
    required this.accountId,
    required this.bankName,
    required this.fipId,
  });

  factory ConsentInfoModel.fromJson(Map<String, dynamic> json) {
    return ConsentInfoModel(
      consentId: json['consentId']?.toString() ?? '',
      consendHandleId: json['consendHandleId']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      custId: json['custId']?.toString() ?? '',
      lastFetch: json['lastFetch']?.toString() ?? '',
      nextFetch: json['nextFetch']?.toString() ?? '',
      fetchCount: int.tryParse(json['fetchCount']?.toString() ?? '0') ?? 0,
      accountId: json['accountId']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      fipId: json['fipId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consentId': consentId,
      'consendHandleId': consendHandleId,
      'sessionId': sessionId,
      'custId': custId,
      'lastFetch': lastFetch,
      'nextFetch': nextFetch,
      'fetchCount': fetchCount,
      'accountId': accountId,
      'bankName': bankName,
      'fipId': fipId,
    };
  }
}
