import 'dart:async';
import 'package:flutter/material.dart';

class AuthCountdownTimer extends StatefulWidget {
  final int initialSeconds;
  final Future<void> Function() onResend;
  final bool isLoading;
  final bool autoStart;

  const AuthCountdownTimer({
    super.key,
    this.initialSeconds = 60,
    required this.onResend,
    this.isLoading = false,
    this.autoStart = false,
  });

  @override
  State<AuthCountdownTimer> createState() => _AuthCountdownTimerState();
}

class _AuthCountdownTimerState extends State<AuthCountdownTimer> {
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      _remainingSeconds = widget.initialSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _remainingSeconds = 0;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    if (_remainingSeconds > 0 || _isResending || widget.isLoading) return;

    setState(() {
      _isResending = true;
    });

    try {
      await widget.onResend();
      if (!mounted) return;
      setState(() {
        _remainingSeconds = widget.initialSeconds;
        _isResending = false;
      });
      _startTimer();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);

    final isClickable = _remainingSeconds == 0 && !_isResending && !widget.isLoading;

    final minutes = _remainingSeconds ~/ 60;
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          "Didn't receive the code? ",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.grey[400] : const Color(0xFF616161),
          ),
        ),
        if (_remainingSeconds > 0)
          Text(
            'Resend in $minutes:$seconds',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          TextButton(
            onPressed: isClickable ? _handleResend : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: _isResending || widget.isLoading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  )
                : Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
      ],
    );
  }
}
