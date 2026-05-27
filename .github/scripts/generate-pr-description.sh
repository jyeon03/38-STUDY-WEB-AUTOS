#!/usr/bin/env bash

set -euo pipefail

TARGET_BRANCH="$1"
SOURCE_BRANCH="$2"
REQUESTED_PR_TYPE="${3:-feat}"
ALLOWED_PR_TYPE_PATTERN='^(feat|fix|refactor|chore|docs|test|ci)$'

if ! printf '%s' "$REQUESTED_PR_TYPE" | grep -Eq "$ALLOWED_PR_TYPE_PATTERN"; then
  REQUESTED_PR_TYPE="feat"
fi

if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "GEMINI_API_KEY is not configured." >&2
  exit 1
fi

git fetch origin "$TARGET_BRANCH:refs/remotes/origin/$TARGET_BRANCH" --depth=1

MERGE_BASE=$(git merge-base "origin/$TARGET_BRANCH" HEAD)
COMMITS=$(git log --no-merges "$MERGE_BASE..HEAD" --oneline)
DIFF_STATS=$(git diff --stat "$MERGE_BASE..HEAD")
DIFF_CONTENT=$(git diff --unified=3 "$MERGE_BASE..HEAD" \
  -- . \
  ':(exclude)package-lock.json' \
  ':(exclude)yarn.lock' \
  ':(exclude)pnpm-lock.yaml' \
  ':(exclude)dist/**' \
  ':(exclude).gitignore')

