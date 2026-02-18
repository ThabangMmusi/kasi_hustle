import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_state.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileInitial || state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = state is ProfileLoaded
            ? state.profile
            : (state as ProfileUpdating).profile;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: colorScheme.surface,
                elevation: 0,
                leading: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCF7F2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Ionicons.arrow_back,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Clean Background
                      Container(color: colorScheme.surface),
                      // Balance Card
                      Positioned(
                        bottom: 20,
                        left: Insets.lg,
                        right: Insets.lg,
                        child: Container(
                          padding: EdgeInsets.all(Insets.xl),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: Corners.lgBorder,
                            boxShadow: Shadows.universal,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Ionicons.wallet,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        size: 20,
                                      ),
                                      HSpace.sm,
                                      Text(
                                        'kasi',
                                        style: TextStyles.titleSmall.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        ' money',
                                        style: TextStyles.titleSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Insets.sm,
                                      vertical: Insets.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.8,
                                      ),
                                      borderRadius: Corners.xsBorder,
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: TextStyles.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              VSpace.lg,
                              Text(
                                'R 2,453.00',
                                style: TextStyles.headlineLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              VSpace.xxs,
                              Text(
                                'Available credit to withdraw',
                                style: TextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              VSpace.lg,
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCardAction(
                                      label: 'Withdraw',
                                      icon: Ionicons.arrow_up_circle_outline,
                                      onTap: () {
                                        // TODO: Implement withdrawal
                                      },
                                      colorScheme: colorScheme,
                                    ),
                                  ),
                                  HSpace.med,
                                  Expanded(
                                    child: _buildCardAction(
                                      label: 'Link Account',
                                      icon: Ionicons.card_outline,
                                      onTap: () => context.pushNamed(
                                        'editBankDetails',
                                        extra: profile,
                                      ),
                                      colorScheme: colorScheme,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VSpace.med,
                      _buildSectionTitle('Bank Details'),
                      VSpace.med,
                      _buildBankCard(context, profile),
                      VSpace.xl,
                      _buildSectionTitle('Recent Transactions'),
                      VSpace.med,
                      _buildTransactionItem(
                        title: 'Payment from Thabang',
                        date: 'Today',
                        amount: '+ R 450.00',
                        isCredit: true,
                      ),
                      _buildTransactionItem(
                        title: 'Withdrawal to FNB',
                        date: 'Yesterday',
                        amount: '- R 1,200.00',
                        isCredit: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardAction({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Corners.smBorder,
        child: Container(
          padding: EdgeInsets.all(Insets.med),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF7F2),
            borderRadius: Corners.smBorder,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyles.labelLarge.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              HSpace.sm,
              Icon(icon, size: 16, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBankCard(BuildContext context, dynamic profile) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasBankDetails = profile.bankName != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF7F2),
        borderRadius: Corners.medBorder,
        border: Border.all(color: colorScheme.outline.withValues(alpha: .1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Ionicons.business_outline,
                color: colorScheme.primary,
                size: IconSizes.med,
              ),
              HSpace.med,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasBankDetails ? profile.bankName! : 'No bank linked',
                      style: TextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasBankDetails) ...[
                      VSpace.xs,
                      Text(
                        '**** ${profile.accountNumber!.substring(profile.accountNumber!.length > 4 ? profile.accountNumber!.length - 4 : 0)}',
                        style: TextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String date,
    required String amount,
    required bool isCredit,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: Insets.med),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Insets.sm),
            decoration: BoxDecoration(
              color: (isCredit ? Colors.green : Colors.red).withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Ionicons.arrow_down : Ionicons.arrow_up,
              color: isCredit ? Colors.green : Colors.red,
              size: IconSizes.sm,
            ),
          ),
          HSpace.med,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
