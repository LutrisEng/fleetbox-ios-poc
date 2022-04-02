.PHONY: protobuf
protobuf: src/lib/generated/export.js src/lib/generated/export.d.ts

src/lib/generated:
	mkdir -p $@

src/lib/generated/export.js: ../Source/Model/Export/FleetboxExport.proto src/lib/generated
	pbjs -t static-module -o $@ -w es6 --es6 $<

src/lib/generated/export.d.ts: src/lib/generated/export.js
	pbts -o $@ $<