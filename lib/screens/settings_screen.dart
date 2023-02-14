// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../main.dart';
import '../screens/app_content_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import '../helpers/Strings.dart';
import '../helpers/Icons.dart';
import '../helpers/Constant.dart';
import '../widgets/change_theme_button_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin<SettingsScreen> {
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    if (showInterstitialAds) {
     // AdMobService.createInterstitialAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: Platform.isIOS ? false : true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(CustomStrings.settings),
          elevation: 2,
        ),
        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // extendBody: true,
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // floatingActionButton: showBottomNavigationBar
        //     ? FloatingActionButton(
        //         child: Lottie.asset(
        //           Theme.of(context).colorScheme.homeIcon,
        //           height: 30,
        //           repeat: true,
        //         ),
        //         onPressed: () {
        //           // setState(() {
        //           Navigator.of(context).pop();
        //           // });
        //         },
        //       )
        //     : null,
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    leading:
                        _buildIcon(Theme.of(context).colorScheme.darkModeIcon),
                    title: _buildTitle(CustomStrings.darkMode),
                    trailing: ChangeThemeButtonWidget(),
                  ),
                  ListTile(
                      leading:
                          _buildIcon(Theme.of(context).colorScheme.aboutUsIcon),
                      title: _buildTitle(CustomStrings.aboutUs),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () => _onPressed(AppContentScreen(
                          title: CustomStrings.aboutUs,
                          content: CustomStrings.aboutPageContent,
                          url: aboutPageURL))),
                  ListTile(
                      leading:
                          _buildIcon(Theme.of(context).colorScheme.privacyIcon),
                      title: _buildTitle(CustomStrings.privacyPolicy),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () => _onPressed(AppContentScreen(
                          title: CustomStrings.privacyPolicy,
                          content: CustomStrings.privacyPageContent,
                          url: privacyPageURL))),
                  ListTile(
                      leading:
                          _buildIcon(Theme.of(context).colorScheme.termsIcon),
                      title: _buildTitle(CustomStrings.terms),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () => _onPressed(AppContentScreen(
                          title: CustomStrings.terms,
                          content: CustomStrings.termsPageContent,
                          url: termsPageURL))),
                  ListTile(
                    leading:
                        _buildIcon(Theme.of(context).colorScheme.shareIcon),
                    title: _buildTitle(CustomStrings.share),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onTap: () => Share.share(
                        Platform.isAndroid
                            ? shareAndroidAppMessge
                            : shareiOSAppMessage,
                        subject: Platform.isAndroid
                            ? shareAndroidAppMessge
                            : shareiOSAppMessage),
                  ),
                  ListTile(
                      leading:
                          _buildIcon(Theme.of(context).colorScheme.rateUsIcon),
                      title: _buildTitle(CustomStrings.rateUs),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () => StoreRedirect.redirect(
                          androidAppId: androidAppId, iOSAppId: iOSAppId))
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildIcon(String icon) {
    return SvgPicture.asset(
      icon,
      width: 20,
      height: 20,
      color: Theme.of(context).iconTheme.color,
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  void _onPressed(Widget routeName) {
    if (showInterstitialAds) {
   //   AdMobService.showInterstitialAd();
    }
    navigatorKey.currentState!
        .push(CupertinoPageRoute(builder: (_) => routeName));
  }
}
