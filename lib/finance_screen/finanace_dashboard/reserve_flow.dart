
import 'package:flutter/material.dart';
import '../../repository/reserve_repository.dart';
import 'reserve.dart';


class ReserveFlow extends StatefulWidget {
  const ReserveFlow({super.key});

  @override
  State<ReserveFlow> createState() => _ReserveFlowState();
}

class _ReserveFlowState extends State<ReserveFlow> {
  int  _step    = 0;
  bool _loading = false;
  final ReserveState _state = ReserveState();

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _next() => _step < 2 ? setState(() => _step++) : _submit();
  void _back() { if (_step > 0) setState(() => _step--); }
  void _rebuild() => setState(() {}); // propagate child mutations upward

  // ── Submission ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() => _loading = true);

    final result = await ReserveApiService.createReserve(_state);

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case ApiSuccess():
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SuccessScreen(payload: _state.toJson()),
          ),
        );
      case ApiFailure(:final message):
        _showErrorDialog(message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Submission Failed',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors2.navyBtn,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors2.cream,
        body: Center(
          child: CircularProgressIndicator(color: AppColors2.navyBtn),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _step,
        children: [
          Screen1(state: _state, onNext: _next, onBack: _back, onChange: _rebuild),
          Screen2(state: _state, onNext: _next, onBack: _back, onChange: _rebuild),
          Screen3(state: _state, onNext: _next, onBack: _back, onChange: _rebuild),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED SCAFFOLD  — header + scrollable body + action button + bottom nav
// ═══════════════════════════════════════════════════════════════════════════════

class ReserveScaffold extends StatelessWidget {
  final int          step;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final Widget       body;
  final String       nextLabel;

  const ReserveScaffold({
    super.key,
    required this.step,
    required this.onBack,
    required this.onNext,
    required this.body,
    this.nextLabel = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors2.cream,
      body: Column(
        children: [
          _AppHeader(step: step, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: body,
            ),
          ),
          _ActionButton(label: nextLabel, onTap: onNext),
         
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared layout sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  final int          step;
  final VoidCallback onBack;
  const _AppHeader({required this.step, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors2.header,
      padding: EdgeInsets.only(
        top:    MediaQuery.of(context).padding.top + 8,
        left:   16,
        right:  16,
        bottom: 16,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          // Title
          const Expanded(
            child: Text(
              'Reserve',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Step badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$step of 3',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String       label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors2.navyBtn,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}



class Screen1 extends StatelessWidget {
  final ReserveState state;
  final VoidCallback onNext, onBack, onChange;

  const Screen1({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return ReserveScaffold(
      step: 1,
      onBack: onBack,
      onNext: onNext,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ScreenTitle('What are you reserving for?'),
          _ScreenSubtitle(
            'Pick what this Reserve is about. Stakeplot\nwill watch only these categories.',
          ),
          const SizedBox(height: 24),
          _CategoryList(state: state, onChange: onChange),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final ReserveState state;
  final VoidCallback onChange;
  const _CategoryList({required this.state, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(kReserveCategories.length, (i) {
          return _CategoryRow(
            category:   kReserveCategories[i],
            isSelected: state.selectedCategories.contains(i),
            isLast:     i == kReserveCategories.length - 1,
            onTap: () {
              state.selectedCategories.contains(i)
                  ? state.selectedCategories.remove(i)
                  : state.selectedCategories.add(i);
              onChange();
            },
          );
        }),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final ReserveCategory category;
  final bool            isSelected;
  final bool            isLast;
  final VoidCallback    onTap;

  const _CategoryRow({
    required this.category,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors2.divider),
                ),
        ),
        child: Row(
          children: [
            _IconBox(category.icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors2.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors2.textMid,
                    ),
                  ),
                ],
              ),
            ),
            _Checkbox(selected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool selected;
  const _Checkbox({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22, height: 22,
      decoration: BoxDecoration(
        color: selected ? AppColors2.navyBtn : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? AppColors2.navyBtn : AppColors2.inputBorder,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 2 — Set your amount and duration
// ═══════════════════════════════════════════════════════════════════════════════

class Screen2 extends StatefulWidget {
  final ReserveState state;
  final VoidCallback onNext, onBack, onChange;

  const Screen2({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
    required this.onChange,
  });

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.state.amount.toStringAsFixed(2),
    );
    _amountCtrl.addListener(() {
      final v = double.tryParse(_amountCtrl.text);
      if (v != null) widget.state.amount = v;
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReserveScaffold(
      step: 2,
      onBack: widget.onBack,
      onNext: widget.onNext,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ScreenTitle('Set your amount and duration'),
          _ScreenSubtitle(
            'Stakeplot suggests a limit based on your\nactual spending history.',
          ),
          const SizedBox(height: 28),
          _SuggestedChip(),
          const SizedBox(height: 14),
          _AmountInput(controller: _amountCtrl),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Set days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors2.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DaySelector(
            selected: widget.state.selectedDay,
            onChanged: (day) {
              setState(() => widget.state.selectedDay = day);
              widget.onChange();
            },
          ),
        ],
      ),
    );
  }
}

class _SuggestedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors2.inputBorder),
      ),
      child: const Text(
        'Suggested Amount    ₹ 6700.34',
        style: TextStyle(fontSize: 13, color: AppColors2.textMid),
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  final TextEditingController controller;
  const _AmountInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors2.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors2.textDark,
        ),
        decoration: const InputDecoration(
          prefixText: '₹ ',
          prefixStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors2.textDark,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final int                 selected;
  final ValueChanged<int>   onChanged;
  const _DaySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSelected = selected == day;
        return GestureDetector(
          onTap: () => onChanged(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors2.navyBtn : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors2.navyBtn : AppColors2.inputBorder,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors2.textMid,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 3 — Set up guardrails
// ═══════════════════════════════════════════════════════════════════════════════

class Screen3 extends StatefulWidget {
  final ReserveState state;
  final VoidCallback onNext, onBack, onChange;

  const Screen3({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
    required this.onChange,
  });

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  bool _pickerOpen = false;

  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minCtrl;
  late final FixedExtentScrollController _periodCtrl;

  @override
  void initState() {
    super.initState();
    _hourCtrl   = FixedExtentScrollController(
      initialItem: widget.state.reminderHour - 1,
    );
    _minCtrl    = FixedExtentScrollController(
      initialItem: widget.state.reminderMinute ~/ 5,
    );
    _periodCtrl = FixedExtentScrollController(
      initialItem: widget.state.reminderPeriod == 'AM' ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ReserveScaffold(
      step: 3,
      onBack: widget.onBack,
      onNext: widget.onNext,
      nextLabel: 'Submit',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ScreenTitle('Set up guardrails'),
          _ScreenSubtitle(
            'These help you in the real moment — not\njust on the dashboard.',
          ),
          const SizedBox(height: 28),

          // ── Notify at % ────────────────────────────────────────────────
          _GuardrailCard(
            child: _NotifySlider(
              value: widget.state.notifyPercent,
              label: widget.state.notifyLabel,
              onChanged: (v) {
                widget.state.notifyPercent = v;
                widget.onChange();
                _rebuild();
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Reminder + inline scroll picker ────────────────────────────
          _GuardrailCard(
            child: _ReminderPicker(
              timeLabel:   widget.state.reminderTimeLabel,
              pickerOpen:  _pickerOpen,
              onToggle:    () => setState(() => _pickerOpen = !_pickerOpen),
              hourCtrl:    _hourCtrl,
              minCtrl:     _minCtrl,
              periodCtrl:  _periodCtrl,
              onHourChanged: (i) {
                widget.state.reminderHour = i + 1;
                widget.onChange(); _rebuild();
              },
              onMinChanged: (i) {
                widget.state.reminderMinute = i * 5;
                widget.onChange(); _rebuild();
              },
              onPeriodChanged: (i) {
                widget.state.reminderPeriod = i == 0 ? 'AM' : 'PM';
                widget.onChange(); _rebuild();
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Partner reserve ─────────────────────────────────────────────
          _GuardrailCard(
            child: _ToggleRow(
              icon:      Icons.people_outlined,
              label:     'Partner reserve',
              value:     widget.state.partnerReserve,
              onChanged: (v) {
                widget.state.partnerReserve = v;
                widget.onChange(); _rebuild();
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Reserve widget ──────────────────────────────────────────────
          _GuardrailCard(
            child: _ToggleRow(
              icon:      Icons.widgets_outlined,
              label:     'Reserve widget',
              value:     widget.state.reserveWidget,
              onChanged: (v) {
                widget.state.reserveWidget = v;
                widget.onChange(); _rebuild();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Screen 3 sub-widgets ─────────────────────────────────────────────────────

class _NotifySlider extends StatelessWidget {
  final double          value;
  final String          label;
  final ValueChanged<double> onChanged;

  const _NotifySlider({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _IconBox(Icons.notifications_outlined),
            const SizedBox(width: 12),
            const Text(
              'Get notified at',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors2.textDark,
              ),
            ),
            const Spacer(),
            _Badge(label),
          ],
        ),
        const SizedBox(height: 14),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight:        4,
            thumbShape:         const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape:       const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor:   AppColors2.accent,
            inactiveTrackColor: AppColors2.sliderTrack,
            thumbColor:         AppColors2.accent,
            overlayColor:       AppColors2.accent.withOpacity(0.15),
          ),
          child: Slider(
            value: value, min: 0.1, max: 1.0, divisions: 9,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['10%','20%','40%','60%','80%','100%']
              .map((e) => Text(
                    e,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors2.textLight,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ReminderPicker extends StatelessWidget {
  final String                       timeLabel;
  final bool                         pickerOpen;
  final VoidCallback                 onToggle;
  final FixedExtentScrollController  hourCtrl;
  final FixedExtentScrollController  minCtrl;
  final FixedExtentScrollController  periodCtrl;
  final ValueChanged<int>            onHourChanged;
  final ValueChanged<int>            onMinChanged;
  final ValueChanged<int>            onPeriodChanged;

  const _ReminderPicker({
    required this.timeLabel,
    required this.pickerOpen,
    required this.onToggle,
    required this.hourCtrl,
    required this.minCtrl,
    required this.periodCtrl,
    required this.onHourChanged,
    required this.onMinChanged,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tappable header ─────────────────────────────────────────────
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              _IconBox(Icons.alarm_outlined),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminder',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors2.textDark,
                    ),
                  ),
                  Text(
                    'Daily reminder at',
                    style: TextStyle(fontSize: 12, color: AppColors2.textMid),
                  ),
                ],
              ),
              const Spacer(),
              // Time chip — turns navy when open
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: pickerOpen ? AppColors2.navyBtn : AppColors2.cream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: pickerOpen
                        ? AppColors2.navyBtn
                        : AppColors2.inputBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: pickerOpen ? Colors.white : AppColors2.textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: pickerOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: pickerOpen ? Colors.white : AppColors2.textMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Expanding scroll-wheel drums ────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: pickerOpen
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild:  const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors2.divider),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    Expanded(
                      child: _WheelDrum(
                        controller: hourCtrl,
                        items: List.generate(
                          12, (i) => (i + 1).toString().padLeft(2, '0'),
                        ),
                        onChanged: onHourChanged,
                      ),
                    ),
                    const _DrumSeparator(),
                    Expanded(
                      child: _WheelDrum(
                        controller: minCtrl,
                        items: List.generate(
                          12, (i) => (i * 5).toString().padLeft(2, '0'),
                        ),
                        onChanged: onMinChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 62,
                      child: _WheelDrum(
                        controller: periodCtrl,
                        items: const ['AM', 'PM'],
                        onChanged: onPeriodChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrumSeparator extends StatelessWidget {
  const _DrumSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors2.textDark,
        ),
      ),
    );
  }
}

/// Single scroll-wheel drum column with selection highlight + fade.
class _WheelDrum extends StatelessWidget {
  final FixedExtentScrollController controller;
  final List<String>                 items;
  final ValueChanged<int>            onChanged;

  const _WheelDrum({
    required this.controller,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Selection band
        Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors2.accent.withOpacity(0.09),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        // Wheel
        ListWheelScrollView.useDelegate(
          controller:         controller,
          itemExtent:         44,
          diameterRatio:      1.6,
          perspective:        0.004,
          physics:            const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: items.length,
            builder: (_, i) => Center(
              child: Text(
                items[i],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors2.textDark,
                ),
              ),
            ),
          ),
        ),
        // Top & bottom fade
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.white.withOpacity(0.9),
                ],
                stops: const [0.0, 0.28, 0.72, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData           icon;
  final String             label;
  final bool               value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(icon),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors2.textDark,
          ),
        ),
        const Spacer(),
        _StyledSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUCCESS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> payload;
  const SuccessScreen({super.key, required this.payload});

  static String _formatKey(String k) => k
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors2.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _SuccessIcon(),
              const SizedBox(height: 24),
              const Text(
                'Reserve Created!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors2.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your reserve has been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors2.textMid),
              ),
              const SizedBox(height: 32),
              _PayloadSummaryCard(payload: payload, formatKey: _formatKey),
              const Spacer(),
              _DoneButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: AppColors2.navyBtn,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors2.navyBtn.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 42),
    );
  }
}

class _PayloadSummaryCard extends StatelessWidget {
  final Map<String, dynamic>     payload;
  final String Function(String)  formatKey;

  const _PayloadSummaryCard({
    required this.payload,
    required this.formatKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUBMITTED PAYLOAD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors2.textLight,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          ...payload.entries.map(
            (e) => _PayloadRow(
              label: formatKey(e.key),
              value: e.value is List
                  ? (e.value as List).join(', ')
                  : e.value.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayloadRow extends StatelessWidget {
  final String label, value;
  const _PayloadRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 144,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors2.textMid),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors2.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ReserveFlow()),
          (_) => false,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors2.navyBtn,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Done',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIMITIVE DESIGN ATOMS  (used across multiple screens)
// ═══════════════════════════════════════════════════════════════════════════════

/// Cream-background icon container used in guardrail rows.
class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox(this.icon);

  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: AppColors2.cream,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 18, color: AppColors2.accent),
  );
}

/// Navy pill badge used to show the selected notify %.
class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors2.navyBtn,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// White card wrapper with subtle shadow used for guardrail sections.
class _GuardrailCard extends StatelessWidget {
  final Widget child;
  const _GuardrailCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

/// Custom animated iOS-style toggle switch.
class _StyledSwitch extends StatelessWidget {
  final bool               value;
  final ValueChanged<bool> onChanged;
  const _StyledSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48, height: 28,
        decoration: BoxDecoration(
          color: value ? AppColors2.toggleOn : AppColors2.toggleOff,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22, height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Centred screen title — shared across all 3 screens.
class _ScreenTitle extends StatelessWidget {
  final String text;
  const _ScreenTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors2.textDark,
    ),
  );
}

/// Centred screen subtitle — shared across all 3 screens.
class _ScreenSubtitle extends StatelessWidget {
  final String text;
  const _ScreenSubtitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors2.textMid,
        height: 1.5,
      ),
    ),
  );
}