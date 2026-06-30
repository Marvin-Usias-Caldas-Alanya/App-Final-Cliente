import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design.dart';
import '../../../shared/widgets/confianza_logo.dart';
import '../viewmodels/auth_viewmodel.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authViewModelProvider.notifier).signIn(
          context,
          dni: _dniController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.paddingOf(context).top + 32,
              24,
              48,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue,
                  AppColors.secondaryBlue,
                  AppColors.aqua,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const ConfianzaLogo(),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: AppDesign.cardDecoration,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Iniciar sesión',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ingresa tu DNI',
                          style: TextStyle(
                            color: AppColors.darkText.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _dniController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'DNI',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingrese su DNI';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su contraseña';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 28),
                        if (state.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Ingresar'),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: AppColors.darkText.withValues(alpha: 0.45),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tus datos están protegidos',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkText.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
