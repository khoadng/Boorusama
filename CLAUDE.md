## Commands
- `flutter test` - Run tests
- `./gen.sh` - Generate i18n, language configs, and booru client configs

## Configuration
- `boorus.yaml` - Defines supported booru sites and their protocols (danbooru, moebooru, etc.)

# Code style
- For Riverpod, always use Notifier/AsyncNotifier. Manually declare providers, no codegen.
- Prefer using factory methods/constructors for creating instances with complex setup.
- Always put business logic into state classes.
- Use `equatable` for value equality in models.

# Workflow
- Always put a single newline at the end a file, when seeing `eol_at_end_of_file` lint warning, just run `dart format <file>`.
- Remember to use the GitHub CLI (`gh`) for all GitHub-related tasks.
- When committing, use conventional commits format, e.g. `fix(posts): handle null tags` and only write commit summaries, no descriptions.

## Key Dependencies
- **State**: `flutter_riverpod`
- **Routing**: `go_router`
- **HTTP**: `dio`
- **DB**: `sqlite3`, `hive`

## Architecture

```
lib/
├── boorus/                    # Booru implementations (danbooru, gelbooru, etc.)
│   ├── registry.dart          # Factory registry for all booru types
│   └── danbooru/              # Example booru implementation
│       ├── danbooru.dart           # Main booru class + parser
│       ├── danbooru_builder.dart   # API operations builder
│       ├── danbooru_repository.dart # Data access layer
│       ├── posts/                  # Posts feature module
│       │   ├── post/               # Individual post handling
│       │   ├── details/            # Post details page
│       │   └── favorites/          # Favorites management
│       └── users/             # User management
├── core/                      # Shared feature modules used across all boorus
│   └── posts/                 # Example module structure
│       ├── post/              # Sub-module
│       │   ├── post.dart           # Types barrel (export 'src/types/*.dart')
│       │   ├── providers.dart      # Data barrel (export 'src/data/*.dart')
│       │   ├── widgets.dart        # UI barrel (export 'src/widgets/*.dart')
│       │   └── src/                # Implementation details
│       │       ├── types/          # Domain models, interfaces
│       │       ├── data/           # Repositories, providers
│       │       └── widgets/        # UI components
│       └── details/
├── foundation/                # Low-level utilities (database, networking, etc.)
└── main.dart

packages/                      # Local workspace packages
├── booru_clients/             # API clients for different booru sites
├── i18n/                     # Internationalization with codegen
└── foundation/               # Shared foundation code
```

**Module Pattern**: Each feature uses barrel exports to expose clean APIs while keeping implementation details in `src/` directories.
