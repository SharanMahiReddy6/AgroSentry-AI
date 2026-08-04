class UserModel {
  final int id;
  final String email;
  final String? fullName;
  final bool isAdmin;
  final String? region;
  final String? primaryCrop;
  final String? username;
  final String? phoneNumber;
  final String? location;
  final String? organization;
  final String? profilePhoto;
  final bool twoFactorEnabled;
  final String? theme;
  final String? language;
  final bool? emailNotifications;
  final bool? pushNotifications;
  final bool? privacyShareData;
  final String? fcmToken;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    required this.isAdmin,
    this.region,
    this.primaryCrop,
    this.username,
    this.phoneNumber,
    this.location,
    this.organization,
    this.profilePhoto,
    this.twoFactorEnabled = false,
    this.theme,
    this.language,
    this.emailNotifications,
    this.pushNotifications,
    this.privacyShareData,
    this.fcmToken,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      isAdmin: json['is_admin'] == true,
      region: json['region']?.toString(),
      primaryCrop: json['primary_crop']?.toString(),
      username: json['username']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      location: json['location']?.toString(),
      organization: json['organization']?.toString(),
      profilePhoto: json['profile_photo']?.toString(),
      twoFactorEnabled: json['two_factor_enabled'] == true,
      theme: json['theme']?.toString(),
      language: json['language']?.toString(),
      emailNotifications: json['email_notifications'] as bool?,
      pushNotifications: json['push_notifications'] as bool?,
      privacyShareData: json['privacy_share_data'] as bool?,
      fcmToken: json['fcm_token']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_admin': isAdmin,
      'region': region,
      'primary_crop': primaryCrop,
      'username': username,
      'phone_number': phoneNumber,
      'location': location,
      'organization': organization,
      'profile_photo': profilePhoto,
      'two_factor_enabled': twoFactorEnabled,
      'theme': theme,
      'language': language,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'privacy_share_data': privacyShareData,
      'fcm_token': fcmToken,
      'created_at': createdAt,
    };
  }
}
