import 'package:injectable/injectable.dart';
import 'package:my_audio_player/injection.config.dart';
import 'package:my_audio_player/main.dart';

@injectableInit
void configureInjection(String environment) => $initGetIt(
  getIt,
  environment: environment,
);

// Injectable package gives us flavors with: 'Environment.test', 'Environment.dev', 'Environment.prod',
// but we can register own environments to pass in 'configureInjection' function.
abstract class Env {
  static const web = 'web';
  static const mobile = 'mobile';
}
