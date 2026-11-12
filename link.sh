#!/usr/bin/env bash
set -euo pipefail

if [ -z "${NUM:-}" ]; then
  echo "::warning::Review on iPhone runs on pull_request events only. Skipping."
  exit 0
fi

trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; printf '%s' "${s%"${s##*[![:space:]]}"}"; }

match=false
[ "${IN_ALL:-false}" = "true" ] && match=true
IFS=',' read -ra items <<< "${IN_PREFIXES:-}"
for p in ${items[@]+"${items[@]}"}; do p="$(trim "$p")"; [ -n "$p" ] && [[ "$HEAD_REF" == "$p"* ]] && match=true; done
IFS=',' read -ra items <<< "${IN_AUTHORS:-}"
for a in ${items[@]+"${items[@]}"}; do a="$(trim "$a")"; [ -n "$a" ] && [ "$AUTHOR" = "$a" ] && match=true; done

if [ "$match" != "true" ]; then
  echo "Not an agent pull request (author $AUTHOR, branch $HEAD_REF). Skipping."
  exit 0
fi

marker="<!-- review-on-iphone -->"
url="https://skoroapps.com/gh#${REPO}/pull/${NUM}"
line="[${IN_TEXT:-Review on iPhone}](${url})"

fail() { echo "::warning::Could not add the link: $1. Pull requests from forks get a read-only token."; exit 0; }

case "${IN_MODE:-comment}" in
  comment)
    existing="$(gh api --paginate "repos/$REPO/issues/$NUM/comments" --jq ".[] | select(.body | contains(\"$marker\")) | .id" 2>/dev/null | head -n1)" || fail "cannot read comments"
    if [ -n "$existing" ]; then echo "Link comment already exists. Nothing to do."; exit 0; fi
    gh api "repos/$REPO/issues/$NUM/comments" -f body="$line
$marker" > /dev/null || fail "cannot comment"
    ;;
  description)
    body="$(gh api "repos/$REPO/pulls/$NUM" --jq '.body // ""')" || fail "cannot read the pull request"
    if [[ "$body" == *"$marker"* ]]; then echo "Link already in the description. Nothing to do."; exit 0; fi
    gh api -X PATCH "repos/$REPO/pulls/$NUM" -f body="${body}

${line}
${marker}" > /dev/null || fail "cannot edit the description"
    ;;
  *) echo "::error::mode must be comment or description"; exit 1 ;;
esac
echo "Added: $url"
