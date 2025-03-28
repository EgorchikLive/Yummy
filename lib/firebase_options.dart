import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

// FirebaseOptions firebaseOptions = const FirebaseOptions(
//     apiKey: 'AIzaSyDvxCOw86-4jONwdOOcZYhHScnx_jPeODo',
//     appId: '1:651756444474:android:4a9771d06af00ad1f30e03',
//     messagingSenderId: '651756444474',
//     projectId: 'yummy-5e694');

FirebaseOptions get firebaseOptions {
  if (Platform.isAndroid) {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDvxCOw86-4jONwdOOcZYhHScnx_jPeODo',
      appId: '1:651756444474:android:4a9771d06af00ad1f30e03',
      messagingSenderId: '651756444474',
      projectId: 'yummy-5e694'
    );
  } else if (Platform.isIOS) {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDv_vUfTVYLnJkzRdJtfVUHSu4To9I_Uho',
      appId: '1:651756444474:ios:ddd6189ba824ffe9f30e03',
      messagingSenderId: '651756444474',
      projectId: 'yummy-5e694',
      iosBundleId: 'com.example.yummy',
    );
  } else {
    throw UnsupportedError("Unsupported platform");
  }
}
