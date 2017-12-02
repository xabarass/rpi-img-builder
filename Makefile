.PHONY: all
all: build

# Build steps
BUILD_STEPS := rootfs

# Prerequesites for each build step
rootfs-pr:

# Build step rule template
define BUILDSTEP_TEMPLATE
.PHONY: build-$(1) clean-$(1) $$($(1)-pr)
build-$(1): $(1)-pr
	$$(MAKE)  -f $(1).mak build
clean-$(1):
	$$(MAKE)  -f $(1).mak clean
endef

$(foreach step,$(BUILD_STEPS),$(eval $(call BUILDSTEP_TEMPLATE,$(step))))

.PHONY: build
build: $(addprefix build-,$(BUILD_STEPS))

.PHONY: clean
clean: $(addprefix clean-,$(BUILD_STEPS))