import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/collections/create_collection_pages/create_collection_flow.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/email_sync/custom_steps.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../Constants/colors.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../controllers/credit_card_controller.dart';
import '../finance_screen/Budgets/Budget.dart';
import '../finance_screen/finanace_dashboard/creditCard_slider.dart';
import 'add_credit_card_bank.dart';

RxBool loadingBankdetails = false.obs;

// Steps shown to the user during data fetch
const List<Map<String, dynamic>> _loadingSteps = [
  {
    'icon': Icons.mail_outline_rounded,
    'title': 'Connecting to Gmail',
    'subtitle': 'Securely accessing your inbox…',
    'color': Color(0xFF4285F4),
  },
  {
    'icon': Icons.search_rounded,
    'title': 'Scanning Emails',
    'subtitle': 'Looking for credit card statements…',
    'color': Color(0xFF37344F),
  },
  {
    'icon': Icons.receipt_long_rounded,
    'title': 'Reading Transactions',
    'subtitle': 'Extracting payment details & amounts…',
    'color': Color(0xFF0F9D58),
  },
  {
    'icon': Icons.credit_card_rounded,
    'title': 'Organising Cards',
    'subtitle': 'Matching statements to your banks…',
    'color': Color(0xFFF4B400),
  },
  {
    'icon': Icons.lock_rounded,
    'title': 'Securing Your Data',
    'subtitle': 'Encrypting & saving securely…',
    'color': Color(0xFFDB4437),
  },
];

class GettingDataScreen extends StatefulWidget {
  @override
  State<GettingDataScreen> createState() => _GettingDataScreenState();
}

class _GettingDataScreenState extends State<GettingDataScreen>
    with TickerProviderStateMixin {
  late AnimationController _stepAnimController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _pulseAnim;

  int _currentStep = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    // Step-change fade+slide animation
    _stepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _stepAnimController,
      curve: Curves.easeInOut,
    );
    _slideAnim = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _stepAnimController, curve: Curves.easeOut),
    );

    // Pulsing glow on the icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _stepAnimController.forward();
    _startStepCycle();

    loadingBankdetails.value = false;
    cardController.LinkBankData(context);

    // Watch for completion
    ever(loadingBankdetails, (bool done) {
      if (done && mounted) {
        _onFinished();
      }
    });
  }

  void _startStepCycle() {
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted || _finished) return;
      _advanceStep();
    });
  }

  void _advanceStep() {
    final nextStep = _currentStep + 1;
    if (nextStep >= _loadingSteps.length) return;

    _stepAnimController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentStep = nextStep);
      _progressController.animateTo(
        (nextStep + 1) / _loadingSteps.length,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
      _stepAnimController.forward();
      _startStepCycle();
    });
  }

  void _onFinished() {
    setState(() => _finished = true);
    _pulseController.stop();
    _progressController.animateTo(1.0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    pushnameToRoute(context, CardDueCarousel());
  }

  @override
  void dispose() {
    _stepAnimController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final step = _loadingSteps[_currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: AppSizes.h30),
              CustomStepper(activeStep: 2),

              // ── Lottie / success icon ──────────────────────────────────
              SizedBox(
                height: h * 0.28,
                width: w,
                child: _finished
                    ? _buildSuccessIcon()
                    : Lottie.asset(
                        'assets/splashScreen/login_email.json',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.email_rounded,
                          size: 80,
                          color: Color(0xFF37344F),
                        ),
                      ),
              ),

              const SizedBox(height: 8),

              // ── Animated step card ─────────────────────────────────────
              AnimatedBuilder(
                animation: _stepAnimController,
                builder: (_, child) => Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: child,
                  ),
                ),
                child: _finished ? _buildDoneCard(w) : _buildStepCard(step, w),
              ),

              SizedBox(height: AppSizes.h20),

              // ── Progress bar ───────────────────────────────────────────
              _buildProgressBar(w),

              SizedBox(height: AppSizes.h14),

              // ── Step counter ───────────────────────────────────────────
              if (!_finished)
                Text(
                  'Step ${_currentStep + 1} of ${_loadingSteps.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.4,
                  ),
                ),

              // const Spacer(),

              SizedBox(height: AppSizes.h40),
              // ── Done button ────────────────────────────────────────────
              Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: loadingBankdetails.value
                      ? _buildDoneButton(context, w)
                      : _buildWaitingHint(),
                ),
              ),

              SizedBox(height: AppSizes.h40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildStepCard(Map<String, dynamic> step, double w) {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          // Pulsing icon container
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (step['color'] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                step['icon'] as IconData,
                color: step['color'] as Color,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF37344F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // Animated dots
          _AnimatedDots(),
        ],
      ),
    );
  }

  Widget _buildDoneCard(double w) {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF2E7D32), size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All done!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your credit card data is ready to view.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF388E3C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (_, __) => LinearProgressIndicator(
              value: _finished ? 1.0 : _progressController.value,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _finished ? const Color(0xFF4CAF50) : const Color(0xFF37344F),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (_, v, __) => Transform.scale(
        scale: v,
        child: const Icon(
          Icons.check_circle_rounded,
          size: 100,
          color: Color(0xFF4CAF50),
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context, double w) {
    return SizedBox(
      width: w * 0.6,
      height: 50,
      child: ElevatedButton(
        onPressed: () => pushnameToRoute(context, CardDueCarousel()),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF37344F),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('View My Cards',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingHint() {
    return Column(
      children: [
        // const SizedBox(
        //   width: 24,
        //   height: 24,
        //   child: CircularProgressIndicator(
        //     strokeWidth: 2.5,
        //     valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF37344F)),
        //   ),
        // ),
        SpinKitCircle(
          color: AppColors.primaryColor,
          size: 30,
        ),
        const SizedBox(height: 10),
        Text(
          'This may take up to 30-40 seconds…',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

/// Animated three-dot indicator
class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _dot = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          if (mounted) setState(() => _dot = (_dot + 1) % 3);
          _ctrl.forward(from: 0);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _dot ? const Color(0xFF37344F) : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
}
