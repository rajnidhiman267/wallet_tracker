// In your HomeScreen, replace the direct FirebaseAuth.signOut() call with
// the AuthCubit.signOut() so the biometric flag is also cleared.
//
// FIND this in home_screen.dart:
//
//   IconButton(
//     icon: const Icon(Icons.logout_rounded, color: Colors.white),
//     onPressed: () async {
//       await FirebaseAuth.instance.signOut();        // ❌ skips biometric cleanup
//       if (context.mounted) context.goNamed(AppRouteName.login);
//     },
//   ),
//
// REPLACE WITH:
//
//   IconButton(
//     icon: const Icon(Icons.logout_rounded, color: Colors.white),
//     onPressed: () async {
//       await authRemoteDatasource.signOut();         // ✅ clears biometric flag too
//       if (context.mounted) context.goNamed(AppRouteName.login);
//     },
//   ),
//
// OR even simpler — just call the datasource directly since AuthCubit
// isn't available in HomeScreen's BlocProvider tree:

// home_screen.dart — only the relevant logout snippet shown
// Replace the logout IconButton's onPressed with this:

/*
  onPressed: () async {
    final datasource = AuthRemoteDatasource(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
    await datasource.signOut();
    if (context.mounted) context.goNamed(AppRouteName.login);
  },
*/

// Full updated home_screen logout button for copy-paste:
