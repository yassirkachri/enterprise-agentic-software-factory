# The Enterprise Agentic Software Factory: Reference Configurations

This repository holds the reference configuration files behind
*The Enterprise Agentic Software Factory*, a reference architecture
and implementation guide for running Claude Code as a governed
software delivery system in a regulated enterprise. Every file here
is reproduced verbatim in Appendix A of the guide, and each one is
explained in the chapter listed next to it below. The files are
meant to be read, adapted, and reviewed, not deployed as they
stand.

## The Architecture in Brief

The guide's operating model runs at **Level 3 conditional
autonomy**. Each agent works one bounded task in its own Git
worktree, and four verification stations check its output before a
person reads it. A named **Change Owner** for each domain makes two
decisions:

- **Spec Gate**: approving the change to the durable specification
  before work starts.
- **Merge Gate**: accepting the evidence before the change merges.

Levels 4 and 5, where agents merge without a named approver, are out
of scope for regulated production services, and managed settings
turn off the experimental Agent Teams feature.

The factory has five planes, each with one job and a named team that
operates it:

| Plane | Job | Decisive control | Operated by |
|---|---|---|---|
| 1. Intent | Turn ticket deltas into approved changes to durable specs | Spec Gate on `specs/`; MCP servers from a managed list | Change Owner |
| 2. Context and workbench | Give each agent scoped rules and an isolated worktree | Managed deny rules; fail-closed edit hooks; a test gate at stop | Platform team |
| 3. Verification | Check agent output before the Merge Gate | A read-only critic in CI; review rules from the base branch | Change Owner, AppSec |
| 4. Headless CI/CD | Run agents in pipelines without standing secrets | Short-lived federated identity; budgets; a sandbox; no push rights | Platform team, AppSec |
| 5. Gateway and telemetry | Route model traffic, meter spend, join it to delivery data | Identity-provider sign-in; per-person caps; one collector | Platform team, budget owner |

