#!/bin/bash
# Format PHP/TS/JS/Vue files after Write or Edit tool calls

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.new_file_path // empty' 2>/dev/null)

[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$CWD" ] && cd "$CWD" 2>/dev/null

case "$FILE" in
    *.php)
        if [ -f vendor/bin/php-cs-fixer ]; then
            vendor/bin/php-cs-fixer fix "$FILE" --quiet 2>/dev/null
        fi
        ;;
    *.ts|*.tsx|*.js|*.jsx|*.vue|*.json|*.css|*.scss)
        if [ -f node_modules/.bin/prettier ]; then
            node_modules/.bin/prettier --write "$FILE" --log-level silent 2>/dev/null
        fi
        ;;
esac

exit 0
