import 'package:auth_session/auth_session.dart';
import 'package:backend_api/backend_api.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:collection_tracker/core/router/routes.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

enum AuthScreenMode { signIn, register }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({
    this.initialMode = AuthScreenMode.signIn,
    this.popOnSuccess = true,
    super.key,
  });

  final AuthScreenMode initialMode;
  final bool popOnSuccess;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  static final RegExp _passwordPolicyRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
  );

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  late bool _isRegisterMode;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isRegisterMode = widget.initialMode == AuthScreenMode.register;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessionAsync = ref.watch(authSessionProvider);
    final session = sessionAsync.value;
    final profileAsync = ref.watch(backendAuthProfileProvider);
    final service = ref.watch(backendAuthServiceProvider);
    final readiness = ref.watch(backendAuthReadinessProvider);
    final canAuthenticate = service != null;
    final isAuthenticated = session?.isAuthenticated ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authTitleAccount)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            if (sessionAsync.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (isAuthenticated)
              Column(
                children: [
                  AppReveal(
                    child: _AuthenticatedCard(
                      l10n: l10n,
                      session: session!,
                      profile: profileAsync.value,
                      isProfileLoading: profileAsync.isLoading,
                      isSubmitting: _isSubmitting,
                      onRequestAccountDeletion: _handleRequestAccountDeletion,
                      onSignOut: _handleSignOut,
                      onDone: () => _closeWithResult(true),
                    ),
                  ),
                ],
              )
            else if (!canAuthenticate)
              AppReveal(
                child: _AuthUnavailableCard(
                  l10n: l10n,
                  message: readiness.message,
                  onClose: () => _closeWithResult(false),
                ),
              )
            else
              Column(
                children: [
                  AppReveal(
                    child: _AuthHeaderCard(
                      l10n: l10n,
                      isRegisterMode: _isRegisterMode,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppReveal(
                    delay: AppMotion.stagger,
                    child: AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isRegisterMode
                                  ? l10n.authCreateAccountHeading
                                  : l10n.authSignInHeading,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _isRegisterMode
                                  ? l10n.authCreateAccountDescription
                                  : l10n.authSignInDescription,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              children: [
                                ChoiceChip(
                                  label: Text(l10n.authSignInChoice),
                                  selected: !_isRegisterMode,
                                  onSelected: _isSubmitting
                                      ? null
                                      : (selected) {
                                          if (!selected) return;
                                          setState(
                                            () => _isRegisterMode = false,
                                          );
                                        },
                                ),
                                ChoiceChip(
                                  label: Text(l10n.authRegisterChoice),
                                  selected: _isRegisterMode,
                                  onSelected: _isSubmitting
                                      ? null
                                      : (selected) {
                                          if (!selected) return;
                                          setState(
                                            () => _isRegisterMode = true,
                                          );
                                        },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppInput(
                              controller: _emailController,
                              labelText: l10n.authEmailLabel,
                              hintText: l10n.authEmailHint,
                              prefixIcon: const Icon(Icons.email_outlined),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                final text = (value ?? '').trim();
                                if (text.isEmpty) {
                                  return l10n.authEmailRequiredError;
                                }
                                if (!text.contains('@')) {
                                  return l10n.authEmailInvalidError;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppInput(
                              controller: _passwordController,
                              labelText: l10n.authPasswordLabel,
                              hintText: _isRegisterMode
                                  ? l10n.authPasswordHint
                                  : null,
                              prefixIcon: const Icon(Icons.lock_outline),
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              autocorrect: false,
                              enableSuggestions: false,
                              smartDashesType: SmartDashesType.disabled,
                              smartQuotesType: SmartQuotesType.disabled,
                              textInputAction: _isRegisterMode
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              validator: (value) {
                                final text = value ?? '';
                                if (text.isEmpty) {
                                  return l10n.authPasswordRequiredError;
                                }
                                if (text.length < 8) {
                                  return l10n.authPasswordLengthError;
                                }
                                if (!_passwordPolicyRegex.hasMatch(text)) {
                                  return l10n.authPasswordPolicyError;
                                }
                                return null;
                              },
                            ),
                            if (_isRegisterMode) ...[
                              const SizedBox(height: AppSpacing.sm),
                              AppInput(
                                controller: _displayNameController,
                                labelText: l10n.authDisplayNameLabel,
                                hintText: l10n.authDisplayNameHint,
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                ),
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: _isRegisterMode
                                  ? l10n.authCreateAccountAction
                                  : l10n.authSignInChoice,
                              isLoading: _isSubmitting,
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              expand: true,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppButton(
                              label: l10n.authNotNowAction,
                              variant: AppButtonVariant.ghost,
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _closeWithResult(false),
                              expand: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final l10n = context.l10n;
    final service = ref.read(backendAuthServiceProvider);
    if (service == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authUnavailableMessage)));
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();

    try {
      if (_isRegisterMode) {
        await service.register(
          email: email,
          password: password,
          displayName: displayName.isEmpty ? null : displayName,
        );
      } else {
        await service.signIn(email: email, password: password);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRegisterMode ? l10n.authRegisterSuccess : l10n.authSignInSuccess,
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.popOnSuccess && mounted) {
        _closeWithResult(true);
      }
    } on BackendApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyAuthError(error))));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authSignInFailed('$error'))));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    final l10n = context.l10n;
    setState(() => _isSubmitting = true);
    try {
      final service = ref.read(backendAuthServiceProvider);
      if (service != null) {
        await service.signOut();
      } else {
        await ref.read(authSessionStoreProvider).clearSession();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authSignedOut)));
      _closeWithResult(true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleRequestAccountDeletion() async {
    final l10n = context.l10n;
    final acknowledged = await _showDeletionImpactDialog();
    if (acknowledged != true) {
      return;
    }
    if (!mounted) {
      return;
    }

    final confirmed = await showAppDialog<bool>(
      context: context,
      title: Text(l10n.authFinalConfirmationTitle),
      content: Text(l10n.authFinalConfirmationMessage),
      actions: [
        AppButton(
          label: l10n.authBackAction,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: l10n.authSubmitRequestAction,
          variant: AppButtonVariant.danger,
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final service = ref.read(backendAuthServiceProvider);
      if (service == null) {
        throw BackendApiException(
          message: l10n.authUnavailableMessage,
          code: 'AUTH_UNAVAILABLE',
        );
      }

      await service.requestAccountDeletion(
        reason: 'User requested deletion from mobile app',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authDeletionRequestSubmitted),
          backgroundColor: Colors.green,
        ),
      );
      _closeWithResult(true);
    } on BackendApiException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.code == 'ACCOUNT_DELETION_ENDPOINT_NOT_FOUND'
          ? l10n.authDeletionEndpointMissing
          : _friendlyAuthError(error);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<bool?> _showDeletionImpactDialog() {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final warningBackground = colorScheme.errorContainer.withValues(
      alpha: colorScheme.brightness == Brightness.light ? 0.78 : 0.9,
    );
    final warningBorder = colorScheme.error.withValues(
      alpha: colorScheme.brightness == Brightness.light ? 0.35 : 0.48,
    );
    final warningTitle = colorScheme.onErrorContainer;
    final warningBody = colorScheme.onErrorContainer.withValues(alpha: 0.92);

    return showAppDialog<bool>(
      context: context,
      barrierDismissible: false,
      title: Text(l10n.authDeletionImpactDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.authDeletionImpactReviewPrompt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: warningBackground,
            borderColor: warningBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: warningTitle,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.authIrreversibleRequestTitle,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: warningTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _DeletionImpactLine(
                  color: warningBody,
                  text: l10n.authImpactLineSessionRevoked,
                ),
                const SizedBox(height: AppSpacing.xs),
                _DeletionImpactLine(
                  color: warningBody,
                  text: l10n.authImpactLineCloudDataDeleted,
                ),
                const SizedBox(height: AppSpacing.xs),
                _DeletionImpactLine(
                  color: warningBody,
                  text: l10n.authImpactLineCannotRestore,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: l10n.actionCancel,
          variant: AppButtonVariant.ghost,
          onPressed: () => closeAppDialog(context, false),
        ),
        AppButton(
          label: l10n.authUnderstandAction,
          variant: AppButtonVariant.danger,
          onPressed: () => closeAppDialog(context, true),
        ),
      ],
    );
  }

  void _closeWithResult(bool result) {
    if (!mounted) {
      return;
    }

    if (Navigator.of(context).canPop()) {
      context.pop(result);
      return;
    }

    context.go(Routes.settings);
  }

  String _friendlyAuthError(BackendApiException error) {
    final l10n = context.l10n;
    final message = error.message.trim();
    if (message.toLowerCase().contains('password must contain uppercase')) {
      return '$message ${l10n.authPasswordPolicySuffix}';
    }
    return message;
  }
}

class _AuthenticatedCard extends StatelessWidget {
  const _AuthenticatedCard({
    required this.l10n,
    required this.session,
    required this.profile,
    required this.isProfileLoading,
    required this.isSubmitting,
    required this.onRequestAccountDeletion,
    required this.onSignOut,
    required this.onDone,
  });

  final AppLocalizations l10n;
  final AuthSession session;
  final BackendAuthUser? profile;
  final bool isProfileLoading;
  final bool isSubmitting;
  final Future<void> Function() onRequestAccountDeletion;
  final Future<void> Function() onSignOut;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final warningBackground = colorScheme.errorContainer.withValues(
      alpha: colorScheme.brightness == Brightness.light ? 0.78 : 0.9,
    );
    final warningBorder = colorScheme.error.withValues(
      alpha: colorScheme.brightness == Brightness.light ? 0.35 : 0.48,
    );
    final warningTitle = colorScheme.onErrorContainer;
    final warningBody = colorScheme.onErrorContainer.withValues(alpha: 0.92);
    final titleText = profile?.displayName?.trim();
    final subtitleText = profile?.email.trim();

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.person_rounded),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (titleText == null || titleText.isEmpty)
                              ? l10n.authAccountConnected
                              : titleText,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (subtitleText == null || subtitleText.isEmpty)
                              ? l10n.authSignedInReadySubtitle
                              : subtitleText,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.authActiveStatus,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isProfileLoading) ...[
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  minHeight: 2,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.authSessionDetailsTitle,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MetaRow(
                icon: Icons.badge_outlined,
                label: l10n.authUserIdLabel,
                value: session.userId ?? l10n.authUnknownValue,
              ),
              const SizedBox(height: AppSpacing.xs),
              _MetaRow(
                icon: Icons.smartphone_outlined,
                label: l10n.authDeviceIdLabel,
                value: session.deviceId ?? l10n.authUnknownValue,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          color: warningBackground,
          borderColor: warningBorder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: warningTitle,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.authDeletionNoticeTitle,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: warningTitle,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.authDeletionNoticeSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: warningBody),
              ),
              const SizedBox(height: AppSpacing.xs),
              _DeletionImpactLine(
                color: warningBody,
                text: l10n.authDeletionNoticeLineProfileSessions,
              ),
              const SizedBox(height: AppSpacing.xs),
              _DeletionImpactLine(
                color: warningBody,
                text: l10n.authDeletionNoticeLineSyncedData,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              AppButton(
                label: l10n.authRequestDeletionAction,
                variant: AppButtonVariant.danger,
                isLoading: isSubmitting,
                onPressed: isSubmitting
                    ? null
                    : () => onRequestAccountDeletion(),
                expand: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.authSignOutAction,
                variant: AppButtonVariant.secondary,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : () => onSignOut(),
                expand: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.authDoneAction,
                variant: AppButtonVariant.ghost,
                onPressed: isSubmitting ? null : onDone,
                expand: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthHeaderCard extends StatelessWidget {
  const _AuthHeaderCard({required this.l10n, required this.isRegisterMode});

  final AppLocalizations l10n;
  final bool isRegisterMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  isRegisterMode
                      ? Icons.person_add_alt_1_rounded
                      : Icons.lock_open_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isRegisterMode
                      ? l10n.authHeaderCreateTitle
                      : l10n.authHeaderWelcomeTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isRegisterMode
                ? l10n.authHeaderCreateSubtitle
                : l10n.authHeaderSignInSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthUnavailableCard extends StatelessWidget {
  const _AuthUnavailableCard({
    required this.l10n,
    required this.message,
    required this.onClose,
  });

  final AppLocalizations l10n;
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_person_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.authUnavailableTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.authBackAction,
            variant: AppButtonVariant.ghost,
            onPressed: onClose,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DeletionImpactLine extends StatelessWidget {
  const _DeletionImpactLine({required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\u2022',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: resolvedColor),
          ),
        ),
      ],
    );
  }
}
