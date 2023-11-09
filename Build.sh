#!/bin/bash

source "$(dirname "$BASH_SOURCE")/.validate"

IFS=$'\n'
files=( $(validate_diff --diff-filter=ACMR --name-only -- '*.go' | grep -v '^Vendor/' || true) )
unset IFS

badFiles=()
for f in "${files[@]}"; do
	# we use "git show" here to validate that what's committed is formatted
	if [ "$(git show "$VALIDATE_HEAD:$f" | gofmt -s -l)" ]; then
		badFiles+=( "$f" )
	fi
done

if [ ${#badFiles[@]} -eq 0 ]; then
	echo 'Congratulations!  All Go source files are properly formatted.'
else
	{
		echo "These files are not properly gofmt'd:"
		for f in "${badFiles[@]}"; do
			echo " - $f"
		done
		echo
		echo 'Please reformat the above files using "gofmt -s -w" and commit the result.'
		echo
	} >&2
	false
fi
