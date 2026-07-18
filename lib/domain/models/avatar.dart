enum AvatarOption {
  fox(id: 'fox', emoji: '🦊', label: 'Fox'),
  bear(id: 'bear', emoji: '🐻', label: 'Bear'),
  owl(id: 'owl', emoji: '🦉', label: 'Owl'),
  rabbit(id: 'rabbit', emoji: '🐰', label: 'Rabbit'),
  tiger(id: 'tiger', emoji: '🐯', label: 'Tiger'),
  dolphin(id: 'dolphin', emoji: '🐬', label: 'Dolphin'),
  panda(id: 'panda', emoji: '🐼', label: 'Panda'),
  wolf(id: 'wolf', emoji: '🐺', label: 'Wolf');

  const AvatarOption({
    required this.id,
    required this.emoji,
    required this.label,
  });

  final String id;
  final String emoji;
  final String label;

  static AvatarOption fromId(String id) {
    return AvatarOption.values.firstWhere(
      (a) => a.id == id,
      orElse: () => AvatarOption.fox,
    );
  }
}
