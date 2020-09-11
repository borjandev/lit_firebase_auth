import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../domain/auth/auth_providers.dart';
import '../domain/auth/i_auth_facade.dart';
import '../domain/auth/user.dart';
import '../infrastructure/firebase_auth_facade.dart';

/// The initialization for Firebase Authentication. This widget must be at the root of
/// your application, above [MaterialApp] or [CupertinoApp].
/// For example:
/// ```dart
/// class MyApp extends StatelessWidget {
///  @override
///  Widget build(BuildContext context) {
///    return LitAuthInit(
///      authProviders: AuthProviders(
///        emailAndPassword: true,
///        google: true,
///        anonymous: true,
///      ),
///      child: MaterialApp(
///        title: 'Material App',
///        home: SplashScreen(),
///      ),
///    );
///  }
///}
///```
///{@end-tool}
/// The enabled authentication providers should be specified with the
/// [authProviders] parameter. By default only email and password authentication
/// is enabled.
class LitAuthInit extends StatelessWidget {
  LitAuthInit({
    Key key,
    this.authProviders = const AuthProviders(),
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  /// Specify the authentication providers that should be enabled for this
  /// application. By default only email and password authentication is enabled.
  ///
  /// For example:
  /// ```
  ///AuthProviders(
  ///  emailAndPassword: false, // enables Email and Password sign-in
  ///  anonymous: true, // enables Anonymous sign-in
  ///  google: true, // enables Google sign-in
  ///)
  ///```
  ///{@end-tool}
  final AuthProviders authProviders;

  final Widget child;

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              Provider<AuthProviders>.value(
                value: authProviders,
              ),
              Provider<AuthFacade>(
                create: (_) => FirebaseAuthFacade(
                  googleSignInEnabled: authProviders.google,
                ),
                lazy: false,
              ),
              StreamProvider(
                create: (context) async* {
                  // return context.read<AuthFacade>().onAuthStateChanged;
                  await for (final user
                      in context.read<AuthFacade>().onAuthStateChanged) {
                    yield user;
                  }
                },
                lazy: false,
                initialData: const LitUser.initializing(),
              ),
            ],
            child: child,
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container();
      },
    );
  }
}
