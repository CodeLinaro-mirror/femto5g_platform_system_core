#! /bin/sh
#Copyright (c) 2019-2020, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

enable_qcs40x_debug()
{
	echo "++++ $0 -> Target specific debug file" > /dev/kmsg
	echo "++++ $0 -> DCC-Enable START" > /dev/kmsg
	DCC_PATH="/sys/bus/platform/devices/b2000.dcc_v2"
	if [ ! -d $DCC_PATH ];
	then
		echo "++++ $0 -> Not a debug build. No DCC available" > /dev/kmsg
		echo "DCC does not exist on this build."
		return
	fi

	echo 0 > $DCC_PATH/enable
	echo 2 > $DCC_PATH/curr_list
	echo cap > $DCC_PATH/func_type
	echo sram > $DCC_PATH/data_sink
	echo 1 > $DCC_PATH/config_reset

	#GCC_BIMC
	echo 0x1823000 0x2 > $DCC_PATH/config
	echo 0x1823010 0x1 > $DCC_PATH/config
	echo 0x1823018 0x2 > $DCC_PATH/config
	echo 0x1823024 0x1 > $DCC_PATH/config

	#GCC_SYSTEM_NOC
	echo 0x1826004 0x2 > $DCC_PATH/config

	echo 1 > $DCC_PATH/enable

	echo "++++ $0 -> DCC-Enable END" > /dev/kmsg

        echo "++++ $0 -> ENABLE-FTRACE START" > /dev/kmsg
        #Enable FTRACE_ENABLE on QCS40x
	#bail out if its perf config
	if [ ! -d /sys/module/msm_rtb ]
	then
		echo "++++ $0 -> Not a debug build. No RTB" > /dev/kmsg
		return
	fi

	#bail out if coresight isn't present
	if [ ! -d /sys/bus/coresight ]
	then
		echo "++++ $0 -> Not a debug build. No Coresight" > /dev/kmsg
		return
	fi

	#coresight
	echo sg > /sys/bus/coresight/devices/coresight-tmc-etr/mem_type

	echo 0 > /sys/kernel/debug/tracing/events/enable
	echo mem > /sys/bus/coresight/devices/coresight-tmc-etr/out_mode
	echo 1 > /sys/bus/coresight/devices/coresight-tmc-etr/enable_sink
	echo 1 > /sys/bus/coresight/devices/coresight-stm/enable_source
	echo 1 > /sys/kernel/debug/tracing/tracing_on

	#SoftIRQs
	echo 1 > /sys/kernel/debug/tracing/events/irq/enable
	#echo 1 > /sys/kernel/debug/tracing/events/irq/filter
	echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_entry/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_exit/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_raise/enable
	#IRQs
	echo 1 > /sys/kernel/debug/tracing/events/irq/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/irq_handler_entry/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/irq_handler_exit/enable
	echo "++++ $0 -> FTRACE-Enable END" > /dev/kmsg

	echo "++++ $0 -> END" > /dev/kmsg
}
