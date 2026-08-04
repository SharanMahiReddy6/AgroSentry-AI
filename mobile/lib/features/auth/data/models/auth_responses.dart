class LoginResponse {
  final String accessToken;
  final String tokenType;

  LoginResponse({required this.accessToken, required this.tokenType});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
    );
  }
}

class GenericAuthResponse {
  final bool success;
  final String message;

  GenericAuthResponse({required this.success, required this.message});

  factory GenericAuthResponse.fromJson(Map<String, dynamic> json) {
    return GenericAuthResponse(
      success: json['success'] is bool
          ? json['success'] as bool
          : (json['success']?.toString().toLowerCase() != 'false'),
      message: json['message']?.toString() ?? '',
    );
  }
}
