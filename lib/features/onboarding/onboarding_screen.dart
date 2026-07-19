import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/avatar.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/user_profile.dart';
import '../../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  String _name = '';
  AvatarOption _avatar = AvatarOption.fox;
  int _age = 28;
  int _heightCm = 175;
  double _weightKg = 75;
  ActivityLevel _activity = ActivityLevel.beginner;
  final Set<Injury> _injuries = {Injury.none};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final injuries = _injuries.contains(Injury.none)
        ? {Injury.none}
        : _injuries.where((i) => i != Injury.none).toSet();

    final profile = UserProfile(
      name: _name.trim().isEmpty ? 'Friend' : _name.trim(),
      avatarId: _avatar.id,
      age: _age,
      heightCm: _heightCm,
      weightKg: _weightKg,
      activityLevel: _activity,
      injuries: injuries,
      onboardingCompleted: true,
      assessmentCompleted: false,
      createdAt: DateTime.now(),
    );

    await ref.read(profileProvider.notifier).completeOnboarding(profile);
  }

  bool get _canContinue {
    if (_page == 0) return _name.trim().isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.forestDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appTagline,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _StepDots(current: _page, total: 4),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(
                    name: _name,
                    avatar: _avatar,
                    onNameChanged: (v) => setState(() => _name = v),
                    onAvatarChanged: (a) => setState(() => _avatar = a),
                  ),
                  _BodyPage(
                    age: _age,
                    heightCm: _heightCm,
                    weightKg: _weightKg,
                    onAge: (v) => setState(() => _age = v),
                    onHeight: (v) => setState(() => _heightCm = v),
                    onWeight: (v) => setState(() => _weightKg = v),
                  ),
                  _ActivityPage(
                    activity: _activity,
                    onChanged: (v) => setState(() => _activity = v),
                  ),
                  _InjuriesPage(
                    selected: _injuries,
                    onToggle: (injury) {
                      setState(() {
                        if (injury == Injury.none) {
                          _injuries
                            ..clear()
                            ..add(Injury.none);
                          return;
                        }
                        _injuries.remove(Injury.none);
                        if (_injuries.contains(injury)) {
                          _injuries.remove(injury);
                        } else {
                          _injuries.add(injury);
                        }
                        if (_injuries.isEmpty) {
                          _injuries.add(Injury.none);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  if (_page > 0)
                      Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        child: Text(l10n.back),
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _canContinue ? _next : null,
                      child: Text(_page == 3 ? l10n.continue : l10n.next),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.stepOfTotal(current + 1, total),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            height: 4,
            width: active ? 28 : 12,
            decoration: BoxDecoration(
              color: active ? AppColors.forest : AppColors.mist,
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }
}

class _WelcomePage extends StatefulWidget {
  const _WelcomePage({
    required this.name,
    required this.avatar,
    required this.onNameChanged,
    required this.onAvatarChanged,
  });

  final String name;
  final AvatarOption avatar;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<AvatarOption> onAvatarChanged;

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(covariant _WelcomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != _nameController.text) {
      _nameController.text = widget.name;
      _nameController.selection = TextSelection.collapsed(
        offset: widget.name.length,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      children: [
        Text('Who’s training?', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Pick an avatar and tell us what to call you.',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your name',
            hintText: 'Alex',
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: widget.onNameChanged,
        ),
        const SizedBox(height: 28),
        Text(l10n.chooseYourAvatar, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (final option in AvatarOption.values)
              _AvatarTile(
                option: option,
                selected: option == widget.avatar,
                onTap: () => widget.onAvatarChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final AvatarOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      child: Material(
        color: selected ? AppColors.mist : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.forest : AppColors.mist,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(option.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  option.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected ? AppColors.forestDark : AppColors.muted,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyPage extends StatelessWidget {
  const _BodyPage({
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.onAge,
    required this.onHeight,
    required this.onWeight,
  });

  final int age;
  final int heightCm;
  final double weightKg;
  final ValueChanged<int> onAge;
  final ValueChanged<int> onHeight;
  final ValueChanged<double> onWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      children: [
        Text(l10n.aFewBasics, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.aFewBasicsSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 28),
        _SliderRow(
          label: l10n.age,
          valueLabel: '$age',
          value: age.toDouble(),
          min: 13,
          max: 80,
          onChanged: (v) => onAge(v.round()),
        ),
        const SizedBox(height: 20),
        _SliderRow(
          label: l10n.height,
          valueLabel: l10n.heightCm(heightCm),
          value: heightCm.toDouble(),
          min: 140,
          max: 220,
          onChanged: (v) => onHeight(v.round()),
        ),
        const SizedBox(height: 20),
        _SliderRow(
          label: l10n.weight,
          valueLabel: l10n.weightKg(weightKg.round()),
          value: weightKg,
          min: 40,
          max: 160,
          onChanged: onWeight,
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(
              valueLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.forestDark,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppColors.forest,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ActivityPage extends StatelessWidget {
  const _ActivityPage({
    required this.activity,
    required this.onChanged,
  });

  final ActivityLevel activity;
  final ValueChanged<ActivityLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      children: [
        Text('How active are you?', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'We’ll start easier than you think — on purpose.',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        for (final level in ActivityLevel.values) ...[
          _SelectTile(
            title: level.label,
            subtitle: level.description,
            selected: activity == level,
            onTap: () => onChanged(level),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _InjuriesPage extends StatelessWidget {
  const _InjuriesPage({
    required this.selected,
    required this.onToggle,
  });

  final Set<Injury> selected;
  final ValueChanged<Injury> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      children: [
        Text('Anything to avoid?', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Optional. We’ll skip exercises that stress these areas.',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        for (final injury in Injury.values) ...[
          _SelectTile(
            title: injury.label,
            subtitle: injury == Injury.none
                ? 'No limitations'
                : 'Adapt workouts around this',
            selected: selected.contains(injury),
            onTap: () => onToggle(injury),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.mist : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.forest : AppColors.mist,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.forest : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
