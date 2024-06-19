import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

import 'stub.dart';

/// Renders a web-only SIGN IN button.
Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return web.renderButton(configuration: web.GSIButtonConfiguration(text: web.GSIButtonText.signin, shape: web.GSIButtonShape.pill, type: web.GSIButtonType.icon, theme: web.GSIButtonTheme.filledBlack, size: web.GSIButtonSize.large));
}