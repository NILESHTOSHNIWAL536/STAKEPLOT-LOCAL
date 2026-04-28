class DeviceModel {
  String deviceId;
  String brand;
  String device;
  String model;
  String os;

  DeviceModel({
    required this.deviceId,
    required this.brand,
    required this.device,
    required this.model,
    required this.os,
  });

  /// Convert to JSON (for API / storage)
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'brand': brand,
      'device': device,
      'model': model,
      'os': os,
    };
  }

  /// Create from JSON (if needed later)
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceId: json['deviceId'] ?? '',
      brand: json['brand'] ?? '',
      device: json['device'] ?? '',
      model: json['model'] ?? '',
      os: json['os'] ?? '',
    );
  }
  
  factory DeviceModel.empty() {
  return DeviceModel(
    deviceId: "",
    brand: "",
    device: "",
    model: "",
    os: "",
  );
}
}