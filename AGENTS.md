# AGENTS.md

## Project Context

- This repository is a study project for designing GitHub collaboration automation.
- The default validation flow is `pnpm lint`, `pnpm test`, and `pnpm build`.
- Work branches should target `test` first, then `test` is merged into `main`.
- Automation work should stay small, reviewable, and easy to explain in a pull request.

## Automation Guidelines

- Prefer GitHub Actions workflows for repeatable collaboration tasks.
- Keep workflow permissions as narrow as the task allows.
- Use repository secrets for API keys and never hard-code credentials.
- Make AI-generated changes traceable through issue comments, workflow logs, commits, or PR bodies.
- Run validation commands after code changes whenever dependencies are available.

## Pull Request Guidelines

- Follow `.github/PULL_REQUEST_TEMPLATE.md` for the PR body structure.
- Use `.github/pr-writing-guide.md` for PR title and body writing rules.
- Do not claim tests were run unless the workflow or developer actually ran them.
- Mark uncertain implementation details as `확인 필요` instead of guessing.
