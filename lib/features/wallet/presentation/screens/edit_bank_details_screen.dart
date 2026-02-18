import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/buttons.dart';
import 'package:kasi_hustle/core/widgets/styled_text_input.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_event.dart';

class EditBankDetailsScreen extends StatefulWidget {
  final UserProfile profile;

  const EditBankDetailsScreen({super.key, required this.profile});

  @override
  State<EditBankDetailsScreen> createState() => _EditBankDetailsScreenState();
}

class _EditBankDetailsScreenState extends State<EditBankDetailsScreen> {
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _accountTypeController;
  late TextEditingController _branchCodeController;
  late TextEditingController _accountHolderController;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController(
      text: widget.profile.bankName ?? '',
    );
    _accountNumberController = TextEditingController(
      text: widget.profile.accountNumber ?? '',
    );
    _accountTypeController = TextEditingController(
      text: widget.profile.accountType ?? '',
    );
    _branchCodeController = TextEditingController(
      text: widget.profile.branchCode ?? '',
    );
    _accountHolderController = TextEditingController(
      text: widget.profile.accountHolder ?? '',
    );
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountTypeController.dispose();
    _branchCodeController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Bank Details',
          style: TextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                Ionicons.close,
                color: colorScheme.onSurface,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Insets.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StyledTextInput(
                    controller: _accountHolderController,
                    label: 'Account Holder',
                    hintText: 'Enter account holder name',
                    autoFocus: true,
                  ),
                  VSpace.lg,
                  StyledTextInput(
                    controller: _bankNameController,
                    label: 'Bank Name',
                    hintText: 'e.g. FNB, Standard Bank, Capitec',
                  ),
                  VSpace.lg,
                  StyledTextInput(
                    controller: _accountNumberController,
                    label: 'Account Number',
                    hintText: 'Enter account number',
                    keyboardType: TextInputType.number,
                  ),
                  VSpace.lg,
                  StyledTextInput(
                    controller: _accountTypeController,
                    label: 'Account Type',
                    hintText: 'e.g. Savings, Cheque',
                  ),
                  VSpace.lg,
                  StyledTextInput(
                    controller: _branchCodeController,
                    label: 'Branch Code',
                    hintText: 'Enter branch code',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(
              Insets.lg,
            ).copyWith(bottom: bottomPadding + Insets.med + keyboardPadding),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryBtn(
                onPressed: () {
                  final updatedProfile = widget.profile.copyWith(
                    bankName: _bankNameController.text.trim().isEmpty
                        ? null
                        : _bankNameController.text.trim(),
                    accountNumber: _accountNumberController.text.trim().isEmpty
                        ? null
                        : _accountNumberController.text.trim(),
                    accountType: _accountTypeController.text.trim().isEmpty
                        ? null
                        : _accountTypeController.text.trim(),
                    branchCode: _branchCodeController.text.trim().isEmpty
                        ? null
                        : _branchCodeController.text.trim(),
                    accountHolder: _accountHolderController.text.trim().isEmpty
                        ? null
                        : _accountHolderController.text.trim(),
                  );

                  if (updatedProfile != widget.profile) {
                    context.read<ProfileBloc>().add(
                      UpdateProfile(profile: updatedProfile),
                    );
                  }
                  context.pop();
                },
                label: 'Save Details',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
