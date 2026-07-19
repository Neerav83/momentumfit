import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/services/input_limits.dart';
import '../../providers/app_providers.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  int _index = 0;
  bool _saving = false;
  final Map<String, int> _results = {};
  final _controller = TextEditingController();

  List<ExerciseDefinition> get _exercises => ExerciseLibrary.assessmentExercises;

  ExerciseDefinition get _current => _exercises[_index];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_saving || _index == 0) return;
    final previous = _exercises[_index - 1];
    final previousValue = _results[previous.id];
    setState(() {
      _index -= 1;
      _controller.text = previousValue?.toString() ?? '';
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  Future<void> _submitCurrent() async {
    if (_saving) return;

    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid number')),
      );
      return;
    }

    final max = _current.unit == ExerciseUnit.seconds
        ? InputLimits.maxSeconds
        : InputLimits.maxReps;
    if (value > max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Max is $max for this exercise')),
      );
      return;
    }

    _results[_current.id] = value;

    if (_index < _exercises.length - 1) {
      final next = _exercises[_index + 1];
      final nextValue = _results[next.id];
      _controller.text = nextValue?.toString() ?? '';
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      setState(() => _index += 1);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(profileProvider.notifier).completeAssessment(_results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save assessment. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_index + 1) / _exercises.length;
    final unitLabel =
        _current.unit == ExerciseUnit.seconds ? 'Seconds' : 'Reps';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fitness check',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Instead of guessing what you can do — measure it. '
                'Take your time. Good form beats max effort.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.mist,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Exercise ${_index + 1} of ${_exercises.length}',
                child: Text(
                  'Exercise ${_index + 1} of ${_exercises.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          _current.name,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: AppColors.ink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _current.howTo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium,
                            decoration: InputDecoration(
                              labelText: unitLabel,
                              hintText: _current.unit == ExerciseUnit.seconds
                                  ? 'sec'
                                  : 'reps',
                            ),
                            onSubmitted: (_) => _submitCurrent(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  if (_index > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _goBack,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_index > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _saving ? null : _submitCurrent,
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _index == _exercises.length - 1
                                  ? 'Save & start'
                                  : 'Next exercise',
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
