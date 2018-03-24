include common.mk

.PHONY: all
all: build

.PHONY: clean $(ROOTFS_DIR).base
clean: delete-rootfs
	@echo "clean"

	if mountpoint -q $(ROOTFS_DIR).base; then \
		umount $(ROOTFS_DIR).base; \
	fi

	# rmdir $(ROOTFS_DIR).base

	rm -rf *.img.tmp *.example plugins.txt

.PHONY: delete-rootfs
delete-rootfs:
	@echo "Delete rootfs"

	ssh $(DEVICE_USER)@$(DEVICE_IP) 'bash -s' < $(BASE_DIR)/device_cleanup.sh $(DEVICE_MOUNT_ROOTFS)

	rm -rf $(wildcard $(ROOTFS_DIR) uInitrd)
	
.PHONY: build
build: packimage

$(ROOTFS_DIR).base: clean
	rm -f plugins.txt

	@echo "making directories"
	mkdir -p $(ROOTFS_DIR).base

	@echo "mounting them"
	mount /dev/mapper/$(LOOP_DEV_NAME) $(ROOTFS_DIR).base

	@echo "Collecting packages"
	for i in plugins/*; do \
		if [ -f $$i/packages -o -f $$i/preinst -o -f $$i/postinst -o -d $$i/files -o -d $$i/patches ]; then \
			echo $$i >> plugins.txt; \
		fi; \
	done

	@echo "Collecting board custom packages"
	for i in plugins/board_custom/$(BOARD_NAME); do \
		if [ -f $$i/packages -o -f $$i/preinst -o -f $$i/postinst -o -d $$i/files -o -d $$i/patches ]; then \
			echo $$i >> plugins.txt; \
		fi; \
	done

	@echo "----- Installing ----"
	@echo "Plugins: $$(cat plugins.txt | xargs | sed -e 's;plugins/;;g' -e 's; ;, ;g')"
	@echo
	@echo -n "2..."
	@sleep 1
	@echo -n "1..."
	@sleep 1
	@echo "OK"

	touch $@

$(ROOTFS_DIR): $(ROOTFS_DIR).base
	rsync --quiet --archive --devices --specials --hard-links --acls --xattrs --sparse $(ROOTFS_DIR).base/* $@
	mkdir -p $@/postinst
	mkdir -p $@/postinstusr
	mkdir -p $@/apt-keys
	
	mkdir -p $@/install_files
	
	touch $@/packages.txt

	if test ! -f $@/etc/resolv.conf; then \
		echo "There is no resolv.conf, copying from this system!"; \
		rm -rf $@/etc/resolv.conf; \
		cp /etc/resolv.conf $@/etc/; \
 	fi

	for i in $$(cat plugins.txt | xargs); do \
		echo "Processing $$i..."; \
		if [ -d $$i/files ]; then \
			echo " - found files ... adding"; \
			cd $$i/files && find . -type f ! -name '*~' -exec cp --preserve=mode,timestamps --parents \{\} $@ \;; \
			cd $(BASE_DIR); \
		fi; \
		if [ -d $$i/install_files ]; then \
			echo " - found install files ... adding"; \
			cd $$i/install_files && find . -type f ! -name '*~' -exec cp --preserve=mode,timestamps --parents \{\} $@/install_files \;; \
			cd $(BASE_DIR); \
		fi; \
		if [ -f $$i/packages ]; then \
			echo " - found packages ... adding"; \
			echo -n "$$(cat $$i/packages | sed -e "s,__ARCH__,$(ARCH),g" | xargs) " >> $@/packages.txt; \
		fi; \
		if [ -f $$i/preinst ]; then \
			chmod +x $$i/preinst; \
			echo " - found preinst ... running"; \
			./$$i/preinst || exit 1; \
		fi; \
		if [ -f $$i/postinst ]; then \
			echo " - found postinst ... adding"; \
			cp $$i/postinst $@/postinst/$$(dirname $$i/postinst | rev | cut -d/ -f1 | rev)-$$(cat /dev/urandom | LC_CTYPE=C tr -dc "a-zA-Z0-9" | head -c 5); \
		fi; \
		if [ -f $$i/postinstusr ]; then \
			echo " - found postinstusr ... adding"; \
			cp $$i/postinstusr $@/postinstusr/$$(dirname $$i/postinstusr | rev | cut -d/ -f1 | rev)-$$(cat /dev/urandom | LC_CTYPE=C tr -dc "a-zA-Z0-9" | head -c 5); \
		fi; \
	done
	chmod +x $@/postinst/*
	chmod +x $@/postinstusr/*
	cp postinstall $@

	ssh $(DEVICE_USER)@$(DEVICE_IP) 'bash -s' < $(BASE_DIR)/device_run.sh $(DEVICE_MOUNT_ROOTFS) $(LOCALE) $(UNAME) $(UPASS) $(RPASS) $(INC_REC)

	for i in $$(cat plugins.txt | xargs); do \
		if [ -d $$i/patches ]; then \
			for j in $$i/patches/*; do \
				patch -p0 -d $@ < $$j; \
			done; \
		fi; \
	done
	
	ssh $(DEVICE_USER)@$(DEVICE_IP) 'bash -s' < $(BASE_DIR)/device_cleanup.sh $(DEVICE_MOUNT_ROOTFS)

	rm -f $@/packages.txt
	rm -f $@/postinstall
	rm -rf $@/postinst/
	rm -rf $@/postinstusr/
	rm -rf $@/apt-keys/
	rm -rf $@/install_files
	touch $@

packimage: $(ROOTFS_DIR)
	@echo "Copying new data to image"

	rm -rf $(ROOTFS_DIR).base/*
	rsync --quiet --archive --devices --specials --hard-links --acls --xattrs --sparse $(ROOTFS_DIR)/* $(ROOTFS_DIR).base/

	sync

	@echo "Unmounting image file"
	umount $(ROOTFS_DIR).base

	@echo "SCION has been added to the image"
