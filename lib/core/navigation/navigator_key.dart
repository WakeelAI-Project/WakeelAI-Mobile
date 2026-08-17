import 'package:flutter/material.dart';

/// Shared with [GoRouter] so code with no [BuildContext] of its own — like
/// the Dio auth interceptor — can still show UI (dialogs, snackbars) over
/// whatever screen the user is currently on.
final rootNavigatorKey = GlobalKey<NavigatorState>();
