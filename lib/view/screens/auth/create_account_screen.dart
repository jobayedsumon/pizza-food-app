import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/signup_model.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/auth/widget/code_picker_widget.dart';
import 'package:provider/provider.dart';

class CreateAccountScreen extends StatefulWidget {
  final String email;
  CreateAccountScreen({@required this.email});

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _countryDialCode;

  String _password;
  double _strength = 0;

  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Za-z].*");

  String _displayText = 'Password should contain at least 6 characters 1 alphabet and 1 number';

  void _checkPassword(String value) {
    _password = value.trim();

    if (_password.isEmpty) {
      setState(() {
        _strength = 0;
        _displayText = 'Password should contain at least 6 characters 1 alphabet and 1 number';
      });
    } else if (_password.length < 6) {
      setState(() {
        _strength = 1 / 4;
        _displayText = 'Your password is too short';
      });
    } else if (_password.length < 8) {
      setState(() {
        _strength = 2 / 4;
        _displayText = 'Your password is acceptable but not strong';
      });
    } else {
      if (!letterReg.hasMatch(_password) || !numReg.hasMatch(_password)) {
        setState(() {
          // Password length >= 8
          // But doesn't contain both letter and digit characters
          _strength = 3 / 4;
          _displayText = 'Your password is strong';
        });
      } else {
        // Password length >= 8
        // Password contains both letter and digit characters
        setState(() {
          _strength = 1;
          _displayText = 'Your password is great';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _countryDialCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel.countryCode).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? PreferredSize(child: WebAppBar(), preferredSize: Size.fromHeight(100)) : null,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) => SafeArea(
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                    child: Center(
                      child: Container(
                        width: _width > 700 ? 700 : _width,
                        padding: _width > 700 ? EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT) : null,
                        decoration: _width > 700 ? BoxDecoration(
                          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 5, spreadRadius: 1)],
                        ) : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: Text(
                              getTranslated('create_account', context),
                              style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 24, color: ColorResources.getGreyBunkerColor(context)),
                            )),
                            SizedBox(height: 20),

                            // for first name section
                            Text(
                              getTranslated('first_name', context),
                              style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            CustomTextField(
                              hintText: 'John',
                              isShowBorder: true,
                              controller: _firstNameController,
                              focusNode: _firstNameFocus,
                              nextFocus: _lastNameFocus,
                              inputType: TextInputType.name,
                              capitalization: TextCapitalization.words,
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            // for last name section
                            Text(
                              getTranslated('last_name', context),
                              style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            Provider.of<SplashProvider>(context, listen: false).configModel.emailVerification?
                            CustomTextField(
                              hintText: 'Doe',
                              isShowBorder: true,
                              controller: _lastNameController,
                              focusNode: _lastNameFocus,
                              nextFocus: _numberFocus,
                              inputType: TextInputType.name,
                              capitalization: TextCapitalization.words,
                            ):CustomTextField(
                              hintText: 'Doe',
                              isShowBorder: true,
                              controller: _lastNameController,
                              focusNode: _lastNameFocus,
                              nextFocus: _emailFocus,
                              inputType: TextInputType.name,
                              capitalization: TextCapitalization.words,
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            // for email section
                            Provider.of<SplashProvider>(context, listen: false).configModel.emailVerification?
                            Text(
                              getTranslated('mobile_number', context),
                              style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                            ):Text(
                              getTranslated('email', context),
                              style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                            Provider.of<SplashProvider>(context, listen: false).configModel.emailVerification?
                            Row(children: [
                              CodePickerWidget(
                                onChanged: (CountryCode countryCode) {
                                  _countryDialCode = countryCode.dialCode;
                                },
                                initialSelection: _countryDialCode,
                                favorite: [_countryDialCode],
                                showDropDownButton: true,
                                padding: EdgeInsets.zero,
                                showFlagMain: true,
                                textStyle: TextStyle(color: Theme.of(context).textTheme.headline1.color),

                              ),
                              Expanded(child: CustomTextField(
                                hintText: getTranslated('number_hint', context),
                                isShowBorder: true,
                                controller: _numberController,
                                focusNode: _numberFocus,
                                nextFocus: _passwordFocus,
                                inputType: TextInputType.phone,
                              )),
                            ]):CustomTextField(
                              hintText: getTranslated('demo_gmail', context),
                              isShowBorder: true,
                              controller: _emailController,
                              focusNode: _emailFocus,
                              nextFocus: _passwordFocus,
                              inputType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            // for password section
                            Text(
                              getTranslated('password', context),
                              style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            CustomTextField(
                              hintText: getTranslated('password_hint', context),
                              isShowBorder: true,
                              isPassword: true,
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              nextFocus: _confirmPasswordFocus,
                              onChanged: (value) => _checkPassword(value),
                              isShowSuffixIcon: true,
                            ),

                            // The strength indicator bar
                            LinearProgressIndicator(
                              value: _strength,
                              backgroundColor: Colors.grey[300],
                              color: _strength <= 1 / 4
                                  ? Colors.red
                                  : _strength == 2 / 4
                                  ? Colors.yellow
                                  : _strength == 3 / 4
                                  ? Colors.blue
                                  : Colors.green,
                              minHeight: 5,
                            ),
                            const SizedBox(
                              height:5,
                            ),

                            // The message about the strength of the entered password
                            Text(
                              _displayText,
                            ),
                            SizedBox(height: 22),

                            // for confirm password section
                            Text(
                              getTranslated('confirm_password', context),
                              style: Theme.of(context).textTheme.headline2.copyWith(color: ColorResources.getHintColor(context)),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            CustomTextField(
                              hintText: getTranslated('password_hint', context),
                              isShowBorder: true,
                              isPassword: true,
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocus,
                              isShowSuffixIcon: true,
                              inputAction: TextInputAction.done,
                            ),

                            SizedBox(height: 22),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                authProvider.registrationErrorMessage.length > 0
                                    ? CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 5)
                                    : SizedBox.shrink(),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.registrationErrorMessage ?? "",
                                    style: Theme.of(context).textTheme.headline2.copyWith(
                                          fontSize: Dimensions.FONT_SIZE_SMALL,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                )
                              ],
                            ),

                            // for signup button
                            SizedBox(height: 10),
                            !authProvider.isLoading
                                ? CustomButton(
                                    btnTxt: getTranslated('signup', context),
                                    onTap: _strength < 1 / 2 ? null : () {
                                      String _firstName = _firstNameController.text.trim();
                                      String _lastName = _lastNameController.text.trim();
                                      String _number = _countryDialCode+_numberController.text.trim();
                                      String _email = _emailController.text.trim();
                                      String _password = _passwordController.text.trim();
                                      String _confirmPassword = _confirmPasswordController.text.trim();
                                      if(Provider.of<SplashProvider>(context, listen: false).configModel.emailVerification){
                                        if (_firstName.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_first_name', context), context);
                                        }else if (_lastName.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_last_name', context), context);
                                        }else if (_number.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_phone_number', context), context);
                                        }else if (_password.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_password', context), context);
                                        }else if (_password.length < 6) {
                                          showCustomSnackBar(getTranslated('password_should_be', context), context);
                                        }else if (_confirmPassword.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_confirm_password', context), context);
                                        }else if(_password != _confirmPassword) {
                                          showCustomSnackBar(getTranslated('password_did_not_match', context), context);
                                        }else if (!(_email.contains('@') && _email.contains('.'))) {
                                        showCustomSnackBar("Email is not valid", context);
                                        return;
                                        }else {
                                          SignUpModel signUpModel = SignUpModel(
                                            fName: _firstName,
                                            lName: _lastName,
                                            email: widget.email,
                                            password: _password,
                                            phone: _number
                                          );
                                          authProvider.registration(signUpModel).then((status) async {
                                            if (status.isSuccess) {
                                              // await Provider.of<WishListProvider>(context, listen: false).initWishList(
                                              //   context, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                                              // );
                                              Navigator.pushNamedAndRemoveUntil(context, Routes.getMainRoute(), (route) => false);
                                            }
                                          });
                                        }
                                      }
                                      else{
                                        if (_firstName.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_first_name', context), context);
                                        }else if (_lastName.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_last_name', context), context);
                                        }else if (_number.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_phone_number', context), context);
                                        }else if (_password.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_password', context), context);
                                        }else if (_password.length < 6) {
                                          showCustomSnackBar(getTranslated('password_should_be', context), context);
                                        }else if (_confirmPassword.isEmpty) {
                                          showCustomSnackBar(getTranslated('enter_confirm_password', context), context);
                                        }else if(_password != _confirmPassword) {
                                          showCustomSnackBar(getTranslated('password_did_not_match', context), context);
                                        }else {
                                          SignUpModel signUpModel = SignUpModel(
                                            fName: _firstName,
                                            lName: _lastName,
                                            email: _email,
                                            password: _password,
                                            phone:  widget.email.trim().contains('+') ? widget.email.trim() : '+'+widget.email.trim(),
                                          );
                                          authProvider.registration(signUpModel).then((status) async {
                                            if (status.isSuccess) {
                                              // await Provider.of<WishListProvider>(context, listen: false).initWishList(
                                              //   context, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                                              // );
                                              Navigator.pushNamedAndRemoveUntil(context, Routes.getMainRoute(), (route) => false);
                                            }
                                          });
                                        }
                                      }
                                    },
                                  )
                                : Center(
                                    child: CircularProgressIndicator(
                                    valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                  )),

                            // for already an account
                            SizedBox(height: 11),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, Routes.getLoginRoute());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      getTranslated('already_have_account', context),
                                      style: Theme.of(context).textTheme.headline2.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: ColorResources.getGreyColor(context)),
                                    ),
                                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                                    Text(
                                      getTranslated('login', context),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3
                                          .copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: ColorResources.getGreyBunkerColor(context)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if(ResponsiveHelper.isDesktop(context)) FooterView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
