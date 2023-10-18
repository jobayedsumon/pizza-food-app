import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_restaurant/data/model/response/social_login_model.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/routes.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/screens/forgot_password/verification_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';


class SocialLoginCheckoutWidget extends StatefulWidget {
  String type;
  SocialLoginCheckoutWidget(this.type);

  @override
  State<SocialLoginCheckoutWidget> createState() => _SocialLoginCheckoutWidgetState();
}

class _SocialLoginCheckoutWidgetState extends State<SocialLoginCheckoutWidget> {
  SocialLoginModel socialLogin = SocialLoginModel();

  void route(
      bool isRoute,
      String token,
      String temporaryToken,
      String errorMessage,
      ) async {
    if (isRoute) {
      if(token != null){
        Navigator.pushNamedAndRemoveUntil(context, Routes.getDashboardRoute('home'), (route) => false,);

      }else if(temporaryToken != null && temporaryToken.isNotEmpty){
        if(Provider.of<SplashProvider>(context,listen: false).configModel.emailVerification){
          Provider.of<AuthProvider>(context, listen: false).checkEmail(socialLogin.email).then((value) async {
            if (value.isSuccess) {
              Provider.of<AuthProvider>(context, listen: false).updateEmail(socialLogin.email.toString());
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (_) => VerificationScreen(emailAddress: socialLogin.email, fromSignUp: true,)), (route) => false);

            }
          });
        }
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (_) => VerificationScreen(emailAddress: '', fromSignUp: true,)), (route) => false);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage),
            backgroundColor: Colors.red));
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final _socialStatus = Provider.of<SplashProvider>(context,listen: false).configModel.socialLoginStatus;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topCenter,
          child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

             if(_socialStatus.isGoogle)
               Row(
                 children: [
                   InkWell(
                      onTap: () async {
                        try{
                          GoogleSignInAuthentication  _auth = await authProvider.googleLogin();
                          GoogleSignInAccount _googleAccount = authProvider.googleAccount;

                          Provider.of<AuthProvider>(context, listen: false).socialLogin(SocialLoginModel(
                            email: _googleAccount.email, token: _auth.idToken, uniqueId: _googleAccount.id, medium: 'google',
                          ), route);


                        }catch(er){
                        }
                      },
                      child: Container(
                        height: ResponsiveHelper.isDesktop(context)
                            ? 50 : 40,
                        width: ResponsiveHelper.isDesktop(context) ? 125 :ResponsiveHelper.isTab(context) ? 105 : 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
                          borderRadius: BorderRadius.all(Radius.circular(Dimensions.RADIUS_DEFAULT)),
                        ),
                        child:   Image.asset(
                          Images.google,
                          height: ResponsiveHelper.isDesktop(context)
                              ? 30 :ResponsiveHelper.isTab(context)
                              ? 25 : 20,
                          width: ResponsiveHelper.isDesktop(context)
                              ? 30 : ResponsiveHelper.isTab(context)
                              ? 25 : 20,
                        ),
                      ),
                    ),

                   //if(_socialStatus.isFacebook)
                   //  SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT,),
                 ],
               ),


              if(_socialStatus.isFacebook)
                InkWell(
                onTap: () async{
                  LoginResult _result = await FacebookAuth.instance.login();

                  if (_result.status == LoginStatus.success) {
                   Map _userData = await FacebookAuth.instance.getUserData();


                   Provider.of<AuthProvider>(context, listen: false).socialLogin(
                     SocialLoginModel(
                       email: _userData['email'],
                       token: _result.accessToken.token,
                       uniqueId: _result.accessToken.userId,
                       medium: 'facebook',
                     ), route,
                   );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 5.0),
                  height: ResponsiveHelper.isDesktop(context)?50 :ResponsiveHelper.isTab(context)? 40:40,
                  width: ResponsiveHelper.isDesktop(context) ? 125 :ResponsiveHelper.isTab(context) ? 105 : 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(Dimensions.RADIUS_DEFAULT)),
                  ),
                  child:   Image.asset(
                    Images.facebook,
                    height: ResponsiveHelper.isDesktop(context)
                        ? 30 : ResponsiveHelper.isTab(context)
                        ? 25 : 20,
                    width: ResponsiveHelper.isDesktop(context)
                        ? 30 :ResponsiveHelper.isTab(context)
                        ? 25 : 20,
                  ),
                ),
              ),

              InkWell(
                onTap: () async{
                  Navigator.pushNamed(context, Routes.getLoginRoute());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Container(
                    height: ResponsiveHelper.isDesktop(context)?50 :ResponsiveHelper.isTab(context)? 40:40,
                    width: ResponsiveHelper.isDesktop(context) ? 125 :ResponsiveHelper.isTab(context) ? 105 : 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(Dimensions.RADIUS_DEFAULT)),
                    ),
                    child:   Text(
                     "Login"
                    ),
                  ),
                ),
              ),
            ]),
            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL,),
          ]),
        );
      }
    );
  }
}
