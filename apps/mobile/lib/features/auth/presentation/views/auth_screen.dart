import 'package:auth_session/auth_session.dart';
import 'package:backend_api/backend_api.dart';
import 'package:collection_tracker/core/providers/providers.dart';
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
    final sessionAsync = ref.watch(authSessionProvider);
    final session = sessionAsync.value;
    final service = ref.watch(backendAuthServiceProvider);
    final readiness = ref.watch(backendAuthReadinessProvider);
    final canAuthenticate = service != null;
    final isAuthenticated = session?.isAuthenticated ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
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
              AppReveal(
                child: _AuthenticatedCard(
                  session: session!,
                  isSubmitting: _isSubmitting,
                  onSignOut: _handleSignOut,
                  onDone: () => context.pop(true),
                ),
              )
            else if (!canAuthenticate)
              AppReveal(
                child: _AuthUnavailableCard(
                  message: readiness.message,
                  onClose: () => context.pop(false),
                ),
              )
            else
              AppReveal(
                child: AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isRegisterMode ? 'Create Account' : 'Sign In',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Sign in to enable cloud sync features.',
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
                              label: const Text('Sign in'),
                              selected: !_isRegisterMode,
                              onSelected: _isSubmitting
                                  ? null
                                  : (selected) {
                                      if (!selected) return;
                                      setState(() => _isRegisterMode = false);
                                    },
                            ),
                            ChoiceChip(
                              label: const Text('Register'),
                              selected: _isRegisterMode,
                              onSelected: _isSubmitting
                                  ? null
                                  : (selected) {
                                      if (!selected) return;
                                      setState(() => _isRegisterMode = true);
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppInput(
                          controller: _emailController,
                          labelText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) {
                              return 'Email is required.';
                            }
                            if (!text.contains('@')) {
                              return 'Enter a valid email.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppInput(
                          controller: _passwordController,
                          labelText: 'Password',
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
                              return 'Password is required.';
                            }
                            if (text.length < 8) {
                              return 'Password must be at least 8 characters.';
                            }
                            if (!_passwordPolicyRegex.hasMatch(text)) {
                              return 'Password must include uppercase, lowercase, and number.';
                            }
                            return null;
                          },
                        ),
                        if (_isRegisterMode) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AppInput(
                            controller: _displayNameController,
                            labelText: 'Display Name (optional)',
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: _isRegisterMode ? 'Create account' : 'Sign in',
                          isLoading: _isSubmitting,
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          expand: true,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: 'Not now',
                          variant: AppButtonVariant.ghost,
                          onPressed: _isSubmitting
                              ? null
                              : () => context.pop(false),
                          expand: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final service = ref.read(backendAuthServiceProvider);
    if (service == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication is currently unavailable.'),
        ),
      );
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
            _isRegisterMode
                ? 'Account created and signed in.'
                : 'Signed in successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.popOnSuccess && mounted) {
        context.pop(true);
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
      ).showSnackBar(SnackBar(content: Text('Sign-in failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
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
      ).showSnackBar(const SnackBar(content: Text('Signed out.')));
      context.pop(true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _friendlyAuthError(BackendApiException error) {
    final message = error.message.trim();
    if (message.toLowerCase().contains('password must contain uppercase')) {
      return '$message Use English keyboard letters and digits (A-Z, a-z, 0-9).';
    }
    return message;
  }
}

class _AuthenticatedCard extends StatelessWidget {
  const _AuthenticatedCard({
    required this.session,
    required this.isSubmitting,
    required this.onSignOut,
    required this.onDone,
  });

  final AuthSession session;
  final bool isSubmitting;
  final Future<void> Function() onSignOut;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Signed in',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You can now use cloud sync features.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MetaRow(label: 'User ID', value: session.userId ?? 'Unknown'),
          const SizedBox(height: AppSpacing.xs),
          _MetaRow(label: 'Device ID', value: session.deviceId ?? 'Unknown'),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.danger,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : () => onSignOut(),
            expand: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Done',
            variant: AppButtonVariant.ghost,
            onPressed: isSubmitting ? null : onDone,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _AuthUnavailableCard extends StatelessWidget {
  const _AuthUnavailableCard({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Authentication unavailable',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
            label: 'Back',
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
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
