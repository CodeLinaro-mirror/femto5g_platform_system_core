ACLOCAL_AMFLAGS = -I m4

root_sbindir = "/sbin"
root_libdir  = "/lib"

bin_PROGRAMS = usb_composition_switch usbd

# Program to switch USB compositions
# =========================================================
usb_composition_switch_CC = @CC@

usb_composition_switch_SOURCES = usb_composition_switch.c

usb_composition_switch_CFLAGS = -O2 \
                                -g \
                                -Wall \
                                -Wno-unused-parameter \
                                -fstack-protector-strong

# Build USB daemon
# =========================================================
usbd_SOURCES   = usbd.cpp

usbd_CPPFLAGS  = @LIBCUTILS_CFLAGS@ @LIBCUTILS_LIBS@
usbd_CPPFLAGS += -Wall -Wno-unused-parameter -O2 -g \
		-Wno-deprecated-declarations \
		-std=c++14

usbd_LDFLAGS   = @LIBUTILS_LIBS@ @LIBCUTILS_LIBS@


root_sbin_SCRIPTS   = usb_composition
root_sbin_SCRIPTS  += ./debuger/usb_debug
root_sbin_SCRIPTS  += start_usb

progs_list = $(shell find  $(srcdir)/compositions/ -type f)

usb_compositionsdir      = $(root_sbindir)/usb/compositions
usb_compositions_SCRIPTS = $(progs_list)

usbdir      = $(root_sbindir)/usb
usb_SCRIPTS = target

usb_debuggerdir       = $(root_sbindir)/usb/debuger
usb_debugger_SCRIPTS  = ./debuger/debugFiles
usb_debugger_SCRIPTS += ./debuger/help

if USE_SYSTEMD
usb_systemddir    = $(root_libdir)/systemd/system
usb_systemd_DATA  = usb.service
usb_systemd_DATA += usbd.service
endif
