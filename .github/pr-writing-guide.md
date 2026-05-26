# PR Writing Guide

## Title

- Write the title in Korean.
- Use the format `[type] 작업 내용`.
- Choose exactly one type from `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`.
- Keep the title concise and specific.

## Body

- Keep the section order from `.github/PULL_REQUEST_TEMPLATE.md`.
- Remove HTML comments from the final PR body.
- Base every statement on commits, diff stats, changed files, or workflow results.
- Do not invent intent, test results, screenshots, or reviewer context.
- If a detail cannot be verified from the diff, write `확인 필요` or `직접 보완 필요`.
- Prefer short bullet points over long paragraphs.
- Include concrete identifiers such as file names, workflow names, trigger names, branch names, secret names, permission scopes, script names, and command names when they are visible in the diff.
- Avoid vague phrases like `자동화 로직을 추가했습니다`, `기능을 개선했습니다`, or `테스트를 진행했습니다` unless the next sentence explains exactly what changed.

## Section Expectations

- `Summary`: Explain what changed and what user workflow is now possible. Mention the most important changed files.
- `해결하고 싶은 문제`: Describe the exact collaboration friction this automation reduces. Connect the problem to the trigger or workflow behavior.
- `구현 방식`: Include all visible implementation details that apply: GitHub Actions event, branch flow, permission scopes, secret names, AI model/API, helper scripts, validation commands, and PR creation method.
- `테스트`: List only commands or checks that were actually run or are visible in workflow steps. If local or Actions execution is not visible, write `직접 보완 필요`.
- `어려웠던 점`: Mention concrete risks or limitations such as GitHub token permissions, missing secrets, AI patch validity, prompt injection, unverified end-to-end Actions runs, or external API failures.
- `참고 자료`: Include related repository files and official docs when they are visible or clearly relevant. Otherwise write `직접 보완 필요`.

## Concrete Writing Checklist

Before finalizing the PR body, check whether the diff contains each item below. If it does, mention it explicitly in the appropriate section.

- Changed workflow file paths.
- Changed script file paths.
- GitHub Actions triggers such as `push`, `pull_request`, `issue_comment`, or `workflow_dispatch`.
- Target branch rules such as `test` or `main`.
- GitHub permissions such as `contents: write`, `issues: write`, or `pull-requests: write`.
- Secret names such as `PR_GEMINI_API_KEY`.
- External model or API names such as `gemini-2.5-flash`.
- Validation commands such as `pnpm lint`, `pnpm test`, and `pnpm build`.
- Branch naming rules such as `auto/ai-pr-issue-{number}`.
- PR creation tools such as `gh pr create` or `peter-evans/create-pull-request`.

## Tone

- Write as a teammate preparing a reviewable technical PR.
- Be concrete, neutral, and concise.
- Avoid marketing language.
