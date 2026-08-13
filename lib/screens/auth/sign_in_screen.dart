import 'package:flutter/material.dart';

import '../../data/app_language.dart';
import '../../data/auth_service.dart';
import '../../data/strings.dart';
import '../../theme/app_colors.dart';

/// Sign-in, done the way Google does it: **one question per screen.**
///
/// Step 1 asks only for the email. Step 2 shows that email back and asks only
/// for the password. Two empty boxes at once is more intimidating for someone
/// who isn't confident with phones — one field is easier to face.
///
/// "Skip for now" is visible at every step, on purpose. Roughly half the target
/// farmers cannot manage an account, and the app must work fully without one.
/// Login exists so a farmer can get their history back on a new phone — nothing
/// more.
///
/// Email + password is live against Firebase: it creates a real account the
/// first time and checks the real password afterwards. Google sign-in is not
/// wired yet — it needs an extra security fingerprint step on Android.
class SignInScreen extends StatefulWidget {
  final AppLanguage language;

  const SignInScreen({super.key, required this.language});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  int _step = 0; // 0 = email, 1 = password
  String? _error;
  bool _obscure = true;
  bool _busy = false;

  String get _lang => widget.language.code;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Deliberately simple: has an @, has a dot after it, no spaces. Nothing
  /// stricter — over-clever email validation rejects real addresses, which is
  /// worse than letting a typo through.
  bool _looksLikeEmail(String v) {
    final t = v.trim();
    if (t.contains(' ') || !t.contains('@')) return false;
    final parts = t.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return false;
    return parts[1].contains('.') && !parts[1].endsWith('.');
  }

  void _nextFromEmail() {
    if (!_looksLikeEmail(_emailController.text)) {
      setState(() => _error = S.invalidEmail(_lang));
      return;
    }
    setState(() {
      _error = null;
      _step = 1;
    });
  }

  /// The real thing: signs in if the account exists, creates it if it doesn't.
  Future<void> _submitPassword() async {
    if (_passwordController.text.length < 6) {
      setState(() => _error = S.shortPassword(_lang));
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });

