import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';

/// Botón "Continuar con Google" de login y registro. Los errores llegan al
/// usuario por `AppController.feedbackMessage`.
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key, this.height = 55});

  final double height;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    // Si entra, el redirect del router lleva al garage.
    final ok = await context.read<AppController>().handleGoogleSignIn();
    if (!ok && mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: OutlinedButton(
        onPressed: _loading ? null : _signIn,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.textPrimary,
          side: BorderSide(color: context.dividerColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _loading
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.textPrimary,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle_outlined, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Continuar con Google',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
