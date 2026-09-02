#!/bin/bash
# Run PHPStan on changed PHP files after Write or Edit

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.new_file_path // empty' 2>/dev/null)

[ -z "$FILE" ] && exit 0

case "$FILE" in
    *.php) ;;
    *) exit 0 ;;
esac

[ ! -f "$FILE" ] && exit 0

CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$CWD" ] && cd "$CWD" 2>/dev/null

if [ ! -f vendor/bin/phpstan ]; then
    exit 0
fi

OUTPUT=$(vendor/bin/phpstan analyse "$FILE" --no-progress --error-format=raw 2>&1)
EXIT=$?

if [ $EXIT -ne 0 ] && [ -n "$OUTPUT" ]; then
    echo "$OUTPUT" | head -20 >&2
    # Non-blocking (exit 1) — shows warning to Claude but doesn't block
    exit 1
fi

exit 0
