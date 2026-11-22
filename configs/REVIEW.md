# Acme Review Instructions

Acme policy. Read from protected main only.

## What Important means here
Important is reserved for changes that break a spec
contract, move money incorrectly, leak data, or block a
rollback:
- float arithmetic on amounts, or rounding outside
  money.round_half_even()
- an UPDATE or DELETE on ledger postings
- a migration that is not backward compatible
- a change under tests/contracts/ without a spec change
- account numbers, PANs, or tokens in logs or errors
Treat any violation of a CLAUDE.md rule as Important.
Style, naming, and refactoring are Nit at most.

## Evidence
- Every finding cites file:line in this repository.
- Behavior claims need the source line, not an inference
  from a name. No citation, no finding.

## Cap the nits
Report at most three Nits per review.

## Do not report
- Lint, format, and type errors: hooks report them;
  make check blocks them where CI requires it
- Generated files under src/gen/ and any *.lock file

## Always check
- Every change under src/settlement/fees/ cites a FEE-nnn
  contract in the PR body
- Skipped or deleted tests are justified in the PR body
- New API handlers call require_entitlement() before
  reading ledger data
