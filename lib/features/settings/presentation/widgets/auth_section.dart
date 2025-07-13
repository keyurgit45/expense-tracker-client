import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AuthSection extends StatefulWidget {
  final AuthState authState;
  
  const AuthSection({
    super.key,
    required this.authState,
  });

  @override
  State<AuthSection> createState() => _AuthSectionState();
}

class _AuthSectionState extends State<AuthSection> {
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.authState is Authenticated) {
      final user = (widget.authState as Authenticated).user;
      return _buildAuthenticatedView(user.email);
    }
    
    if (widget.authState is AuthLoading) {
      return _buildLoadingView();
    }
    
    return _buildUnauthenticatedView();
  }

  Widget _buildAuthenticatedView(String email) {
    return InkWell(
      onTap: () => _showLogoutDialog(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorConstants.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ColorConstants.borderDefault,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.account_circle,
                color: ColorConstants.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signed in as',
                    style: GoogleFonts.inter(
                      color: ColorConstants.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      color: ColorConstants.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Sign out',
              style: GoogleFonts.inter(
                color: ColorConstants.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: CircularProgressIndicator(
          color: ColorConstants.primary,
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton('Sign In', !_isSignUp),
              const SizedBox(width: 16),
              _buildTabButton('Sign Up', _isSignUp),
            ],
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  style: GoogleFonts.inter(
                    color: ColorConstants.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: GoogleFonts.inter(
                      color: ColorConstants.textTertiary,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: ColorConstants.bgPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(
                    color: ColorConstants.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: GoogleFonts.inter(
                      color: ColorConstants.textTertiary,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: ColorConstants.bgPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: ColorConstants.textTertiary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                if (widget.authState is AuthError) ...[
                  const SizedBox(height: 12),
                  Text(
                    (widget.authState as AuthError).message,
                    style: GoogleFonts.inter(
                      color: ColorConstants.error,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.surface3,
                      foregroundColor: ColorConstants.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: ColorConstants.borderStrong,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      _isSignUp ? 'Create Account' : 'Sign In',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Connect to Gemini AI for expense insights',
              style: GoogleFonts.inter(
                color: ColorConstants.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSignUp = label == 'Sign Up';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? ColorConstants.surface3
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? ColorConstants.borderStrong
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isActive
                ? ColorConstants.textPrimary
                : ColorConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleAuth() {
    if (_formKey.currentState!.validate()) {
      final authCubit = context.read<AuthCubit>();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isSignUp) {
        authCubit.signUpUser(email, password);
      } else {
        authCubit.loginUser(email, password);
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorConstants.bgSecondary,
        title: Text(
          'Sign Out',
          style: GoogleFonts.inter(
            color: ColorConstants.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.inter(
            color: ColorConstants.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: ColorConstants.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logoutUser();
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.inter(
                color: ColorConstants.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}