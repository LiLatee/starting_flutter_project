import 'package:envied/envied.dart';

part 'env.g.dart';

/// If you need to use "staging" or "production" envs then just change path to .env file.
/// staging -> 'secrets/keys/staging.env'
/// production -> 'secrets/keys/production.env'
/// development -> 'secrets/keys/development.env'
@Envied(path: 'secrets/keys/development.env')
abstract class Env {
  @EnviedField(defaultValue: 'example_key_development', varName: 'EXAMPLE_KEY', obfuscate: true)
  static final String key = _Env.key;
}
