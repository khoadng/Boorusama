#!/usr/bin/env bash
echo == slang
cd ./packages/i18n && flutter pub run slang; cd ~-
echo == generate language
cd ./packages/i18n && flutter pub run tools/generate_language.dart; cd ~-
echo == generate config
cd ./packages/booru_clients && flutter pub run tools/generate_config.dart; cd ~-
echo == generate yaml
cd ./packages/booru_clients && flutter pub run tools/generate_yaml_configs.dart; cd ~-
echo == generate registry
cd ./packages/booru_clients && flutter pub run tools/generate_registry.dart; cd ~-
wait
