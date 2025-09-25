# Boorusama Project Guide

### Writing New Code

#### Adding New Booru Type
1. Create `lib/boorus/{type}/` directory
2. Implement `{type}.dart` with `create{Type}()` factory function
3. Add to registry map in `lib/boorus/registry.dart`
4. Create matching client in `packages/booru_clients/lib/`

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
├── {type}.dart                 # Main booru class
├── {type}_builder.dart         # UI customizations
├── {type}_repository.dart      # Data layer
├── posts/                      # Core post features
│   ├── post/
│   ├── details/               # Post detail pages
│   ├── favorites/             # Favorites management
│   └── [type-specific features]
├── tags/                       # Tag management
├── configs/                    # Configuration
├── home/                       # Home page customization
└── [advanced features]/       # comments, artists, notes, etc.
```
