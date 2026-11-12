# Review on iPhone

Adds a **Review on iPhone** link to pull requests opened by AI agents. Tap it on your phone and the pull request opens in [Code Viewer](https://skoroapps.com/code-viewer/?ref=action): read the diff, comment on lines, approve and merge.

## Usage

Create `.github/workflows/review-on-iphone.yml`:

```yaml
name: Review on iPhone
on:
  pull_request:
    types: [opened, reopened, ready_for_review]
permissions:
  pull-requests: write
jobs:
  link:
    runs-on: ubuntu-latest
    steps:
      - uses: skoroapps-hq/review-on-iphone@v1
```

To pin an exact version, use the commit SHA instead of `v1`, for example `skoroapps-hq/review-on-iphone@<sha>`.

By default it adds one comment to pull requests from branches starting with `claude/`, `codex/`, `copilot/`, `cursor/` or `devin/`. It never comments twice on the same pull request.

## Options

| Input | Default | What it does |
|---|---|---|
| `branch-prefixes` | `claude/,codex/,copilot/,cursor/,devin/` | Branches treated as agent pull requests |
| `authors` | empty | PR author logins treated as agent pull requests, e.g. `my-bot[bot]` |
| `all-prs` | `false` | `true` adds the link to every pull request |
| `mode` | `comment` | `description` appends the link to the PR description instead |
| `text` | `Review on iPhone` | Link text |
| `token` | `github.token` | Token with `pull-requests: write` |

## Privacy

The action uses your repository's own token and talks only to GitHub. Nothing is sent to us. The link looks like `https://skoroapps.com/gh#owner/repo/pull/12`: the part after `#` stays on your device, so our server never sees the repository name. Anyone who can see the pull request can see the link.

Pull requests from forks get a read-only token, so the action skips them with a warning instead of failing.

## Without the action

Add one line to `CLAUDE.md` or `AGENTS.md` so the agent puts the link in the PR itself. See [skoroapps.com/code-viewer/review-links](https://skoroapps.com/code-viewer/review-links/).
