#!/bin/sh
echo -ne '\033c\033]0;Vampire Survivor Clone\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/export_web.x86_64" "$@"
