$(info MACHINE_ENABLED is $(MACHINE_ENABLED))

# SUBDIRS = $(MACHINE_ENABLED)

# install essential scripts under /etc
root_etcdir      = "/etc/"
root_etc_SCRIPTS = $(MACHINE_ENABLED)/init.post_boot.sh
if LOG_RESTRICT
root_etc_SCRIPTS += logging-restrictions.sh
endif
if ENABLE_DEBUG
root_etc_SCRIPTS += $(MACHINE_ENABLED)/init.qti.debug.sh
endif

install-data-hook:
	chmod  go-x $(DESTDIR)$(root_etcdir)/init.post_boot.sh
if LOG_RESTRICT
	chmod  go-x $(DESTDIR)$(root_etcdir)/logging-restrictions.sh
endif
if ENABLE_DEBUG
	chmod  go-x $(DESTDIR)$(root_etcdir)/init.qti.debug.sh
endif
