class GuestLoginResponse {
  final bool success;
  final String message;
  final GuestLoginData? data;

  const GuestLoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory GuestLoginResponse.fromJson(Map<String, dynamic> json) {
    return GuestLoginResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? GuestLoginData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GuestLoginData {
  final String token;
  final int credits;

  const GuestLoginData({
    required this.token,
    required this.credits,
  });

  factory GuestLoginData.fromJson(Map<String, dynamic> json) {
    return GuestLoginData(
      token: json['token']?.toString() ?? '',
      credits: (json['credits'] as num?)?.toInt() ?? 0,
    );
  }
}
