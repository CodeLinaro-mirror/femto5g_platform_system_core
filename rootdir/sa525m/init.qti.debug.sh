#! /bin/sh
# Copyright (c) 2022,2023 Qualcomm Innovation Center, Inc. All rights reserved.
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

create_sa525m_stm_stp_policy()
{
	echo "++++ $0 -> create_stp_policy START" > /dev/kmsg
	mkdir /sys/kernel/config/stp-policy/coresight-stm:p_ost.policy
	chmod 660 /sys/kernel/config/stp-policy/coresight-stm:p_ost.policy
	mkdir /sys/kernel/config/stp-policy/coresight-stm:p_ost.policy/default
	chmod 660 /sys/kernel/config/stp-policy/coresight-stm:p_ost.policy/default
	echo 0x10 > /sys/bus/coresight/devices/coresight-stm/traceid
	echo "++++ $0 -> create_stp_policy END" > /dev/kmsg
}

enable_SA525M_debug()
{
	echo "++++ $0 -> SA525M target specific debug file" > /dev/kmsg
	echo "++++ $0 -> DCC-Enable START" > /dev/kmsg
	DCC_PATH="/sys/devices/platform/soc/240ff000.dcc_v2"

	if [ ! -d $DCC_PATH ]; then
		 echo "++++ $0 -> Not a debug build. No DCC available" > /dev/kmsg
		 echo "DCC does not exist on this build."
		 return
	fi

	echo 0 > $DCC_PATH/enable
	echo 1 > $DCC_PATH/config_reset
	echo 7 > $DCC_PATH/curr_list
	echo 1 > $DCC_PATH/hw_trig
	echo cap > $DCC_PATH/func_type
	echo sram > $DCC_PATH/data_sink

	echo 0xb251024 > $DCC_PATH/config
	echo 0xbde1034 > $DCC_PATH/config

	#RPMH_PDC_APSS
	echo 0xb201020 2 > $DCC_PATH/config
	echo 0xb211020 2 > $DCC_PATH/config
	echo 0xb221020 2 > $DCC_PATH/config
	echo 0xb231020 2 > $DCC_PATH/config
	echo 0xb204520 > $DCC_PATH/config

	echo 0xb200010 4 > $DCC_PATH/config
	echo 0xb200900 4 > $DCC_PATH/config
	echo 0xb201030 > $DCC_PATH/config
	echo 0xb201204 2 > $DCC_PATH/config
	echo 0xb201218 2 > $DCC_PATH/config
	echo 0xb20122c 2 > $DCC_PATH/config
	echo 0xb201240 2 > $DCC_PATH/config
	echo 0xb201254 2 > $DCC_PATH/config
	echo 0xb204510 2 > $DCC_PATH/config
	echo 0xb220010 4 > $DCC_PATH/config
	echo 0xb220900 4 > $DCC_PATH/config

	echo 0xB200000 > $DCC_PATH/config
	echo 0xB220000 > $DCC_PATH/config

	#APSS_RSCC
	echo 0x17A20000 > $DCC_PATH/config
	echo 0x17A00004 > $DCC_PATH/config
	echo 0x17A20004 > $DCC_PATH/config
	echo 0x17A10004 > $DCC_PATH/config
	echo 0x17A00008 > $DCC_PATH/config
	echo 0x17A10008 > $DCC_PATH/config
	echo 0x17A20008 > $DCC_PATH/config
	echo 0x17A00010 > $DCC_PATH/config
	echo 0x17A10010 > $DCC_PATH/config
	echo 0x17A20010 > $DCC_PATH/config
	echo 0x17A00014 > $DCC_PATH/config
	echo 0x17A10014 > $DCC_PATH/config
	echo 0x17A20014 > $DCC_PATH/config
	echo 0x17A00018 > $DCC_PATH/config
	echo 0x17A10018 > $DCC_PATH/config
	echo 0x17A20018 > $DCC_PATH/config
	echo 0x17A0000C > $DCC_PATH/config
	echo 0x17A1000C > $DCC_PATH/config
	echo 0x17A2000C > $DCC_PATH/config
	echo 0x17A0001C > $DCC_PATH/config
	echo 0x17A00020 > $DCC_PATH/config
	echo 0x17A00024 > $DCC_PATH/config
	echo 0x17A00028 > $DCC_PATH/config
	echo 0x17A00030 > $DCC_PATH/config
	echo 0x17A10030 > $DCC_PATH/config
	echo 0x17A20030 > $DCC_PATH/config
	echo 0x17A20034 > $DCC_PATH/config
	echo 0x17A20038 > $DCC_PATH/config
	echo 0x17A2003C > $DCC_PATH/config
	echo 0x17A20040 > $DCC_PATH/config
	echo 0x17A20044 > $DCC_PATH/config
	echo 0x17A00048 > $DCC_PATH/config
	echo 0x17A0004C > $DCC_PATH/config
	echo 0x17A000D0 > $DCC_PATH/config
	echo 0x17A000D4 > $DCC_PATH/config
	echo 0x17A000D8 > $DCC_PATH/config
	echo 0x17A00104 > $DCC_PATH/config
	echo 0x17A0010C > $DCC_PATH/config
	echo 0x17A00110 > $DCC_PATH/config
	echo 0x17A20204 > $DCC_PATH/config
	echo 0x17A20224 > $DCC_PATH/config
	echo 0x17A20244 > $DCC_PATH/config
	echo 0x17A20264 > $DCC_PATH/config
	echo 0x17A20284 > $DCC_PATH/config
	echo 0x17A20208 > $DCC_PATH/config
	echo 0x17A20228 > $DCC_PATH/config
	echo 0x17A20248 > $DCC_PATH/config
	echo 0x17A20268 > $DCC_PATH/config
	echo 0x17A20288 > $DCC_PATH/config
	echo 0x17A2020C > $DCC_PATH/config
	echo 0x17A2022C > $DCC_PATH/config
	echo 0x17A2024C > $DCC_PATH/config
	echo 0x17A2026C > $DCC_PATH/config
	echo 0x17A2028C > $DCC_PATH/config
	echo 0x17A00404 > $DCC_PATH/config
	echo 0x17A00408 > $DCC_PATH/config
	echo 0x17A2001C > $DCC_PATH/config
	echo 0x17A20020 > $DCC_PATH/config
	echo 0x17A20024 > $DCC_PATH/config
	echo 0x17A20028 > $DCC_PATH/config
	echo 0x17A20048 > $DCC_PATH/config
	echo 0x17A20400 > $DCC_PATH/config
	echo 0x17A20404 > $DCC_PATH/config
	echo 0x17A20408 > $DCC_PATH/config
	echo 0x17A20460 > $DCC_PATH/config
	echo 0x17A20464 > $DCC_PATH/config
	echo 0x17A20D00 > $DCC_PATH/config
	echo 0x17A20D04 > $DCC_PATH/config
	echo 0x17A20D08 > $DCC_PATH/config
	echo 0x17A20D10 > $DCC_PATH/config
	echo 0x17A20D20 > $DCC_PATH/config
	echo 0x17A20D28 > $DCC_PATH/config
	echo 0x17A20D2C > $DCC_PATH/config
	echo 0x17A20D30 > $DCC_PATH/config
	echo 0x17A20D40 > $DCC_PATH/config


	echo 1 > $DCC_PATH/sw_trig
	echo 1 > $DCC_PATH/enable

	echo "++++ $0 -> DCC-Enable END" > /dev/kmsg

	echo "++++ $0 -> ENABLE-FTRACE START" > /dev/kmsg

	create_sa525m_stm_stp_policy

	#bail out if its perf config
	if [ ! -d /sys/module/msm_rtb ] ; then
		echo "++++ $0 -> Not a debug build. No RTB" > /dev/kmsg
		return
	fi

	# bail out if coresight isn't present
	if [ ! -d /sys/bus/coresight ] ; then
		echo "++++ $0 -> Not a debug build. No Coresight" > /dev/kmsg
		return
	fi

	#bail out if ftrace events are not present
	if [ ! -d /sys/kernel/debug/tracing/events ] ; then
		echo "++++ $0 -> Not a debug build. No Tracing events" > /dev/kmsg
		return
	fi

	echo 0x200000 > /sys/bus/coresight/devices/coresight-tmc-etr/buffer_size
	echo 1 > /sys/bus/coresight/devices/coresight-tmc-etr/enable_sink
	echo coresight-stm > /sys/class/stm_source/ftrace/stm_source_link
	echo 1 > /sys/bus/coresight/devices/coresight-stm/enable_source
	echo 0 > /sys/bus/coresight/devices/coresight-stm/hwevent_enable

	echo 1 >/sys/bus/coresight/devices/coresight-cti-swao_cti/enable
	echo 0 24 >/sys/bus/coresight/devices/coresight-cti-swao_cti/channels/trigin_attach
	echo 0 1 >/sys/bus/coresight/devices/coresight-cti-swao_cti/channels/trigout_attach

	#IRQs
	echo 1 > /sys/kernel/debug/tracing/events/irq/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/irq_handler_entry/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/irq_handler_exit/enable

	#Workqueue
	echo 1 > /sys/kernel/debug/tracing/events/workqueue/enable

	#SoftIRQs
	echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_entry/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_exit/enable
	echo 1 > /sys/kernel/debug/tracing/events/irq/softirq_raise/enable

	#Scheduler
	echo 1 > /sys/kernel/debug/tracing/events/sched/sched_pi_setprio/enable
	echo 1 > /sys/kernel/debug/tracing/events/sched/sched_migrate_task/enable
	echo 1 > /sys/kernel/debug/tracing/events/sched/sched_switch/enable
	echo 1 > /sys/kernel/debug/tracing/events/sched/sched_wakeup/enable
	echo 1 > /sys/kernel/debug/tracing/events/sched/sched_wakeup_new/enable

	#Timer
	echo 1 > /sys/kernel/debug/tracing/events/timer/timer_expire_entry/enable
	echo 1 > /sys/kernel/debug/tracing/events/timer/timer_expire_exit/enable
	echo 1 > /sys/kernel/debug/tracing/events/timer/hrtimer_cancel/enable
	echo 1 > /sys/kernel/debug/tracing/events/timer/hrtimer_expire_entry/enable
	echo 1 > /sys/kernel/debug/tracing/events/timer/hrtimer_expire_exit/enable
	echo 1 > /sys/kernel/debug/tracing/events/timer/hrtimer_init/enable
	echo 1 > /sys/kernel/debug/tracing/events/timer/hrtimer_start/enable

	#Hot-plug
	echo 1 > /sys/kernel/debug/tracing/events/cpuhp/enable

	echo 1 > /sys/kernel/debug/tracing/events/power/cpu_frequency/enable
	echo 1 > /sys/kernel/debug/tracing/events/clk/enable
	echo 1 > /sys/kernel/debug/tracing/events/regulator/enable
	echo 1 > /sys/kernel/debug/tracing/events/rpmh/enable

	echo 1 > /sys/kernel/debug/tracing/tracing_on

	echo "++++ $0 -> FTRACE-Enable END" > /dev/kmsg

}