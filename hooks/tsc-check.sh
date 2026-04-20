#!/bin/bash
# Run TypeScript type-check after Write or Edit on .ts/.tsx files

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.new_file_path // empty' 2>/dev/null)

[ -z "$FILE" ] && exit 0

case "$FILE" in
    *.ts|*.tsx) ;;
    *) exit 0 ;;
esac

CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$CWD" ] && cd "$CWD" 2>/dev/null

if [ ! -f node_modules/.bin/tsc ]; then
    exit 0
fi

# Only run if tsconfig.json exists
[ ! -f tsconfig.json ] && exit 0

OUTPUT=$(node_modules/.bin/tsc --noEmit --pretty false 2>&1)
EXIT=$?

if [ $EXIT -ne 0 ] && [ -n "$OUTPUT" ]; then
    echo "$OUTPUT" | head -30 >&2
    exit 1
fi

exit 0
