#!/bin/bash

# Розширений скрипт підрахунку файлів

TARGET_DIR="${1:-/etc}"
EXT="${2:-}"
RECURSIVE="${3:-}"

# Перевірка існування директорії
if [ ! -d "$TARGET_DIR" ]; then
    echo "Помилка: директорія $TARGET_DIR не існує"
    exit 1
fi

count_items() {
    local dir=$1
    local type=$2
    local ext=$3
    local recursive=$4
    local name_filter=()
    [ -z "$ext" ] || name_filter=(-name "*.$ext")
    local depth=(-maxdepth 1)
    if [ "$recursive" = "r" ]; then
        depth=()
    fi
    find "$dir" "${depth[@]}" -type "$type" "${name_filter[@]}" 2>/dev/null | wc -l
}

calc_total_size() {
    local dir=$1
    local ext=$2
    local recursive=$3
    local name_filter=()
    [ -z "$ext" ] || name_filter=(-name "*.$ext")
    local depth=(-maxdepth 1)
    if [ "$recursive" = "r" ]; then
        depth=()
    fi
    find "$dir" "${depth[@]}" -type f "${name_filter[@]}" -printf '%s\n' 2>/dev/null | awk '{sum += $1} END {print sum + 0}'
}

files=$(count_items "$TARGET_DIR" "f" "$EXT" "$RECURSIVE")
dirs=$(count_items "$TARGET_DIR" "d" "" "$RECURSIVE")
links=$(count_items "$TARGET_DIR" "l" "" "$RECURSIVE")
total_bytes=$(calc_total_size "$TARGET_DIR" "$EXT" "$RECURSIVE")
total_number=$(numfmt --to=iec --suffix=B "$total_bytes" 2>/dev/null || echo "${total_bytes}B")

echo "Статистика директорії $TARGET_DIR:"
if [ -n "$EXT" ]; then
    echo "  Файли з розширенням .$EXT: $files"
else
    echo "  Звичайні файли: $files"
fi
echo "  Директорії: $((dirs - 1))"
echo "  Символічні посилання: $links"
echo "  Загальний розмір файлів: $total_number ($total_bytes байт)"
echo "  -------------------------"
echo "  Разом: $files"
