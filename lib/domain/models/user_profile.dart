import 'avatar.dart';
import 'enums.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.avatarId,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.injuries,
    required this.onboardingCompleted,
    required this.assessmentCompleted,
    this.lastAssessmentAt,
    this.createdAt,
  });

  final String name;
  final String avatarId;
  final int age;
  final int heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final Set<Injury> injuries;
  final bool onboardingCompleted;
  final bool assessmentCompleted;
  final DateTime? lastAssessmentAt;
  final DateTime? createdAt;

  AvatarOption get avatar => AvatarOption.fromId(avatarId);

  bool get needsAssessment {
    if (!assessmentCompleted || lastAssessmentAt == null) return true;
    return DateTime.now().difference(lastAssessmentAt!).inDays >= 28;
  }

  UserProfile copyWith({
    String? name,
    String? avatarId,
    int? age,
    int? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    Set<Injury>? injuries,
    bool? onboardingCompleted,
    bool? assessmentCompleted,
    DateTime? lastAssessmentAt,
    DateTime? createdAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      injuries: injuries ?? this.injuries,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      assessmentCompleted: assessmentCompleted ?? this.assessmentCompleted,
      lastAssessmentAt: lastAssessmentAt ?? this.lastAssessmentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarId': avatarId,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'activityLevel': activityLevel.name,
        'injuries': injuries.map((e) => e.name).toList(),
        'onboardingCompleted': onboardingCompleted,
        'assessmentCompleted': assessmentCompleted,
        'lastAssessmentAt': lastAssessmentAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      avatarId: json['avatarId'] as String? ?? 'fox',
      age: json['age'] as int? ?? 25,
      heightCm: json['heightCm'] as int? ?? 170,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70,
      activityLevel: ActivityLevel.fromName(
        json['activityLevel'] as String? ?? 'beginner',
      ),
      injuries: {
        for (final i in (json['injuries'] as List<dynamic>? ?? const []))
          Injury.fromName(i as String),
      },
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      assessmentCompleted: json['assessmentCompleted'] as bool? ?? false,
      lastAssessmentAt: json['lastAssessmentAt'] != null
          ? DateTime.tryParse(json['lastAssessmentAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  static UserProfile empty() => UserProfile(
        name: '',
        avatarId: AvatarOption.fox.id,
        age: 25,
        heightCm: 170,
        weightKg: 70,
        activityLevel: ActivityLevel.beginner,
        injuries: {Injury.none},
        onboardingCompleted: false,
        assessmentCompleted: false,
        createdAt: DateTime.now(),
      );
}
