#! /bin/sh
# Copyright (c) 2022 Qualcomm Innovation Center, Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted (subject to the limitations in the
# disclaimer below) provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#      with the distribution.
#
#    * Neither the name of Qualcomm Innovation Center, Inc. nor the names of its
#      contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.
#
# NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
# GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
# HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

configure_coresight()
{
	#configure STM trace ID
	chmod 664 /sys/bus/coresight/devices/coresight-stm/traceid
	echo 0x10 > /sys/bus/coresight/devices/coresight-stm/traceid

	#give diag application root permission for the device
	chmod 664 /dev/byte-cntr
	chown diag:root /dev/byte-cntr
}

configure_dcc()
{
	echo "++++ $0 -> DCC-Enable START" > /dev/kmsg
        DCC_PATH="/sys/bus/platform/devices/1be2000.dcc_v2"
	if [ ! -d $DCC_PATH ]; then
		echo "++++ $0 -> Not a debug build. No DCC available" > /dev/kmsg
		echo "DCC does not exist on this build."
		return
	fi

	#QDSP
	echo 0xA754520  > $DCC_PATH/config
	echo 0xA751020  > $DCC_PATH/config
	echo 0xA751024  > $DCC_PATH/config
	echo 0xA751030  > $DCC_PATH/config
	echo 0xA751200  > $DCC_PATH/config
	echo 0xA751204  > $DCC_PATH/config
	echo 0xA751208  > $DCC_PATH/config
	echo 0xA754510  > $DCC_PATH/config
	echo 0xA754514  > $DCC_PATH/config
	echo 0xA750010  > $DCC_PATH/config
	echo 0xA750900  > $DCC_PATH/config

	echo 1 > $DCC_PATH/enable

        echo "++++ $0 -> DCC-Enable END" > /dev/kmsg
}

configure_traces()
{
	echo "++++ $0 -> ENABLE-FTRACE START" > /dev/kmsg

	#bail out if its perf config
	if [ ! -d /sys/module/msm_rtb ] ; then
		echo "++++ $0 -> Not a debug build. No RTB" > /dev/kmsg
		return
	fi

	#bail out if ftrace events are not present
	if [ ! -d /sys/kernel/debug/tracing/events ] ; then
		echo "++++ $0 -> Not a debug build. No Tracing events" > /dev/kmsg
		return
	fi

	#IRQs
	echo 1 > /sys/kernel/debug/tracing/events/irq/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/irq_handler_entry/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/irq_handler_exit/enable

	#SoftIRQs
	echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_entry/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_exit/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_raise/enable

	#Scheduler
	echo 1 > /sys/kernel/debug/tracing/events/sched/sched_migrate_task/enable
	echo 1 > /sys/kernel/debug/tracing/events/sched/sched_switch/enable
	echo 1 > /sys/kernel/debug/tracing/events/sched/sched_wakeup/enable

	#Timer
	echo 1 > /sys/kernel/debug/tracing/events/timer/timer_expire_entry/enable
	echo 1 > /sys/kernel/debug/tracing/events/timer/timer_expire_exit/enable

	echo 1 > /sys/kernel/debug/tracing/tracing_on

	echo "++++ $0 -> FTRACE-Enable END" > /dev/kmsg
}

enable_SA410M_debug()
{
	echo "++++ $0 -> SA410M target specific debug file" > /dev/kmsg

	configure_dcc

	configure_traces

	configure_coresight
}
