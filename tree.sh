#!/bin/bash

tree() {
	find "$([[ -z "$1" ]] && echo "." || echo $1)" -maxdepth 1 -type d | while read line; do
		[[ "$line" == "$1" ]] && continue
		[[ -n "$(grep "^\.$" <<< "$line")" ]] && continue
		echo "$2+[$(basename "$line")]"
		tree "$line" "$2|"
	done

	find "$([[ -z "$1" ]] && echo "." || echo $1)" -maxdepth 1 -type f | while read line; do
		echo "$2-$(basename "$line")"
	done
}

[[ -z "$1" ]] && tree