import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/domain/employee_profile.dart';
import '../../application/profile_photo_controller.dart';
import 'full_screen_photo_viewer.dart';
import 'profile_photo_sheet.dart';

/// The employee's avatar (photo or initials) with a small edit-pen badge.
/// Tapping the photo itself opens a full-screen view; tapping the pen opens
/// the "Add Profile Photo" bottom sheet.
class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.radius = 40,
  });

  final String? photoUrl;
  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final resolvedUrl = resolvePhotoUrl(photoUrl);
    final isBusy = ref.watch(profilePhotoControllerProvider).isLoading;

    return SizedBox(
      width: radius * 2 + 8,
      height: radius * 2 + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: resolvedUrl == null
                ? null
                : () => Navigator.of(context).push(FullScreenPhotoViewer.route(resolvedUrl)),
            child: resolvedUrl == null
                ? _InitialsCircle(initials: initials, radius: radius, colors: colors)
                : ClipOval(
                    child: SizedBox(
                      width: radius * 2,
                      height: radius * 2,
                      child: Image.network(
                        resolvedUrl,
                        fit: BoxFit.cover,
                        // A broken/unreachable photo URL falls back to the initials
                        // circle rather than the framework's default red error box.
                        errorBuilder: (context, error, stackTrace) =>
                            _InitialsCircle(initials: initials, radius: radius, colors: colors),
                      ),
                    ),
                  ),
          ),
          if (isBusy)
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.bgCard),
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: GestureDetector(
              onTap: isBusy ? null : () => showProfilePhotoSheet(context, ref, hasPhoto: resolvedUrl != null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.brandPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.bgCard, width: 2),
                ),
                child: Icon(LucideIcons.pencil, size: 14, color: colors.onBrandPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({required this.initials, required this.radius, required this.colors});

  final String initials;
  final double radius;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.textPrimary,
      child: Text(
        initials,
        style: AppTypography.text2xl(false).copyWith(
              color: colors.bgCard,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
