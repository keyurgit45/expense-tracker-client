import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/injection.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/auth_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: Scaffold(
        backgroundColor: ColorConstants.bgPrimary,
        appBar: AppBar(
          backgroundColor: ColorConstants.bgPrimary,
          title: Text(
            'Settings',
            style: GoogleFonts.inter(
              color: ColorConstants.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: ColorConstants.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          elevation: 0,
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 24),
                
                // AI Chat Section
                _buildSectionHeader('AI Chat'),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: ColorConstants.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      AuthSection(authState: state),
                      if (state is Authenticated) ...[
                        const Divider(
                          color: ColorConstants.divider,
                          height: 1,
                        ),
                        _buildSettingItem(
                          icon: Icons.history,
                          title: 'Chat History',
                          onTap: () => context.push('/chat/sessions'),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // App Settings Section
                _buildSectionHeader('App Settings'),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: ColorConstants.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: Icons.category_outlined,
                        title: 'Categories',
                        onTap: () => context.push('/categories'),
                      ),
                      const Divider(
                        color: ColorConstants.divider,
                        height: 1,
                      ),
                      _buildSettingItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {},
                      ),
                      const Divider(
                        color: ColorConstants.divider,
                        height: 1,
                      ),
                      _buildSettingItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: ColorConstants.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: ColorConstants.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  color: ColorConstants.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: ColorConstants.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}