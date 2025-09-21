# boorusama_lint

Custom lint rules for Boorusama project to enforce code quality and consistency.

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint: ^0.8.0
  boorusama_lint:
    path: packages/boorusama_lint
```

Enable the plugin in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - no_relative_src_imports:
        excluded_paths:
          - "/test/"
```

## Usage

### Command Line
```bash
dart run custom_lint
```

Alternatively, install globally:
```bash
# Install globally
dart pub global activate custom_lint
# Run from anywhere
custom_lint
```

## Available Rules

- `no_relative_src_imports`: Prevents relative imports to `/src/` directories, encouraging barrel exports instead

## Configuration

Rules can be disabled or configured:

```yaml
custom_lint:
  rules:
    - no_relative_src_imports: false  # Disable rule
    - no_relative_src_imports:        # Configure rule
        excluded_paths:
          - "/test/"
          - "/example/"
```