    final result = await AuthService.signInOrCreate(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case AuthResult.signedIn:
        _finish(S.welcomeBack(_lang));
      case AuthResult.created:
        _finish(S.accountCreated(_lang));
      case AuthResult.wrongPassword:
        setState(() => _error = S.wrongPassword(_lang));
      case AuthResult.weakPassword:
        setState(() => _error = S.shortPassword(_lang));
      case AuthResult.invalidEmail:
        setState(() {
          _error = S.invalidEmail(_lang);
          _step = 0;
        });
      case AuthResult.noInternet:
        setState(() => _error = S.noInternetAuth(_lang));
      case AuthResult.tooManyAttempts:
        setState(() => _error = S.tooManyTries(_lang));
      case AuthResult.unknown:
        setState(() => _error = S.somethingWrong(_lang));
    }
  }

  void _finish(String message) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Future<void> _forgotPassword() async {
    final ok = await AuthService.sendResetEmail(_emailController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? S.resetSent(_lang) : S.somethingWrong(_lang)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _notWiredYet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google sign-in comes next — email works now'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F5EA), Colors.white],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ---- Back ----
              // On step 2 this goes back to the email field, not out of the
              // screen. Same button, context-aware.
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        if (_step == 1) {
                          setState(() {
                            _step = 0;
                            _error = null;
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E9E3),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 21,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/branding/emblem.png',
                        height: 72,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      S.signInTitle(_lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      S.signInWhy(_lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: 12.5,
                        height: 1.45,
                        color: Color(0xFF7B877E),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // AnimatedSwitcher gives a soft crossfade between the two
                    // steps instead of the screen snapping.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _step == 0 ? _emailStep() : _passwordStep(),
                    ),
                  ],
                ),
              ),

              // ---- Continue + Skip, pinned to the bottom ----
              // Pinned on purpose: when the keyboard opens, Android lifts this
              // section above it. Previously Continue was inside the scrolling
              // list and the keyboard covered it — the user could type but not
              // submit, which is the worst kind of bug: nothing looks broken.
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: _continueButton(
                  _step == 0 ? _nextFromEmail : _submitPassword,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    S.skipForNow(_lang),
                    style: const TextStyle(
                      fontFamily: 'NotoSansDevanagari',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6F7C72),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Step 1: email ----------------

  Widget _emailStep() {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google first, because it is one tap and nothing to remember.
        SizedBox(
          height: 54,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFDCE6DE), width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _notWiredYet,
            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
            label: Text(
              S.withGoogle(_lang),
              style: const TextStyle(
                fontFamily: 'NotoSansDevanagari',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
        _orDivider(),
        const SizedBox(height: 20),

        Text(
          S.emailLabel(_lang),
          style: const TextStyle(
            fontFamily: 'NotoSansDevanagari',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _nextFromEmail(),
          decoration: _fieldStyle('name@example.com'),
        ),

        if (_error != null) _errorText(),
      ],
    );
  }

  // ---------------- Step 2: password ----------------

  Widget _passwordStep() {
    return Column(
      key: const ValueKey('password'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The email is shown back, with a way to correct it. Never trap someone
        // on a screen because they mistyped on the previous one.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE6EDE7), width: 1.3),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _emailController.text.trim(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _step = 0;
                  _error = null;
                }),
                child: Text(
                  S.changeEmail(_lang),
                  style: const TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        Text(
          S.passwordLabel(_lang),
          style: const TextStyle(
            fontFamily: 'NotoSansDevanagari',
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 9),

        // The warning goes ABOVE the field, not below it, and it is impossible
        // to miss. Shruti — who built this app — still asked whether to type her
        // Gmail password here. If the person who built it wasn't sure, a farmer
        // certainly won't be. Nobody reads small grey text under a field they
        // have already filled in.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3DFB4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_rounded,
                size: 18,
                color: Colors.orange.shade800,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  S.passwordHelp(_lang),
                  style: TextStyle(
                    fontFamily: 'NotoSansDevanagari',
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _obscure,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitPassword(),
          decoration: _fieldStyle('••••••').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
                color: const Color(0xFF9BA69E),
              ),
              // Let people see what they typed. Hiding it always is a common
              // cause of failed logins, especially on a phone keyboard.
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),

        if (_error != null) _errorText(),

        const SizedBox(height: 6),
        Center(
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text(
              S.forgotPassword(_lang),
              style: const TextStyle(
                fontFamily: 'NotoSansDevanagari',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Small shared pieces ----------------

  InputDecoration _fieldStyle(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFB4BEB7), fontSize: 14.5),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE0E9E2), width: 1.4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
    ),
  );

  Widget _errorText() => Padding(
    padding: const EdgeInsets.only(top: 8, left: 4),
    child: Text(
      _error!,
      style: TextStyle(
        fontFamily: 'NotoSansDevanagari',
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: Colors.red.shade700,
      ),
    ),
  );

  Widget _continueButton(VoidCallback onTap) => SizedBox(
    height: 54,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: const Color(0xFF7E9C88),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      // Disabled while waiting for Firebase, so an impatient double-tap can't
      // fire two sign-in attempts at once.
      onPressed: _busy ? null : onTap,
      child: _busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
          : Text(
              S.continueLabel(_lang),
              style: const TextStyle(
                fontFamily: 'NotoSansDevanagari',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    ),
  );

  Widget _orDivider() => Row(
    children: [
      const Expanded(child: Divider(color: Color(0xFFDCE6DE))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          S.orLabel(_lang),
          style: const TextStyle(
            fontFamily: 'NotoSansDevanagari',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9BA69E),
          ),
        ),
      ),
      const Expanded(child: Divider(color: Color(0xFFDCE6DE))),
    ],
  );
}
