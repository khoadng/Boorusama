## Commands
- `flutter test` - Run tests
- `./gen.sh` - Generate i18n, language configs, and booru client configs

# Code style
- For Riverpod, always use Notifier/AsyncNotifier. Manually declare providers, no codegen.
- Prefer using factory methods/constructors for creating instances with complex setup, move all constructor to the top of the class.
- Always put business logic into state classes or a dedicated file.
- Use `equatable` for value equality when necessary.
- Always use pattern matching to make code more readable, only use traditional if/else when it improves readability.
- When parsing data from external sources, always assume data is nullable and handle null cases explicitly in the code.

# Workflow
- Run `dart format` after each file creation, prefer batch formatting.
- Always take a look and sample related code before writing new code to understand the existing patterns.
- Use the GitHub CLI (`gh`) for all GitHub-related tasks.
- When committing, use conventional commits format, e.g. `fix(posts): handle null tags` and only write commit summaries, no descriptions.
