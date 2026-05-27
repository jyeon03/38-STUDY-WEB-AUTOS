# PR Writing Guide

## Title

- title은 한국어로 작성합니다.
- 형식은 `[type] 작업 내용`을 사용합니다.
- type은 `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci` 중 하나만 선택합니다.
- issue에서 확인되는 type이 있다면 PR title의 `[type]`도 같은 값을 사용합니다.
- title은 짧고 구체적으로 작성합니다.

## Body

- section 순서는 `.github/PULL_REQUEST_TEMPLATE.md`를 유지합니다.
- 최종 PR body에서는 HTML comments를 제거합니다.
- 모든 설명은 commits, diff stats, changed files, workflow results에서 확인 가능한 내용만 기반으로 작성합니다.
- intent, test results, screenshots, reviewer context를 임의로 지어내지 않습니다.
- diff에서 확인할 수 없는 detail은 `확인 필요` 또는 `직접 보완 필요`로 작성합니다.
- 긴 문단보다 짧은 bullet points를 우선 사용합니다.
- diff에서 확인되는 file names, workflow names, trigger names, branch names, secret names, permission scopes, script names, command names 같은 concrete identifiers를 명시합니다.
- `자동화 로직을 추가했습니다`, `기능을 개선했습니다`, `테스트를 진행했습니다`처럼 모호한 표현은 피합니다. 사용해야 한다면 바로 다음 문장에서 무엇이 바뀌었는지 구체적으로 설명합니다.

## Section Expectations

- `Summary`: 무엇이 바뀌었고 어떤 user workflow가 가능해졌는지 설명합니다. 가장 중요한 changed files를 함께 언급합니다.
- `해결하고 싶은 문제`: 이 automation이 줄이는 collaboration friction을 구체적으로 설명합니다. 문제를 trigger 또는 workflow behavior와 연결합니다.
- `구현 방식`: 확인 가능한 implementation details를 작성합니다. 예: GitHub Actions event, branch flow, permission scopes, secret names, AI model/API, helper scripts, validation commands, PR creation method.
- `테스트`: 실제로 실행한 commands 또는 workflow steps에서 확인되는 checks만 작성합니다. local 실행이나 Actions 실행 여부가 보이지 않으면 `직접 보완 필요`로 작성합니다.
- `어려웠던 점`: GitHub token permissions, missing secrets, AI patch validity, prompt injection, end-to-end Actions 미검증, external API failures처럼 구체적인 risks 또는 limitations를 작성합니다.
- `참고 자료`: 관련 repository files와 official docs가 확인되거나 명확히 관련 있으면 포함합니다. 그렇지 않으면 `직접 보완 필요`로 작성합니다.

## Concrete Writing Checklist

PR body를 확정하기 전에 diff에 아래 항목이 있는지 확인합니다. 해당 항목이 있다면 알맞은 section에 명시합니다.

- 변경된 workflow file paths.
- 변경된 script file paths.
- `push`, `pull_request`, `issue_comment`, `workflow_dispatch` 같은 GitHub Actions triggers.
- `test`, `main` 같은 target branch rules.
- `contents: write`, `issues: write`, `pull-requests: write` 같은 GitHub permissions.
- `PR_GEMINI_API_KEY` 같은 secret names.
- `gemini-2.5-flash` 같은 external model 또는 API names.
- `pnpm lint`, `pnpm test`, `pnpm build` 같은 validation commands.
- `feat/login-page-ui/#3` 같은 `type/feature-name/#issue-number` branch naming rules.
- `gh pr create`, `peter-evans/create-pull-request` 같은 PR creation tools.

## Tone

- review 가능한 technical PR을 준비하는 teammate처럼 작성합니다.
- 구체적이고 중립적이며 간결하게 작성합니다.
- marketing language는 사용하지 않습니다.
