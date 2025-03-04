import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../common/enum/card_type.dart';
import '../../../common/widgets/material_you_app_bar_widget.dart';
import '../../../data/accounts/model/account.dart';
import '../../../di/service_locator.dart';
import '../bloc/accounts_bloc.dart';
import '../widgets/account_card.dart';
import '../widgets/card_type_drop_down.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({
    Key? key,
    this.accountId,
  }) : super(key: key);

  final String? accountId;

  @override
  AddAccountPageState createState() => AddAccountPageState();
}

class AddAccountPageState extends State<AddAccountPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  late final AccountsBloc accountsBloc = locator.get()
    ..add(FetchAccountFromIdEvent(widget.accountId));
  late final TextEditingController accountNumberController =
      TextEditingController()..addListener(_updateValues);
  late final TextEditingController accountCardHolderController =
      TextEditingController()..addListener(_updateValues);
  late final TextEditingController accountNameController =
      TextEditingController()..addListener(_updateValues);
  late final DateTime selectedDate = DateTime.now();
  late CardType selectedType = CardType.cash;

  bool get isAccountAddOrUpdate => widget.accountId == null;

  Account? account;

  void _updateValues() {
    setState(() {});
  }

  void _addOrUpdateAccount() {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (isAccountAddOrUpdate) {
      accountsBloc.add(
        AddAccountEvent(
          bankName: accountNameController.text,
          icon: Icons.credit_card.codePoint,
          holderName: accountCardHolderController.text,
          number: accountNumberController.text,
          validThru: selectedDate,
          cardType: selectedType,
        ),
      );
    } else {
      accountsBloc.add(
        UpdateAccountEvent(
          bankName: accountNameController.text,
          icon: Icons.credit_card.codePoint,
          holderName: accountCardHolderController.text,
          number: accountNumberController.text,
          validThru: selectedDate,
          cardType: selectedType,
          account: account,
        ),
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => accountsBloc,
      child: BlocConsumer(
        bloc: accountsBloc,
        listener: (context, state) {
          if (state is AddAccountState) {
            showMaterialSnackBar(
              context,
              isAccountAddOrUpdate
                  ? AppLocalizations.of(context)!.addedCardLabel
                  : AppLocalizations.of(context)!.updatedCardLabel,
            );
          }
          if (state is AccountDeletedState) {
            showMaterialSnackBar(
              context,
              AppLocalizations.of(context)!.deletedCardLabel,
            );
          } else if (state is AccountErrorState) {
            showMaterialSnackBar(context, state.errorString);
          }
        },
        buildWhen: (previous, current) => current is AccountSuccessState,
        builder: (context, state) {
          if (state is AccountSuccessState) {
            account = state.account;
            selectedType = account?.cardType ?? CardType.cash;
            accountNameController.text = account?.bankName ?? '';
            accountNumberController.text = account?.number ?? '';
            accountCardHolderController.text = account?.name ?? '';
          }

          return ScreenTypeLayout(
            mobile: Scaffold(
              appBar: materialYouAppBar(
                context,
                AppLocalizations.of(context)!.addCardLabel,
                actions: [
                  IconButton(
                    onPressed: _showInfo,
                    icon: const Icon(Icons.info_rounded),
                  ),
                  isAccountAddOrUpdate
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () => accountsBloc
                              .add(ClearAccountEvent(widget.accountId!)),
                          icon: Icon(
                            Icons.delete_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: CardTypeButtons(
                        onSelected: (cardType) {
                          selectedType = cardType;
                        },
                        selectedCardType: selectedType,
                      ),
                    ),
                    AccountCard(
                      cardNumber: accountNumberController.value.text,
                      cardHolder: accountCardHolderController.value.text,
                      bankName: accountNameController.value.text,
                      cardType: selectedType,
                    ),
                    Form(
                      key: _form,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            AccountCardHolderNameWidget(
                              controller: accountCardHolderController,
                            ),
                            const SizedBox(height: 16),
                            AccountNameWidget(
                              controller: accountNameController,
                            ),
                            const SizedBox(height: 16),
                            AccountNumberWidget(
                              controller: accountNumberController,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _addOrUpdateAccount,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.addCardLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:
                            Theme.of(context).textTheme.headline6?.fontSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            tablet: Scaffold(
              appBar: materialYouAppBar(
                context,
                AppLocalizations.of(context)!.addCardLabel,
                actions: [
                  IconButton(
                    onPressed: _showInfo,
                    icon: const Icon(Icons.info_rounded),
                  ),
                  isAccountAddOrUpdate
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () => accountsBloc
                              .add(ClearAccountEvent(widget.accountId!)),
                          icon: Icon(
                            Icons.delete_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                ],
              ),
              body: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AccountCard(
                        cardNumber: accountNumberController.value.text,
                        cardHolder: accountCardHolderController.value.text,
                        bankName: accountNameController.value.text,
                        cardType: selectedType,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Column(
                          children: [
                            Form(
                              key: _form,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    CardTypeButtons(
                                      onSelected: (cardType) {
                                        selectedType = cardType;
                                      },
                                      selectedCardType: selectedType,
                                    ),
                                    const SizedBox(height: 16),
                                    AccountCardHolderNameWidget(
                                      controller: accountCardHolderController,
                                    ),
                                    const SizedBox(height: 16),
                                    AccountNameWidget(
                                      controller: accountNameController,
                                    ),
                                    const SizedBox(height: 16),
                                    AccountNumberWidget(
                                      controller: accountNumberController,
                                    ),
                                    ElevatedButton(
                                      onPressed: _addOrUpdateAccount,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(24),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .addCardLabel,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              ?.fontSize,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInfo() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      context: context,
      builder: (context) {
        return SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)!.accountInfoLabel,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.accountInfoDescLabel,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.acceptLabel,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        );
      },
    );
  }
}

class AccountCardHolderNameWidget extends StatelessWidget {
  final TextEditingController controller;

  const AccountCardHolderNameWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.cardHolderLabel,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

class AccountNameWidget extends StatelessWidget {
  final TextEditingController controller;

  const AccountNameWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.accountNameLabel,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

class AccountNumberWidget extends StatelessWidget {
  final TextEditingController controller;

  const AccountNumberWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: 4,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.lastFourDigitLabel,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