Agents reach tickets and other enterprise systems through the Model
Context Protocol. Connectors are authorized with OAuth 2.1, per the
MCP authorization specification
(<https://modelcontextprotocol.io/specification/latest/basic/authorization>).

## What Each File Does and Where It Is Deployed

The files keep the `configs/` paths the guide cites. The "Deployed
as" column gives the location each file takes in a real
installation. Because they live under `configs/` here, GitHub does
not act on the sample `CODEOWNERS` file or the two sample Actions
workflows in this repository.

### Plane 1: Intent

| File | Chapters | Deployed as |
|---|---|---|
| `configs/CODEOWNERS` | 2, 3, 4, 7, 8 | `.github/CODEOWNERS` in each repository (GitLab reads the root, `docs/`, or `.gitlab/`) |
| `configs/managed-mcp.json` | 2 | Managed MCP server list, delivered through MDM |
| `configs/CLAUDE.md.template` | 2, 3 | `CLAUDE.md` at each repository's root, owned by its Change Owners |

### Plane 2: Context and Workbench

| File | Chapters | Deployed as |
|---|---|---|
| `configs/managed-settings.json` | 3, 6 | Managed settings path on every laptop and runner image |
| `configs/managed-settings.d/30-laptop-guards.json` | 2, 3, 9 | Managed drop-in on laptops, through MDM |
| `configs/hooks/session-audit.sh` | 3, 9 | `/opt/acme/hooks/session-audit.sh`, through MDM |
| `configs/hooks/webfetch-internal.sh` | 3 | `/opt/acme/hooks/webfetch-internal.sh`, through MDM |
| `configs/settings.hooks.json` | 3 | Merged into each repository's `.claude/settings.json` |
| `configs/hooks/protect-paths.sh` | 3 | `.claude/hooks/protect-paths.sh` |
| `configs/hooks/test-gate.sh` | 3, 5 | The `Stop` hook in `.claude/hooks/` |
| `configs/hooks/post-edit.sh` | 3 | The `PostToolUse` hook for Python files in `.claude/hooks/` |

### Plane 3: Verification

| File | Chapters | Deployed as |
|---|---|---|
| `configs/critic-reviewer.md` | 4 | `.claude/agents/critic-reviewer.md`, loaded from `origin/main` |
| `configs/REVIEW.md` | 4 | `REVIEW.md`, read from the protected default branch only |
| `configs/managed-settings.d/20-verification.json` | 4 | Managed drop-in on laptops and implementer runners |
| `configs/github-claude-factory.yml` | 4, 5 | `.github/workflows/claude-factory.yml` in the platform repository `acme/factory-ci` |
| `configs/github-claude-critic.yml` | 4 | `.github/workflows/claude-critic.yml` in `acme/factory-ci` |
| `configs/github-ruleset-critic.json` | 8 | Body of a GitHub organization rulesets API call, one per domain |
| `configs/github-ruleset-factory.json` | 4, 8 | Body of a GitHub organization rulesets API call |

### Plane 4: Headless CI/CD

| File | Chapters | Deployed as |
|---|---|---|
| `configs/gitlab-ci-bedrock-oidc.yml` | 5 | Pipeline of the GitLab platform project `acme/platform/factory-ci` |
| `configs/ci-sandbox.json` | 5 | Passed to the pipeline implementer with `--settings` |
| `configs/managed-settings.d/30-runner-telemetry.json` | 5, 6 | Managed drop-in on runner images only |
| `configs/managed-settings.d/40-runner-secrets.json` | 5 | Managed drop-in on runner images only |

### Plane 5: Gateway and Telemetry

| File | Chapters | Deployed as |
|---|---|---|
| `configs/gateway.yaml` | 6, 7, 8, 9 | Run with `claude gateway --config gateway.yaml` |
| `configs/managed-settings.d/30-laptop-gateway.json` | 6 | Managed drop-in on laptops, through MDM |
| `configs/otel-collector.yaml` | 6 | OpenTelemetry Collector for the gateway and runner pools |
| `configs/factory-scorecard.yaml` | 1, 2, 4, 6 | Scorecard definition in the factory policy repository |

### People, Governance, and Day-2 Operation

| File | Chapters | Deployed as |
|---|---|---|
| `configs/l3-readiness.yaml` | 7, 8 | One file per service in the factory policy repository |
| `configs/managed-settings.d/35-laptop-retention.json` | 7 | Managed drop-in on laptops |
| `configs/arb-exception.yaml` | 8 | One file per dispensation in `dispensations/` |
| `configs/check-dispensations.sh` | 8 | Daily job, and on pull requests that touch `dispensations/` |
| `configs/kill-switch-l2.yaml` | 8, 9 | Merged into the catch-all policy of `gateway.yaml` |
| `configs/stop-laptop-traffic.sh` | 9 | Fleet lever run by the platform on-call |
| `configs/revoke-ci-sessions.sh` | 9 | Run by the platform on-call after new agent jobs stop |

Some controls are not files: branch protection, project settings,
IAM trust policies, and identity-provider groups are configured on
each platform. The guide lists the ones each file depends on.

## Scope and Disclaimer

- **Reference configurations, not a product.** The files are
  written for the placeholder organization **Acme**
  (`acme.internal`, `acme.example`, `@acme/` teams, `ACME_*`
  variables, AWS documentation account `111122223333`). The guide's
  case study, **Northstar Financial Group**, is illustrative: it
  shows how the same components assemble inside one regulated bank
  and measures nothing.
- **Checked against the documentation.** Claude Code settings keys,
  hook events, flags, and paths were checked against the Claude
  Code documentation as published in November 2026. GitHub, GitLab,
  and AWS behavior follows their documentation as cited in the
  guide. Platforms change; confirm each mechanism against the
  current documentation before you rely on it.
- **No client results.** Neither this repository nor the guide
  reports any client outcome, benchmark, or ROI figure.
- **Illustrative values.** Caps, versions, budgets, IDs, commits,
  and dates are starting points to replace with your own. Comments
  marked "Acme policy" flag design choices that a reader could
  mistake for platform behavior; the deny lists, caps, ownership
  lines, and job shapes are design choices too, even where no
  comment says so. None of these files is a product default.
- **Replace every placeholder and review before reuse.** Render the
  files under your own names in a reviewed change, run them through
  your own security review, and test them in a non-production
  environment first.

## Validating Locally

The workflow in `.github/workflows/validate-configs.yml` runs three
checks on every push and pull request. To run the same checks on
your machine, install the tools:

```bash
# macOS
brew install jq yamllint shellcheck
# Debian or Ubuntu
sudo apt-get install jq yamllint shellcheck
```

Then, from the repository root:

```bash
# JSON parses
find configs -name '*.json' -print0 | xargs -0 -t -n1 jq empty
# YAML syntax
yamllint -c .yamllint.yml .
# Shell scripts
find configs -name '*.sh' -print0 | xargs -0 shellcheck
```

The YAML check uses yamllint's `relaxed` preset, which fails on any
syntax error but does not enforce spacing style. The files match
the text printed in the guide character for character, so their
layout is kept as published.

These checks prove syntax only. They do not show that a file
behaves correctly on your platform, at your Claude Code version, or
under your policies.

## The Guide and Its Companions

The configurations are one part of a set of three documents,
available at <https://yassirkachri.com>:

- **Executive Brief**: the decisions, risks, and 90-day trajectory
  for an executive committee.
- **Strategic Whitepaper**: the operating-model argument for
  architects and engineering leaders.
- **Reference Architecture & Implementation Guide**: *The
  Enterprise Agentic Software Factory*, with the mechanisms,
  sources, and full configurations.

Author: Yassir Kachri, Enterprise AI, Cloud & Security Architect.
<https://yassirkachri.com> ·
<https://www.linkedin.com/in/yassirkachri/>

## License

Released under the [MIT License](LICENSE).
