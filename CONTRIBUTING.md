# Contributing to Boorusama

We would love for you to contribute to Boorusama and help make it even better than it is today!
As a contributor, here are the guidelines we would like you to follow:

## <a name="commit"></a> Commit Message Format

*This specification is inspired by the Angular commit message format.*

#### <a name="commit-header"></a>Commit Message Header

```
<type>(<scope>): <short summary>
  │       │             │
  │       │             └─⫸ Summary in present tense. Not capitalized. No period at the end.
  │       │
  │       └─⫸ Commit Scope: posts|comments|users|explore...
  │
  └─⫸ Commit Type: build|ci|docs|feat|fix|perf|refactor|test|l10n|i18n
```

The `<type>` and `<summary>` fields are mandatory, the `(<scope>)` field is optional.

##### Type

Must be one of the following:

* **build**: Changes that affect the build system or external dependencies (example scopes: pub, npm)
* **ci**: Changes to our CI configuration files and scripts (examples: CircleCi, GitHub Action)
* **docs**: Documentation only changes
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
* **feat**: A new feature
* **fix**: A bug fix
* **perf**: A code change that improves performance
* **refactor**: A code change that neither fixes a bug nor adds a feature
* **test**: Adding missing tests or correcting existing tests
* **l10n**: Translation only changes
* **i18n**: Changes to remove hardwired string and changes that affect translation files


##### Scope
The scope should be the name of the features affected.

* `posts`
* `comments`
* `users`
* `explore`
* T.B.D


##### Summary

Use the summary field to provide a succinct description of the change:

* use the imperative, present tense: "change" not "changed" nor "changes"
* don't capitalize the first letter
* no dot (.) at the end


#### <a name="commit-body"></a>Commit Message Body

Just as in the summary, use the imperative, present tense: "fix" not "fixed" nor "fixes".

Explain the motivation for the change in the commit message body. This commit message should explain _why_ you are making the change.
You can include a comparison of the previous behavior with the new behavior in order to illustrate the impact of the change.
