import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/profile_photo_controller.dart';

const _maxPhotoBytes = 5 * 1024 * 1024;

/// The "Add Profile Photo" bottom sheet — take a photo, choose from the
/// gallery, or (when a photo already exists) remove it.
Future<void> showProfilePhotoSheet(
  BuildContext context,
  WidgetRef ref, {
  required bool hasPhoto,
}) {
  final colors = Theme.of(context).extension<AppColors>()!;
  final l10n = AppLocalizations.of(context)!;
  final isArabic = l10n.localeName == 'ar';

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.bgCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                decoration: BoxDecoration(color: colors.borderDefault, borderRadius: AppRadius.fullRadius),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.profilePhotoSheetTitle,
                    style: AppTypography.textLg(isArabic).copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              ListTile(
                leading: Icon(LucideIcons.camera, color: colors.textPrimary),
                title: Text(l10n.profilePhotoTakePhoto, style: AppTypography.textBase(isArabic).copyWith(color: colors.textPrimary)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickCropAndUpload(context, ref, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.image, color: colors.textPrimary),
                title: Text(l10n.profilePhotoChooseFromGallery,
                    style: AppTypography.textBase(isArabic).copyWith(color: colors.textPrimary)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickCropAndUpload(context, ref, ImageSource.gallery);
                },
              ),
              if (hasPhoto)
                ListTile(
                  leading: Icon(LucideIcons.trash2, color: colors.errorFg),
                  title: Text(l10n.profilePhotoRemove, style: AppTypography.textBase(isArabic).copyWith(color: colors.errorFg)),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final ok = await ref.read(profilePhotoControllerProvider.notifier).removePhoto();
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profilePhotoRemoveError)));
                    }
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _pickCropAndUpload(BuildContext context, WidgetRef ref, ImageSource source) async {
  final l10n = AppLocalizations.of(context)!;

  final picked = await ImagePicker().pickImage(source: source, imageQuality: 90);
  if (picked == null) return;

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 85,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: l10n.profilePhotoCropTitle,
        cropStyle: CropStyle.circle,
        aspectRatioPresets: const [CropAspectRatioPreset.square],
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: l10n.profilePhotoCropTitle,
        cropStyle: CropStyle.circle,
        aspectRatioLockEnabled: true,
        aspectRatioPickerButtonHidden: true,
      ),
    ],
  );
  if (cropped == null) return;

  final file = File(cropped.path);
  if (await file.length() > _maxPhotoBytes) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profilePhotoTooLarge)));
    }
    return;
  }

  final ok = await ref.read(profilePhotoControllerProvider.notifier).uploadPhoto(file);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profilePhotoUploadError)));
  }
}
