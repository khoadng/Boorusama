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
- Avoid writing comments that over-explain the code. Write comments only when necessary to explain complex logic or decisions that are not immediately clear from the code itself.

# Testing
- Focus on observable behavior, not implementation details.
- Use mocks/stubs only for external dependencies, avoid mocking internal logic.
- Keep tests minimal, logically grouped, and use parameterized cases with clear input/output records.
- Make sure parameterized tests are focused on a single behavior per test.
- Don’t write tests for obvious language behavior, one-line getters/setters, or redundant validation. Each test should protect meaningful logic or edge cases only.
- Test names must be clear sentences describing behavior and outcome. Do not include function or class names

# Workflow
- Run `dart format` after each file creation, prefer batch formatting.
- Always take a look and sample related code before writing new code to understand the existing patterns.
- Use the GitHub CLI (`gh`) for all GitHub-related tasks.
- When committing, use conventional commits format, e.g. `fix(posts): handle null tags` and only write commit summaries, no descriptions.
