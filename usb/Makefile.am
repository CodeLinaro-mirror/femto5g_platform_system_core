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

usbd_SOURCES = usbd.cpp

usbd_CPPFLAGS = @LIBCUTILS_CFLAGS@ @LIBCUTILS_LIBS@
usbd_CPPFLAGS += -Wall -Wno-unused-parameter -O2 -g \
		-Wno-deprecated-declarations \
		-std=c++14

usbd_LDFLAGS = @LIBUTILS_LIBS@ @LIBCUTILS_LIBS@
