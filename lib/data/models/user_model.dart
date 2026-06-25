import 'package:equatable/equatable.dart';

enum UserStatus { online, away, offline }

class MinoUser extends Equatable {
  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final String? phone;          // optional, never required
  final UserStatus status;
  final DateTime? lastSeen;
  final bool isVerified;
  final String? fcmToken;

  const MinoUser({
    required this.id,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.status = UserStatus.offline,
    this.lastSeen,
    this.isVerified = false,
    this.fcmToken,
  });

  factory MinoUser.fromMap(Map<String, dynamic> m) => MinoUser(
    id: m['id'] as String,
    displayName: m['display_name'] as String? ?? 'Mino user',
    email: m['email'] as String?,
    avatarUrl: m['avatar_url'] as String?,
    bio: m['bio'] as String?,
    phone: m['phone'] as String?,
    status: UserStatus.values.firstWhere(
      (s) => s.name == (m['status'] as String?),
      orElse: () => UserStatus.offline,
    ),
    lastSeen: m['last_seen'] == null
        ? null
        : DateTime.tryParse(m['last_seen'] as String)?.toLocal(),
    isVerified: (m['is_verified'] as bool?) ?? false,
    fcmToken: m['fcm_token'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'display_name': displayName,
    if (email != null) 'email': email,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (bio != null) 'bio': bio,
    if (phone != null) 'phone': phone,
    'status': status.name,
    if (lastSeen != null) 'last_seen': lastSeen!.toUtc().toIso8601String(),
    'is_verified': isVerified,
    if (fcmToken != null) 'fcm_token': fcmToken,
  };

  MinoUser copyWith({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? phone,
    UserStatus? status,
    DateTime? lastSeen,
    bool? isVerified,
    String? fcmToken,
  }) =>
      MinoUser(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        bio: bio ?? this.bio,
        phone: phone ?? this.phone,
        status: status ?? this.status,
        lastSeen: lastSeen ?? this.lastSeen,
        isVerified: isVerified ?? this.isVerified,
        fcmToken: fcmToken ?? this.fcmToken,
      );

  @override
  List<Object?> get props => [id, displayName, avatarUrl, status, lastSeen];
}
