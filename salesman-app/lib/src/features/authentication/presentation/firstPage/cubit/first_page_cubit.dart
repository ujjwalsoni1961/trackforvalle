import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/features/authentication/domain/usecases/login_with_google.dart';

part 'first_page_state.dart';

class FirstPageCubit extends Cubit<FirstPageState> {
  final LoginWithGoogle loginWithGoogle;
  FirstPageCubit(this.loginWithGoogle) : super(FirstPageInitial());
  static final List<String> scopes = <String>['email', 'openid'];
  bool isTermsAndPrivacyChecked = false;

  // For web, clientId should be set in web/index.html meta tag or passed here
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: scopes,
    // Uncomment and add your web client ID here if not using meta tag
    // clientId: kIsWeb ? 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com' : null,
  );

  void toggleCheckBox() {
    isTermsAndPrivacyChecked = !isTermsAndPrivacyChecked;
    emit(TermsAndConditionToggled(isTermsAndPrivacyChecked));
  }

  Future<String> getGoogleAccessToken() async {
    // Signout if already signed in
    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (error) {
      log("Google Signout Error : ${error.toString()}");
    }
    try {
      GoogleSignInAccount? google = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await google!.authentication;
      return googleAuth.accessToken!;
    } catch (error) {
      log("Google Token Error : ${error.toString()}");
      return '';
    }
  }

  void signInWithGoogle() async {
    if (!isTermsAndPrivacyChecked) {
      emit(
        const GoogleSigninFailure(
          'Please agree to terms & condition and privacy policy.',
        ),
      );
      emit(FirstPageInitial());
      return;
    }
    emit(GoogleSigninInProgress());
    final googleAccessToken = await getGoogleAccessToken();
    if (googleAccessToken.isNotEmpty) {
      final response = await loginWithGoogle(
        LoginWithGoogleParams(googleAccessToken: googleAccessToken),
      );
      response.fold((failure) => emit(GoogleSigninFailure(failure.message)), (
        userData,
      ) async {
        final resLocal = await sl<UserLocalDataSource>().setUserData(userData);
        resLocal.fold(
          (failure) => emit(GoogleSigninFailure(failure.message)),
          (_) => emit(GoogleSigninSuccess()),
        );
      });
    } else {
      emit(const GoogleSigninFailure('Google Signin Failed'));
    }
  }
}
