import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/chat_result_card.dart';
import '../../application/chat_provider.dart';
import '../../../leaves/application/leave_request_service.dart';

class ResultCardRenderer extends ConsumerStatefulWidget {
  const ResultCardRenderer({super.key, required this.card, required this.messageId});

  final ChatResultCard card;
  final String messageId;

  @override
  ConsumerState<ResultCardRenderer> createState() => _ResultCardRendererState();
}

class _ResultCardRendererState extends ConsumerState<ResultCardRenderer> {
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _error;
  late bool _handled;

  @override
  void initState() {
    super.initState();
    _handled = widget.card.payload['handled'] == true;
    if (!_handled && widget.card.type == 'leave_draft') {
      final requestId = widget.card.payload['request_id'] as String?;
      if (requestId != null) {
        _isVerifying = true;
        _verifyDraftStatus(requestId);
      }
    }
  }

  Future<void> _verifyDraftStatus(String requestId) async {
    try {
      final isDraft = await ref.read(leaveRequestServiceProvider).isLeaveDraft(requestId);
      if (!isDraft) {
        if (mounted) {
          setState(() {
             _handled = true;
          });
        }
        ref.read(chatProvider.notifier).markCardAsHandled(widget.messageId);
      }
    } catch (e) {
      // Ignore verification errors; default to showing the actionable state.
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant ResultCardRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.payload['handled'] == true) {
      _handled = true;
    }
  }

  Future<void> _handleSubmitLeave(String requestId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(leaveRequestServiceProvider).submitLeaveDraft(requestId);
      setState(() {
        _handled = true;
      });
      ref.read(chatProvider.notifier).markCardAsHandled(widget.messageId);
      // Optionally notify chat state or show toast
    } catch (e) {
      setState(() {
        _error = 'Failed to submit request';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCancelLeave(String requestId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(leaveRequestServiceProvider).deleteLeaveDraft(requestId);
      setState(() {
        _handled = true;
      });
      ref.read(chatProvider.notifier).markCardAsHandled(widget.messageId);
    } catch (e) {
      setState(() {
        _error = 'Failed to cancel request';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.card.type == 'calculation') {
      return _buildCalculationCard(context);
    } else if (widget.card.type == 'leave_draft') {
      return _buildLeaveDraftCard(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCalculationCard(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final headline = widget.card.payload['headline'] as String? ?? '';
    final formula = widget.card.payload['formula'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        border: Border.all(color: colors.accent),
        borderRadius: BorderRadius.circular(12), // --radius-lg
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colors.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formula,
            style: AppTypography.mono().copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveDraftCard(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final requestId = widget.card.payload['request_id'] as String?;
    final days = widget.card.payload['days_requested']?.toString() ?? '0';

    if (requestId == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave Request Draft',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Days Requested: $days',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.red[800]), // Use status token properly in a real app
            ),
          ],
          const SizedBox(height: 16),
          if (_isVerifying)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (!_handled)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => _handleCancelLeave(requestId),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleSubmitLeave(requestId),
                    child: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text('Submit'),
                  ),
                ),
              ],
            )
          else
            Text(
              'Draft processed.',
              style: TextStyle(color: colors.textSecondary, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}
