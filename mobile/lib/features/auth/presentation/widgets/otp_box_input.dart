import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpBoxInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final TextEditingController? controller;
  final bool enabled;

  const OtpBoxInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.hasError = false,
    this.controller,
    this.enabled = true,
  });

  @override
  State<OtpBoxInput> createState() => _OtpBoxInputState();
}

class _OtpBoxInputState extends State<OtpBoxInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (i) => TextEditingController());
    _focusNodes = List.generate(widget.length, (i) => FocusNode());

    for (final node in _focusNodes) {
      node.addListener(() {
        if (mounted) setState(() {});
      });
    }

    if (widget.controller != null && widget.controller!.text.isNotEmpty) {
      _distributeText(widget.controller!.text);
    }
  }

  void _distributeText(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 0; i < widget.length; i++) {
      if (i < clean.length) {
        _controllers[i].text = clean[i];
      } else {
        _controllers[i].text = '';
      }
    }
    _notifyChange();
  }

  void _notifyChange() {
    final code = _controllers.map((c) => c.text).join();
    if (widget.controller != null && widget.controller!.text != code) {
      widget.controller!.text = code;
    }
    widget.onChanged(code);
    if (code.length == widget.length && widget.onCompleted != null) {
      widget.onCompleted!(code);
    }
  }

  void _onFieldChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      // Multi-digit entered or pasted
      for (int i = 0; i < digits.length && (index + i) < widget.length; i++) {
        _controllers[index + i].text = digits[i];
      }
      final nextIndex = (index + digits.length).clamp(0, widget.length - 1);
      _focusNodes[nextIndex].requestFocus();
      _notifyChange();
      return;
    }

    if (digits.length == 1) {
      _controllers[index].text = digits;
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      _controllers[index].text = '';
    }

    _notifyChange();
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].text = '';
        _notifyChange();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    final errorColor = theme.colorScheme.error;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = (widget.length - 1) * 8.0;
        final maxBoxWidth = ((constraints.maxWidth - totalSpacing) / widget.length).clamp(38.0, 52.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (index) {
            final isFocused = _focusNodes[index].hasFocus;
            final isFilled = _controllers[index].text.isNotEmpty;

            Color borderColor;
            if (widget.hasError) {
              borderColor = errorColor;
            } else if (isFocused) {
              borderColor = primaryColor;
            } else if (isFilled) {
              borderColor = primaryColor.withValues(alpha: 0.5);
            } else {
              borderColor = isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFD0D7D1);
            }

            Color fillColor;
            if (isDark) {
              fillColor = isFocused ? const Color(0xFF263328) : const Color(0xFF1E2420);
            } else {
              fillColor = isFocused ? const Color(0xFFE8F5E9) : const Color(0xFFF7FAF7);
            }

            return SizedBox(
              width: maxBoxWidth,
              height: 56,
              child: KeyboardListener(
                focusNode: _focusNodes[index],
                onKeyEvent: (event) => _onKeyEvent(index, event),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: borderColor,
                      width: isFocused || widget.hasError ? 2.0 : 1.2,
                    ),
                    boxShadow: isFocused
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controllers[index],
                      enabled: widget.enabled,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1B2E1D),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(widget.length),
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) => _onFieldChanged(index, value),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
