cd packages/i18n && dart run slang &
cd packages/i18n && dart run tools/generate_language.dart &
cd packages/booru_clients && dart run tools/generate_config.dart &
wait
