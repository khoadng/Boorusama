# Boorusama Project Guide

### Writing New Code

#### Adding New Booru Type
1. Add configuration to `packages/booru_clients/boorus.yaml`
2. Run `./gen.sh` to generate booru configs
3. Create `lib/boorus/{type}/` directory
4. Implement `{type}.dart` with `create{Type}()` factory function
5. Create matching client in `packages/booru_clients/lib/`

#### Adding Cross-Booru Features
- Use `lib/core/{feature}/` for shared functionality
- Follow module structure: types, data providers, UI widgets
- Put business logic in state classes (Riverpod Notifier/AsyncNotifier)

#### Module Organization
```
lib/core/{feature}/
├── {sub-feature}/
│   ├── {sub-feature}.dart  # Types barrel exports
│   ├── providers.dart      # Data barrel exports
│   ├── widgets.dart        # UI barrel exports
│   ├── routes.dart         # Route barrel exports
│   └── src/                # Implementation (never import directly)
│       ├── types/          # Domain models, interfaces
│       ├── data/           # Repositories, providers
│       ├── widgets/        # UI components
│       └── routes/         # Route definitions
```

### Creating New Features

#### Step-by-Step Feature Creation
1. **Core Feature** (`lib/core/{feature}/`)
   - Create module structure with barrel exports
   - Define domain models with `Equatable` in `src/types/`
   - Implement Riverpod providers in `src/data/` (manual declaration, Notifier/AsyncNotifier)
   - Build UI components in `src/widgets/`
   - For translation, add keys in `packages/i18n/translations/en-US.json` and run `./gen.sh` then use `context.t.key` in code
   - Register routes in main router


### Booru Directory Patterns
```
lib/boorus/{type}/
├── {type}.dart                 # Factory function & main booru class
├── {type}_builder.dart         # UI customizations
├── {type}_repository.dart      # Data layer
├── client_provider.dart        # Client providers
├── posts/                      # Post features (providers, widgets, types, parsers)
├── tags/                       # Tag management
├── configs/                    # Configuration UI
├── home/                       # Home page customization
├── favorites/                  # Favorites (if supported)
└── [other features]/           # comments, artists, notes, autocompletes, etc.
```
