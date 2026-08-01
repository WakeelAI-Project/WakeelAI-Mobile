import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_state_provider.dart';

class EmployeeHomeScreen extends ConsumerWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to Wakeel AI!'),
      ),
    );
  }
}
