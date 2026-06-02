#!/usr/bin/env bash
#
# Append a CHANGELOG.md entry for a Dependabot pull request, under an
# "Infrastructure" subsection of the [Unreleased] section. Idempotent:
# re-running it for the same pull request makes no change.
#
# Required environment variables:
#   PR_TITLE    Pull request title (e.g. "Bump actions/checkout from 4 to 5").
#   PR_NUMBER   Pull request number.
#   PR_URL      Pull request HTML URL.
#
# Usage:
#   ./.github/scripts/add-dependabot-changelog-entry.sh
#

set -euo pipefail

changelog="CHANGELOG.md"

: "${PR_TITLE:?PR_TITLE is required}"
: "${PR_NUMBER:?PR_NUMBER is required}"
: "${PR_URL:?PR_URL is required}"

# Idempotency: do nothing if this pull request is already referenced.
if grep -q "/pull/${PR_NUMBER})" "${changelog}"; then
    echo "CHANGELOG already references PR #${PR_NUMBER}; nothing to do."
    exit 0
fi

entry="- ${PR_TITLE} ([#${PR_NUMBER}](${PR_URL}))"
tmp="$(mktemp)"

if grep -qE '^### Infrastructure[[:space:]]*$' "${changelog}"; then
    # Insert under the existing Infrastructure heading (after its blank line).
    awk -v entry="${entry}" '
        !inserted && /^### Infrastructure[[:space:]]*$/ {
            print
            if ((getline line) > 0) {
                print line
            }
            print entry
            inserted = 1
            next
        }
        { print }
    ' "${changelog}" > "${tmp}"
else
    # Create an Infrastructure subsection just under [Unreleased].
    awk -v entry="${entry}" '
        !inserted && /^## \[Unreleased\]/ {
            print
            print ""
            print "### Infrastructure"
            print ""
            print entry
            inserted = 1
            next
        }
        { print }
    ' "${changelog}" > "${tmp}"
fi

mv "${tmp}" "${changelog}"
echo "Added CHANGELOG entry for PR #${PR_NUMBER}."
