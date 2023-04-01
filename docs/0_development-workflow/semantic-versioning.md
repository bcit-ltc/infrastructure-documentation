# Semantic versioning

The pipelines use [`semantic-release`](https://semantic-release.gitbook.io/semantic-release/) to analyze commit messages and determine if a new git tag should be created.

## Semver keywords

To use automatic [semver tagging](https://semver.org/), add any of the following to your commit messages:

| **Prefix:** ...commit message...                                           | Release type  |
| ----------------------                                                     | ------------  |
| `fix: ...some smaller bugfix...`                                           | patch         |
| `feat: ...add functionality message...`                                    | minor         |
| `any term!: ...big version change...\nBREAKING CHANGE: some description`*  | major         |
`*` *the "footer" of the commit message must start with **BREAKING CHANGE:***

