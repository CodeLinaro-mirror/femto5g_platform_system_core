ACLOCAL_AMFLAGS = -I m4

root_sbindir = "/sbin"
root_etcdir  = "/etc"
root_libdir  = "/lib"
root_datadir = "/data"

powerapp_SOURCES = powerapp.c

AM_CFLAGS = -Os \
            -g \
            -Wall \
            -Wno-unused-parameter \
            -D_XOPEN_SOURCE \
            -D_GNU_SOURCE \
            -I../include

powerapp_sbindir             = $(root_sbindir)
powerapp_sbin_PROGRAMS       = powerapp
powerapp_sbin_SCRIPTS        = reboot-bootloader
powerapp_sbin_SCRIPTS       += reboot-recovery

powerapp_userfsdatadir       = $(root_datadir)
powerapp_userfsdata_SCRIPTS  = reboot-cookie

if USE_SYSTEMD
powerapp_sysconfdir       = $(root_etcdir)/initscripts
powerapp_sysconf_SCRIPTS  = reboot
powerapp_sysconf_SCRIPTS += reset_reboot_cookie
powerapp_sysconf_SCRIPTS += shutdown
powerapp_sysconf_SCRIPTS += start_power_config

install-data-hook:
	mv $(DESTDIR)/$(powerapp_sysconfdir)/start_power_config  $(DESTDIR)/$(powerapp_sysconfdir)/power_config

powerapp_systemddir       = $(root_libdir)/systemd/system
powerapp_systemd_DATA     = reset_reboot_cookie.service
powerapp_systemd_DATA    += power_config.service
else
powerapp_sysconfdir       = $(root_etcdir)/init.d
powerapp_sysconf_SCRIPTS  = reboot
powerapp_sysconf_SCRIPTS += reset_reboot_cookie
powerapp_sysconf_SCRIPTS += shutdown
powerapp_sysconf_SCRIPTS += start_power_config

install-data-hook:
	 mv $(DESTDIR)/$(powerapp_sysconfdir)/start_power_config $(DESTDIR)/$(powerapp_sysconfdir)/power_config

endif
