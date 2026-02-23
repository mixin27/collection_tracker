import 'package:collection_tracker/features/loans/presentation/view_models/loan_tracking_view_model.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

class LoanTrackingScreen extends ConsumerStatefulWidget {
  const LoanTrackingScreen({super.key});

  @override
  ConsumerState<LoanTrackingScreen> createState() => _LoanTrackingScreenState();
}

class _LoanTrackingScreenState extends ConsumerState<LoanTrackingScreen> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeLoansProvider);
    final historyAsync = ref.watch(loanHistoryProvider);
    final loansAsync = _showHistory ? historyAsync : activeAsync;

    return Scaffold(
      appBar: AppBar(title: const Text('Loan Tracking')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'loan_tracking_fab',
        onPressed: () => _showCreateLoanSheet(context),
        icon: const Icon(Icons.handshake_outlined),
        label: const Text('New Loan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl * 2,
        ),
        children: [
          AppReveal(child: _LoanSummaryCard(activeAsync: activeAsync)),
          const SizedBox(height: AppSpacing.md),
          AppReveal(
            delay: AppMotion.stagger,
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  selected: !_showHistory,
                  label: const Text('Active'),
                  onSelected: (_) => setState(() => _showHistory = false),
                ),
                ChoiceChip(
                  selected: _showHistory,
                  label: const Text('History'),
                  onSelected: (_) => setState(() => _showHistory = true),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppReveal(
            delay: AppMotion.stagger * 2,
            child: AppAnimatedSwitcher(
              child: loansAsync.when(
                data: (loans) {
                  if (loans.isEmpty) {
                    return EmptyState(
                      key: ValueKey(
                        _showHistory ? 'history-empty' : 'active-empty',
                      ),
                      icon: _showHistory
                          ? Icons.history_toggle_off_rounded
                          : Icons.inventory_2_outlined,
                      title: _showHistory
                          ? 'No returned loans yet'
                          : 'No active loans',
                      message: _showHistory
                          ? 'Returned items will appear here.'
                          : 'Create a loan to start tracking borrowed items.',
                    );
                  }

                  return Column(
                    key: ValueKey(
                      _showHistory ? 'history-list' : 'active-list',
                    ),
                    children: [
                      for (var i = 0; i < loans.length; i++) ...[
                        _LoanCard(
                          loan: loans[i],
                          showHistoryMeta: _showHistory,
                          onReturn: loans[i].isActive
                              ? () => _markReturned(context, loans[i])
                              : null,
                          onDelete: () => _deleteLoan(context, loans[i]),
                        ),
                        if (i < loans.length - 1)
                          const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xxl),
                  child: LoadingView(message: 'Loading loans...'),
                ),
                error: (error, _) => ErrorView(
                  message: 'Failed to load loans: $error',
                  onRetry: () {
                    ref.invalidate(activeLoansProvider);
                    ref.invalidate(loanHistoryProvider);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateLoanSheet(BuildContext context) async {
    await showAppSheet(
      context: context,
      builder: (_) => const _CreateLoanSheet(),
    );
  }

  Future<void> _markReturned(BuildContext context, LoanRecord loan) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: const Text('Mark as returned?'),
      content: Text('Confirm return for "${loan.itemTitle}".'),
      actions: [
        AppButton(
          label: context.l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: 'Mark Returned',
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(markLoanReturnedProvider(loanId: loan.id).future);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loan marked as returned.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark return: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteLoan(BuildContext context, LoanRecord loan) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: const Text('Delete loan record?'),
      content: Text('Delete loan record for "${loan.itemTitle}".'),
      actions: [
        AppButton(
          label: context.l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: context.l10n.actionDelete,
          variant: AppButtonVariant.danger,
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(deleteLoanProvider(loanId: loan.id).future);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loan deleted.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete loan: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _LoanSummaryCard extends StatelessWidget {
  const _LoanSummaryCard({required this.activeAsync});

  final AsyncValue<List<LoanRecord>> activeAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: activeAsync.when(
        data: (activeLoans) {
          final overdueCount = activeLoans
              .where((loan) => loan.isOverdue)
              .length;

          return Row(
            children: [
              Expanded(
                child: _StatPill(
                  icon: Icons.inventory_2_outlined,
                  label: 'Active Loans',
                  value: '${activeLoans.length}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatPill(
                  icon: Icons.warning_amber_rounded,
                  label: 'Overdue',
                  value: '$overdueCount',
                  tint: overdueCount > 0
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 74,
          child: Center(child: LoadingView(indicatorSize: 30)),
        ),
        error: (_, _) => const Text('Unable to load loan summary.'),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tint ?? colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({
    required this.loan,
    required this.showHistoryMeta,
    required this.onDelete,
    this.onReturn,
  });

  final LoanRecord loan;
  final bool showHistoryMeta;
  final VoidCallback onDelete;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  loan.itemTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _LoanStatusBadge(loan: loan),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            loan.collectionName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _LoanMetaRow(
            icon: Icons.person_outline_rounded,
            label: 'Borrower',
            value: loan.borrowerName,
          ),
          if (loan.borrowerContact != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _LoanMetaRow(
              icon: Icons.call_outlined,
              label: 'Contact',
              value: loan.borrowerContact!,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          _LoanMetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'Loaned',
            value: _formatDate(context, loan.loanedAt),
          ),
          if (loan.dueAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _LoanMetaRow(
              icon: Icons.event_available_outlined,
              label: 'Due',
              value: _formatDate(context, loan.dueAt!),
              valueColor: loan.isOverdue
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
            ),
          ],
          if (showHistoryMeta && loan.returnedAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _LoanMetaRow(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Returned',
              value: _formatDate(context, loan.returnedAt!),
            ),
          ],
          if (loan.notes != null && loan.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              loan.notes!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (onReturn != null)
                AppButton(
                  label: 'Mark Returned',
                  variant: AppButtonVariant.secondary,
                  onPressed: onReturn,
                ),
              AppButton(
                label: context.l10n.actionDelete,
                variant: AppButtonVariant.ghost,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).format(date);
  }
}

class _LoanMetaRow extends StatelessWidget {
  const _LoanMetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 15, color: colors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoanStatusBadge extends StatelessWidget {
  const _LoanStatusBadge({required this.loan});

  final LoanRecord loan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    late final Color background;
    late final Color foreground;
    late final String label;

    if (loan.isReturned) {
      background = colorScheme.primary.withValues(alpha: 0.14);
      foreground = colorScheme.primary;
      label = 'Returned';
    } else if (loan.isOverdue) {
      background = colorScheme.error.withValues(alpha: 0.14);
      foreground = colorScheme.error;
      label = 'Overdue';
    } else {
      background = colorScheme.tertiary.withValues(alpha: 0.14);
      foreground = colorScheme.tertiary;
      label = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CreateLoanSheet extends ConsumerStatefulWidget {
  const _CreateLoanSheet();

  @override
  ConsumerState<_CreateLoanSheet> createState() => _CreateLoanSheetState();
}

class _CreateLoanSheetState extends ConsumerState<_CreateLoanSheet> {
  final TextEditingController _borrowerController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedItemId;
  DateTime? _dueDate;
  bool _submitting = false;

  @override
  void dispose() {
    _borrowerController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidatesAsync = ref.watch(loanCandidateItemsProvider);
    final activeLoans =
        ref.watch(activeLoansProvider).asData?.value ?? const <LoanRecord>[];

    return AnimatedPadding(
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: candidatesAsync.when(
            data: (allCandidates) {
              final activeItemIds = activeLoans
                  .map((loan) => loan.itemId)
                  .toSet();
              final candidates = allCandidates
                  .where(
                    (candidate) => !activeItemIds.contains(candidate.item.id),
                  )
                  .toList(growable: false);

              final selectedStillValid =
                  _selectedItemId != null &&
                  candidates.any(
                    (candidate) => candidate.item.id == _selectedItemId,
                  );
              if (!selectedStillValid) {
                _selectedItemId = candidates.isEmpty
                    ? null
                    : candidates.first.item.id;
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Loan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Track who borrowed an item and when it should be returned.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (candidates.isEmpty)
                      EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No available items',
                        message:
                            'All items are currently loaned or there are no items yet.',
                      )
                    else
                      DropdownButtonFormField<String>(
                        key: ValueKey(_selectedItemId),
                        initialValue: _selectedItemId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Item'),
                        items: candidates
                            .map(
                              (candidate) => DropdownMenuItem<String>(
                                value: candidate.item.id,
                                child: Text(
                                  candidate.displayLabel,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _submitting
                            ? null
                            : (value) =>
                                  setState(() => _selectedItemId = value),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    AppInput(
                      controller: _borrowerController,
                      labelText: 'Borrower name',
                      hintText: 'e.g. John Doe',
                      enabled: !_submitting && candidates.isNotEmpty,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppInput(
                      controller: _contactController,
                      labelText: 'Contact (optional)',
                      hintText: 'Phone, email, or @username',
                      enabled: !_submitting && candidates.isNotEmpty,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DueDateField(
                      dueDate: _dueDate,
                      enabled: !_submitting && candidates.isNotEmpty,
                      onPick: () => _pickDueDate(context),
                      onClear: _dueDate == null
                          ? null
                          : () => setState(() => _dueDate = null),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppInput(
                      controller: _notesController,
                      labelText: 'Notes (optional)',
                      hintText: 'Extra details for this loan',
                      maxLines: 3,
                      enabled: !_submitting && candidates.isNotEmpty,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: _submitting ? 'Creating...' : 'Create Loan',
                      onPressed: (_submitting || candidates.isEmpty)
                          ? null
                          : () => _submit(context),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: context.l10n.actionCancel,
                      variant: AppButtonVariant.ghost,
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(
              height: 180,
              child: LoadingView(message: 'Loading items...'),
            ),
            error: (error, _) => ErrorView(
              message: 'Failed to load items: $error',
              onRetry: () => ref.invalidate(loanCandidateItemsProvider),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(picked.year, picked.month, picked.day, 12);
      });
    }
  }

  Future<void> _submit(BuildContext context) async {
    final itemId = _selectedItemId;
    if (itemId == null || itemId.isEmpty) {
      return;
    }

    final borrowerName = _borrowerController.text.trim();
    if (borrowerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Borrower name is required.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await ref
          .read(
            createLoanProvider(
              itemId: itemId,
              borrowerName: borrowerName,
              borrowerContact: _contactController.text,
              notes: _notesController.text,
              dueAt: _dueDate,
            ).future,
          )
          .then((_) {
            ref.invalidate(activeLoansProvider);
            ref.invalidate(loanHistoryProvider);
            ref.invalidate(loanCandidateItemsProvider);
          });

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan created successfully.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create loan: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _DueDateField extends StatelessWidget {
  const _DueDateField({
    required this.dueDate,
    required this.enabled,
    required this.onPick,
    this.onClear,
  });

  final DateTime? dueDate;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = dueDate == null
        ? 'No due date'
        : DateFormat.yMMMd(locale).format(dueDate!);

    final controls = <Widget>[
      AppButton(
        label: 'Pick',
        variant: AppButtonVariant.secondary,
        onPressed: enabled ? onPick : null,
      ),
      if (dueDate != null)
        AppButton(
          label: 'Clear',
          variant: AppButtonVariant.ghost,
          onPressed: enabled ? onClear : null,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final dateField = Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Due date', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateField,
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: controls,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: dateField),
            const SizedBox(width: AppSpacing.sm),
            for (final button in controls)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: button,
              ),
          ],
        );
      },
    );
  }
}
