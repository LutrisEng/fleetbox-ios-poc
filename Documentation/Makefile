SHELL=/usr/bin/env bash -o pipefail

.PHONY: generated
generated: lineitemtypes docs/changelog.md

.PHONY: lineitemtypes
lineitemtypes: src/generated/LineItemTypes.json src/generated/LineItemTypes.ts

src/generated:
	mkdir -p "$@"

src/generated/LineItemTypes.json: ../Source/Model/Line\ Item\ Types/LineItemTypes.yml src/generated
	js-yaml "$<" > "$@"

src/generated/LineItemTypes.ts: ../Source/Model/Line\ Item\ Types/LineItemTypes.schema.json src/generated
	json2ts "$<" "$@"

docs/changelog.md: ../CHANGELOG.md
	cp "$<" "$@"

.PHONY: clean
clean:
	rm -rf src/generated
	rm docs/changelog.md