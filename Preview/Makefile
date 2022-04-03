SHELL=/usr/bin/env bash -o pipefail

.PHONY: generated
generated: protobuf lineitemtypes

.PHONY: protobuf
protobuf: src/lib/generated/export.js src/lib/generated/export.d.ts

.PHONY: lineitemtypes
lineitemtypes: src/lib/generated/LineItemTypes.json src/lib/generated/LineItemTypes.ts

src/lib/generated:
	mkdir -p "$@"

src/lib/generated/export.js: ../Source/Model/Export/FleetboxExport.proto src/lib/generated
	pbjs -t static-module -o "$@" -w es6 --es6 "$<"

src/lib/generated/export.d.ts: src/lib/generated/export.js
	pbts -o "$@" "$<"

src/lib/generated/LineItemTypes.json: ../Source/Model/Line\ Item\ Types/LineItemTypes.yml src/lib/generated
	yq -o=json eval "$<" | jq -c . > "$@"

src/lib/generated/LineItemTypes.ts: ../Source/Model/Line\ Item\ Types/LineItemTypes.schema.json src/lib/generated
	json2ts "$<" "$@"

.PHONY: clean
clean:
	rm -rf src/lib/generated