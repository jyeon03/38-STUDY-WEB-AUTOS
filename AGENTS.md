# AGENTS.md

## Project Context

- 이 repository는 GitHub 협업 자동화를 직접 설계하고 검증하는 study project입니다.
- 기본 validation flow는 `pnpm lint`, `pnpm test`, `pnpm build`입니다.
- 작업 branch는 먼저 `test`를 target으로 삼고, 검증 후 `test`를 `main`에 merge합니다.
- automation 작업은 작고 review하기 쉬운 단위로 유지하며, pull request에서 변경 이유를 쉽게 설명할 수 있어야 합니다.

## Automation Guidelines

- 반복되는 협업 작업은 우선 GitHub Actions workflow로 자동화합니다.
- workflow permissions는 작업에 필요한 최소 범위로 설정합니다.
- API key는 repository secrets를 사용하고, credential을 코드에 hard-code하지 않습니다.
- AI-generated changes는 issue comment, workflow logs, commits, PR body 중 하나 이상에서 추적 가능해야 합니다.
- dependencies를 사용할 수 있다면 code changes 이후 validation commands를 실행합니다.

## Pull Request Guidelines

- PR body 구조는 `.github/PULL_REQUEST_TEMPLATE.md`를 따릅니다.
- PR title과 body 작성 규칙은 `.github/pr-writing-guide.md`를 기준으로 합니다.
- workflow 또는 developer가 실제로 실행하지 않은 tests는 실행했다고 작성하지 않습니다.
- 확인되지 않은 implementation details는 추측하지 말고 `확인 필요`로 표시합니다.
