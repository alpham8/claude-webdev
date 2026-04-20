#!/bin/bash
# Block dangerous Bash commands before execution

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

[ -z "$CMD" ] && exit 0

# Patterns that are unconditionally dangerous
DANGEROUS_PATTERNS=(
    'rm -rf /'
    'rm -rf ~'
    'rm -rf \$HOME'
    '>\s*/dev/sda'
    'dd if=.* of=/dev/'
    'mkfs\.'
    'DROP DATABASE'
    'DROP TABLE.*CASCADE'
    'git push --force.*(main|master)'
    'git push -f.*(main|master)'
    ': \$\{VAR:=\}; rm'
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$CMD" | grep -qE "$pattern"; then
        jq -n \
          --arg reason "Gefährliches Kommando blockiert: Pattern '$pattern' erkannt. Bitte den Befehl manuell ausführen falls beabsichtigt." \
          '{
            hookSpecificOutput: {
              hookEventName: "PreToolUse",
              permissionDecision: "deny",
              permissionDecisionReason: $reason
            }
          }'
        exit 2
    fi
done

exit 0
