// lib/widgets/custom_button.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

enum ButtonStyle {
  filled,
  outlined,
  text,
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final ButtonStyle style;
  final double? width;
  final double height;
  final bool disabled;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.style = ButtonStyle.filled,
    this.width,
    this.height = 56,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on style
    Color backgroundColor;
    Color textColor;

    switch (style) {
      case ButtonStyle.filled:
        backgroundColor = disabled
            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
            : Theme.of(context).colorScheme.primary;
        textColor = Theme.of(context).colorScheme.onPrimary;
        break;
      case ButtonStyle.outlined:
        backgroundColor = Colors.transparent;
        textColor = disabled
            ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
            : Theme.of(context).colorScheme.primary;
        break;
      case ButtonStyle.text:
        backgroundColor = Colors.transparent;
        textColor = disabled
            ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
            : Theme.of(context).colorScheme.primary;
        break;
    }

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: style == ButtonStyle.filled && !disabled
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: disabled || isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: style != ButtonStyle.filled
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: style == ButtonStyle.outlined
                  ? Border.all(
                      color: disabled
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                          : Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          style == ButtonStyle.filled
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: textColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Example Usage:
/*
CustomButton(
  onPressed: () {
    // Action
  },
  text: 'Continue',
),

CustomButton(
  onPressed: () {
    // Action
  },
  text: 'Cancel',
  style: ButtonStyle.outlined,
),

CustomButton(
  onPressed: () {
    // Action
  },
  text: 'Add to Cart',
  icon: Icons.shopping_cart,
),
*/