if [ -z "$DIFF_CONTENT" ]; then
  {
    echo "should_create=false"
    echo "title=[$REQUESTED_PR_TYPE] 변경 사항 없음"
    echo "body<<EOF"
    echo "변경 사항이 없어 PR을 생성하지 않습니다."
    echo "EOF"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

PR_TEMPLATE=$(cat .github/PULL_REQUEST_TEMPLATE.md)
PR_WRITING_GUIDE=""

if [ -f .github/pr-writing-guide.md ]; then
  PR_WRITING_GUIDE=$(cat .github/pr-writing-guide.md)
fi

PROMPT=$(cat <<EOF
당신은 GitHub Pull Request 제목과 본문 초안을 작성하는 한국어 기술 문서 작성자입니다.

목표:
- feature 브랜치에서 test 브랜치로 보내는 PR의 제목과 본문 초안을 생성합니다.
- 저장소 PR 템플릿의 섹션 구조를 유지한 상태로 각 항목을 초안 형태로 채웁니다.

제목 규칙:
- 반드시 한국어로 작성합니다.
- 형식은 "[type] 작업 내용"입니다.
- type은 반드시 "$REQUESTED_PR_TYPE"을 사용합니다.
- issue type과 PR title type이 일치해야 하므로 다른 type으로 바꾸지 않습니다.
- 60자 이내를 권장합니다.

본문 규칙:
- 반드시 한국어 마크다운으로 작성합니다.
- 변경 사항은 커밋 목록, 변경 파일 통계, 상세 diff에 근거해 작성합니다.
- 아래에 제공되는 PR 템플릿의 헤더 구조와 순서를 그대로 유지합니다.
- 아래에 제공되는 PR 작성 지침을 우선적으로 따릅니다.
- 구현 방식에는 diff에서 확인 가능한 파일명, workflow trigger, 권한, secret 이름, branch 흐름, helper script, 검증 명령, PR 생성 방식을 구체적으로 포함합니다.
- "자동화 로직 추가", "기능 개선", "테스트 진행"처럼 추상적인 표현만 단독으로 쓰지 않습니다.
- 각 bullet은 가능한 한 "무엇을", "어디서", "어떻게" 바꿨는지 드러나게 작성합니다.
- 확실하지 않은 내용은 추측하지 말고 "확인 필요" 또는 "직접 보완 필요"라고 적습니다.
- 테스트를 실제로 실행했다고 추정하지 않습니다.
- 각 섹션은 2~4개의 bullet로 작성하되, 내용이 없는 섹션은 "직접 보완 필요"라고 적습니다.
- HTML 주석은 제거하고 실제 초안 문장을 작성합니다.

출력 형식:
TITLE: [$REQUESTED_PR_TYPE] 예시 제목
---
아래 PR 템플릿 구조를 유지한 완성된 마크다운 본문

PR 정보:
- base branch: $TARGET_BRANCH
- head branch: $SOURCE_BRANCH
- issue type: $REQUESTED_PR_TYPE

PR 템플릿:
---
$PR_TEMPLATE
---

PR 작성 지침:
---
$PR_WRITING_GUIDE
---

커밋 목록:
$COMMITS

변경 파일 통계:
$DIFF_STATS

상세 diff:
$DIFF_CONTENT
EOF
)

REQUEST_BODY=$(jq -n --arg prompt "$PROMPT" '{
  contents: [
    {
      role: "user",
      parts: [{ text: $prompt }]
    }
  ],
  generationConfig: {
    temperature: 0.2
  }
}')

write_fallback_pr_draft() {
  PR_TITLE="[$REQUESTED_PR_TYPE] 자동 생성 PR 초안 작성"
  PR_BODY_DRAFT=$(cat <<EOF
## 👀 Summary

- AI PR 본문 생성 중 Gemini API가 일시적으로 실패해 fallback 초안을 생성했습니다.
- 변경 사항은 아래 커밋 목록과 파일 통계를 기준으로 직접 확인이 필요합니다.

---

## 🚨 해결하고 싶은 문제

- 자동화된 PR 생성 흐름에서 코드 변경 후 PR 생성까지 이어지도록 처리합니다.
- Gemini PR 설명 생성 API가 불안정한 경우에도 PR 생성 자체가 중단되지 않도록 합니다.

---

## 💻 구현 방식

- base branch: \`$TARGET_BRANCH\`
- head branch: \`$SOURCE_BRANCH\`
- 커밋 목록과 diff 통계를 기반으로 PR 초안을 생성했습니다.

\`\`\`text
$COMMITS
\`\`\`

\`\`\`text
$DIFF_STATS
\`\`\`

---

## 🐾 테스트

- 직접 보완 필요

---

## 🤬 어려웠던 점

- Gemini API가 일시적으로 503 또는 빈 응답을 반환할 수 있어 fallback 본문을 사용했습니다.

---

## 📚 참고 자료

- 직접 보완 필요
EOF
)
}

GEMINI_RESPONSE=""
GEMINI_OK=false

for attempt in 1 2 3 4 5; do
  HTTP_RESPONSE=$(curl -sS -w '\n%{http_code}' -X POST \
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}" \
    -H 'Content-Type: application/json' \
    -d "$REQUEST_BODY")

  HTTP_STATUS=$(printf '%s' "$HTTP_RESPONSE" | tail -n 1)
  GEMINI_RESPONSE=$(printf '%s' "$HTTP_RESPONSE" | sed '$d')

  if [ "$HTTP_STATUS" = "200" ]; then
    GEMINI_OK=true
    break
  fi

  if [ "$attempt" -eq 5 ] || { [ "$HTTP_STATUS" != "429" ] && [ "${HTTP_STATUS#5}" = "$HTTP_STATUS" ]; }; then
    echo "Gemini API request failed with status $HTTP_STATUS. Falling back to a deterministic PR draft." >&2
    echo "$GEMINI_RESPONSE" >&2
    write_fallback_pr_draft
    break
  fi

  sleep $((attempt * attempt * 2))
done

if [ "$GEMINI_OK" = "true" ]; then
  FULL_RESPONSE=$(printf '%s' "$GEMINI_RESPONSE" | jq -r '
    .candidates[0].content.parts
    | map(.text // "")
    | join("")
  ')

  if [ -z "$FULL_RESPONSE" ] || [ "$FULL_RESPONSE" = "null" ]; then
    echo "Gemini API returned an empty response. Falling back to a deterministic PR draft." >&2
    echo "$GEMINI_RESPONSE" >&2
    write_fallback_pr_draft
  else
    PR_TITLE=$(printf '%s\n' "$FULL_RESPONSE" | sed -n 's/^TITLE:[[:space:]]*//p' | head -n 1)
    PR_BODY_DRAFT=$(printf '%s\n' "$FULL_RESPONSE" | sed '1,/^---$/d')

    if [ -z "$PR_TITLE" ] || [ -z "$PR_BODY_DRAFT" ]; then
      echo "Failed to parse Gemini response. Falling back to a deterministic PR draft." >&2
      write_fallback_pr_draft
    fi
  fi
fi

normalize_pr_title_type() {
  local raw_title="$1"
  local title_without_type

  title_without_type=$(printf '%s' "$raw_title" | sed -E 's/^\[?(feat|fix|refactor|chore|docs|test|ci)\]?[[:space:]]*[:：-]?[[:space:]]*//I')

  if [ -z "$title_without_type" ]; then
    title_without_type="자동 생성 PR 초안 작성"
  fi

  printf '[%s] %s' "$REQUESTED_PR_TYPE" "$title_without_type"
}

PR_TITLE=$(normalize_pr_title_type "$PR_TITLE")

TITLE_FILE=$(mktemp)
BODY_FILE=$(mktemp)

printf '%s' "$PR_TITLE" > "$TITLE_FILE"
printf '%s' "$PR_BODY_DRAFT" > "$BODY_FILE"

{
  echo "should_create=true"
  echo "title=$PR_TITLE"
  echo "title_file=$TITLE_FILE"
  echo "body_file=$BODY_FILE"
} >> "$GITHUB_OUTPUT"
