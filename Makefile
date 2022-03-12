mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

# Universal build info mostly from
#     https://developer.apple.com/documentation/xcode/building_a_universal_macos_binary
# Insight on Universal dSYM from
#     https://lists.apple.com/archives/xcode-users/2009/Apr/msg00034.html

MODULE := $(lastword $(subst ., ,$(current_dir)))
PREFIX ?= ~/.hammerspoon
MODPATH = hs
VERSION ?= 0.x
HS_APPLICATION ?= /Applications

# get from https://github.com/asmagill/hammerspoon-config/blob/master/utils/docmaker.lua
# if you want to generate a readme file similar to the ones I generally use. Adjust the copyright in the file and adjust
# this variable to match where you save docmaker.lua relative to your hammerspoon configuration directory
# (usually ~/.hammerspoon)
MARKDOWNMAKER = utils/docmaker.lua

OBJCFILES = ${wildcard src/*.m}
LUAFILES  = ${wildcard src/*.lua}
HEADERS   = ${wildcard src/*.h}

# for compiling each source file into a separate library (see also obj_x86_64/%.s and obj_arm64/%.s below)
DYLIBS  := $(notdir $(OBJCFILES:.m=.dylib))

# for compiling all source files into one library (see also obj_x86_64/%.s and obj_arm64/%.s below)
# DYLIBS  := $(join lib, $(join ${MODULE}, .dylib))

DYLIBS_x86_64   := $(addprefix obj_x86_64/,$(DYLIBS))
DYLIBS_arm64    := $(addprefix obj_arm64/,$(DYLIBS))
DYLIBS_univeral := $(addprefix obj_universal/,$(DYLIBS))

DEBUG_CFLAGS ?= -g

# special vars for uninstall
space :=
space +=
comma := ,
ALLFILES := $(LUAFILES)
ALLFILES += $(DYLIBS)

# CC=clang
CC=@clang
WARNINGS ?= -Weverything -Wno-objc-missing-property-synthesis -Wno-implicit-atomic-properties -Wno-direct-ivar-access -Wno-cstring-format-directive -Wno-padded -Wno-covered-switch-default -Wno-missing-prototypes -Werror-implicit-function-declaration -Wno-documentation-unknown-command -Wno-poison-system-directories
EXTRA_CFLAGS ?= -F$(HS_APPLICATION)/Hammerspoon.app/Contents/Frameworks -DSOURCE_PATH="$(mkfile_path)"
INTEL_CFLAGS ?= -mmacosx-version-min=10.15 -target x86_64-apple-macos10.15
ARM64_CFLAGS ?= -mmacosx-version-min=10.15 -target arm64-apple-macos10.15

# Apple is #^#$@#%^$ inconsistent with Core Foundation types; some are const, others aren't
# WARNINGS += -Wno-incompatible-pointer-types-discards-qualifiers

CFLAGS  += $(DEBUG_CFLAGS) -fmodules -fobjc-arc -DHS_EXTERNAL_MODULE $(WARNINGS) $(EXTRA_CFLAGS)
release: CFLAGS  += -DRELEASE_VERSION=$(VERSION)
releaseWithDocs: CFLAGS  += -DRELEASE_VERSION=$(VERSION)
LDFLAGS += -dynamiclib -undefined dynamic_lookup $(EXTRA_LDFLAGS)

all: verify $(shell uname -m)

echo:
	@echo mkfile_path     = ${mkfile_path}
	@echo current_dir     = ${current_dir}
	@echo MODULE          = ${MODULE}
	@echo PREFIX          = ${PREFIX}
	@echo MODPATH         = ${MODPATH}
	@echo VERSION         = ${VERSION}
	@echo HS_APPLICATION  = ${HS_APPLICATION}
	@echo OBJCFILES       = ${OBJCFILES}
	@echo LUAFILES        = ${LUAFILES}
	@echo HEADERS         = ${HEADERS}
	@echo DYLIBS          = ${DYLIBS}
	@echo DYLIBS_x86_64   = ${DYLIBS_x86_64}
	@echo DYLIBS_arm64    = ${DYLIBS_arm64}
	@echo DYLIBS_univeral = ${DYLIBS_univeral}
	@echo ALLFILES        = ${ALLFILES}
	@echo CFLAGS          = ${CFLAGS}
	@echo LDFLAGS         = ${LDFLAGS}

x86_64: $(DYLIBS_x86_64)

arm64: $(DYLIBS_arm64)

universal: verify x86_64 arm64 $(DYLIBS_univeral)

# for compiling each source file into a separate library
#     (see also DYLIBS above)

obj_x86_64/%.dylib: src/%.m $(HEADERS)
	$(CC) $< $(CFLAGS) $(INTEL_CFLAGS) $(LDFLAGS) -o $@

obj_arm64/%.dylib: src/%.m $(HEADERS)
	$(CC) $< $(CFLAGS) $(ARM64_CFLAGS) $(LDFLAGS) -o $@

# for compiling all source files into one library
#     (see also DYLIBS above)

# obj_x86_64/%.dylib: $(OBJCFILES) $(HEADERS)
# 	$(CC) $(OBJCFILES) $(CFLAGS) $(INTEL_CFLAGS) $(LDFLAGS) -o $@
#
# obj_arm64/%.dylib: $(OBJCFILES) $(HEADERS)
# 	$(CC) $(OBJCFILES) $(CFLAGS) $(ARM64_CFLAGS) $(LDFLAGS) -o $@

# creating the universal dSYM bundle is a total hack because I haven't found a better
# way yet... suggestions welcome
obj_universal/%.dylib: $(DYLIBS_x86_64) $(DYLIBS_arm64)
	lipo -create -output $@ $(subst universal/,x86_64/,$@) $(subst universal/,arm64/,$@)
	mkdir -p $@.dSYM/Contents/Resources/DWARF/
	cp $(subst universal/,x86_64/,$@).dSYM/Contents/Info.plist $@.dSYM/Contents
	lipo -create -output $@.dSYM/Contents/Resources/DWARF/$(subst obj_universal/,,$@) $(subst universal/,x86_64/,$@).dSYM/Contents/Resources/DWARF/$(subst obj_universal/,,$@) $(subst universal/,arm64/,$@).dSYM/Contents/Resources/DWARF/$(subst obj_universal/,,$@)

$(DYLIBS_x86_64): | obj_x86_64

$(DYLIBS_arm64): | obj_arm64

$(DYLIBS_univeral): | obj_universal

obj_x86_64:
	mkdir obj_x86_64

obj_arm64:
	mkdir obj_arm64

obj_universal:
	mkdir obj_universal

verify: $(LUAFILES)
	@if $$(hash lua >& /dev/null); then (luac -p $(LUAFILES) && echo "Lua Compile Verification Passed"); else echo "Skipping Lua Compile Verification"; fi

install: install-$(shell uname -m)

install-lua: $(LUAFILES)
	mkdir -p $(PREFIX)/$(MODPATH)
	install -m 0644 $(LUAFILES) $(PREFIX)/$(MODPATH)
	test -f $(MODULE).docs.json && install -m 0644 $(MODULE).docs.json $(PREFIX)/$(MODPATH) || echo "No $(MODULE).docs.json file to install"
# 	mkdir -p $(PREFIX)/$(MODPATH)/$(MODULE)
# 	install -m 0644 $(LUAFILES) $(PREFIX)/$(MODPATH)/$(MODULE)
# 	test -f docs.json && install -m 0644 docs.json $(PREFIX)/$(MODPATH)/$(MODULE) || echo "No docs.json file to install"

install-x86_64: verify install-lua $(DYLIBS_x86_64)
	mkdir -p $(PREFIX)/$(MODPATH)
	install -m 0644 $(DYLIBS_x86_64) $(PREFIX)/$(MODPATH)
	cp -vpR $(DYLIBS_x86_64:.dylib=.dylib.dSYM) $(PREFIX)/$(MODPATH)
# 	mkdir -p $(PREFIX)/$(MODPATH)/$(MODULE)
# 	install -m 0644 $(DYLIBS_x86_64) $(PREFIX)/$(MODPATH)/$(MODULE)
# 	cp -vpR $(DYLIBS_x86_64:.dylib=.dylib.dSYM) $(PREFIX)/$(MODPATH)/$(MODULE)

install-arm64: verify install-lua $(DYLIBS_arm64)
	mkdir -p $(PREFIX)/$(MODPATH)
	install -m 0644 $(DYLIBS_arm64) $(PREFIX)/$(MODPATH)
	cp -vpR $(DYLIBS_arm64:.dylib=.dylib.dSYM) $(PREFIX)/$(MODPATH)
# 	mkdir -p $(PREFIX)/$(MODPATH)/$(MODULE)
# 	install -m 0644 $(DYLIBS_arm64) $(PREFIX)/$(MODPATH)/$(MODULE)
# 	cp -vpR $(DYLIBS_arm64:.dylib=.dylib.dSYM) $(PREFIX)/$(MODPATH)/$(MODULE)

install-universal: verify install-lua $(DYLIBS_univeral)
	mkdir -p $(PREFIX)/$(MODPATH)
	install -m 0644 $(DYLIBS_univeral) $(PREFIX)/$(MODPATH)
	cp -vpR $(DYLIBS_univeral:.dylib=.dylib.dSYM) $(PREFIX)/$(MODPATH)
# 	mkdir -p $(PREFIX)/$(MODPATH)/$(MODULE)
# 	install -m 0644 $(DYLIBS_univeral) $(PREFIX)/$(MODPATH)/$(MODULE)
# 	cp -vpR $(DYLIBS_univeral:.dylib=.dylib.dSYM) $(PREFIX)/$(MODPATH)/$(MODULE)

uninstall:
	rm -v -f $(PREFIX)/$(MODPATH)/{$(subst $(space),$(comma),$(notdir $(ALLFILES)))}
	(pushd $(PREFIX)/$(MODPATH)/ ; rm -v -fr $(DYLIBS:.dylib=.dylib.dSYM) ; popd)
	rm -v -f $(PREFIX)/$(MODPATH)/$(MODULE).docs.json
	rmdir -p $(PREFIX)/$(MODPATH) ; exit 0
# 	rm -v -f $(PREFIX)/$(MODPATH)/$(MODULE)/{$(subst $(space),$(comma),$(ALLFILES))}
# 	(pushd $(PREFIX)/$(MODPATH)/$(MODULE)/ ; rm -v -fr $(DYLIBS:.dylib=.dylib.dSYM) ; popd)
# 	rm -v -f $(PREFIX)/$(MODPATH)/$(MODULE)/docs.json
# 	rmdir -p $(PREFIX)/$(MODPATH)/$(MODULE) ; exit 0

clean:
	rm -rf obj_x86_64 obj_arm64 obj_universal tmp $(MODULE).docs.json

docs:
	hs -c "require(\"hs.doc\").builder.genJSON([[$(join $(dir $(mkfile_path)), /src)]])" > $(MODULE).docs.json

markdown:
	hs -c "dofile(\"$(MARKDOWNMAKER)\").genMarkdown([[$(join $(dir $(mkfile_path)), /src)]])" > README.tmp.md

markdownWithTOC:
	hs -c "dofile(\"$(MARKDOWNMAKER)\").genMarkdown([[$(join $(dir $(mkfile_path)), /src)]], true)" > README.tmp.md

release: clean all
	HS_APPLICATION=$(HS_APPLICATION) PREFIX=tmp make install-universal ; cd tmp ; tar -cf ../$(MODULE)-v$(VERSION).tar hs ; cd .. ; gzip $(MODULE)-v$(VERSION).tar

releaseWithDocs: clean all docs
	HS_APPLICATION=$(HS_APPLICATION) PREFIX=tmp make install-universal ; cd tmp ; tar -cf ../$(MODULE)-v$(VERSION).tar hs ; cd .. ; gzip $(MODULE)-v$(VERSION).tar

.PHONY: all clean verify install install-lua install-x86_64 install-arm64 install-universal docs markdown markdownWithTOC release releaseWithDocs

