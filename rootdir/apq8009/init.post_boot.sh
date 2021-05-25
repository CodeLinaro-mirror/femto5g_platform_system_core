#! /bin/sh
# Copyright (c) 2009-2020, The Linux Foundation. All rights reserved.
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

echo -n "Starting post boot settings "
echo "++++ $0 -> Starting post boot settings " > /dev/kmsg

emmc_boot=`getprop ro.boot.emmc`
case "$emmc_boot"
    in "true")
        chown -h system /sys/devices/platform/rs300000a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300000a7.65536/sync_sts
        chown -h system /sys/devices/platform/rs300100a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300100a7.65536/sync_sts
    ;;
esac

if [ -f /sys/devices/soc0/machine ]; then
    target=`cat /sys/devices/soc0/machine | tr [:upper:] [:lower:]`
else
    target=`getprop ro.board.platform`
fi
case "$target" in
    "apq8009" | "msm8909" )
        #if the kernel version >=4.9,use the schedutil governor
        KernelVersionStr=`cat /proc/sys/kernel/osrelease`
        KernelVersionS=${KernelVersionStr:2:2}
        KernelVersionA=${KernelVersionStr:0:1}
        KernelVersionB=${KernelVersionS%.*}
        case $ProductName in
            *robot*)
                echo 1 > /sys/devices/system/cpu/cpu0/online
                # Apply governor settings for 8909
                if [ $KernelVersionA -ge 4 ] && [ $KernelVersionB -ge 9 ]; then
                    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
                    echo 400000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
                    echo 0 > /sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
                    echo 800000 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
                    echo -6 > /sys/devices/system/cpu/cpu0/sched_load_boost
                    echo -6 > /sys/devices/system/cpu/cpu1/sched_load_boost
                    echo -6 > /sys/devices/system/cpu/cpu2/sched_load_boost
                    echo -6 > /sys/devices/system/cpu/cpu3/sched_load_boost
                    echo 85 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
                else
                    # HMP scheduler settings for 8909 similiar to 8916
                    echo 2 > /proc/sys/kernel/sched_window_stats_policy
                    echo 3 > /proc/sys/kernel/sched_ravg_hist_size
                    # disable thermal core_control to update scaling_min_freq
                    echo 0 > /sys/module/msm_thermal/core_control/enabled
                    echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
                    echo 400000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
                    # enable thermal core_control now
                    echo 1 > /sys/module/msm_thermal/core_control/enabled
                    echo "25000" > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
                    echo 90 > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
                    echo 30000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
                    echo 800000 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
                    echo 0 > /sys/devices/system/cpu/cpufreq/interactive/io_is_busy
                    echo "1 400000:85 998400:90 1094400:80" > /sys/devices/system/cpu/cpufreq/interactive/target_loads
                    echo 50000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
                fi
                # Bring up all cores online
                echo 1 > /sys/devices/system/cpu/cpu1/online
                echo 1 > /sys/devices/system/cpu/cpu2/online
                echo 1 > /sys/devices/system/cpu/cpu3/online
                # Enable all LPMs by default
                if [ -f /sys/module/lpm_levels/parameters/sleep_disabled ]; then
                    echo N > /sys/module/lpm_levels/parameters/sleep_disabled
                elif [ -f /sys/module/lpm_levels_legacy/parameters/sleep_disabled ]; then
                    echo N > /sys/module/lpm_levels_legacy/parameters/sleep_disabled
                else
                    echo "can not enable LPMs"
                fi
                for cpubw in /sys/class/devfreq/soc:qcom,cpubw*
                do
                    echo "bw_hwmon" > $cpubw/governor
                done
        ;;
        *)
            echo 1 > /sys/devices/system/cpu/cpu0/online
            # Apply governor settings for 8909
            if [ $KernelVersionA -ge 4 ] && [ $KernelVersionB -ge 9 ]; then
                echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
                echo 800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
                echo 0 > /sys/devices/system/cpu/cpufreq/schedutil/rate_limit_us
                echo 1094400 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq
                echo -6 > /sys/devices/system/cpu/cpu0/sched_load_boost
                echo -6 > /sys/devices/system/cpu/cpu1/sched_load_boost
                echo -6 > /sys/devices/system/cpu/cpu2/sched_load_boost
                echo -6 > /sys/devices/system/cpu/cpu3/sched_load_boost
                echo 70 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_load
            else
                echo 2 > /proc/sys/kernel/sched_window_stats_policy
                echo 3 > /proc/sys/kernel/sched_ravg_hist_size
                # disable thermal core_control to update scaling_min_freq
                echo 0 > /sys/module/msm_thermal/core_control/enabled
                echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
                echo 800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
                echo "25000" > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
                echo 70 > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
                echo 20000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
                echo 1094400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
                echo 0 > /sys/devices/system/cpu/cpufreq/interactive/io_is_busy
                echo "1 400000:85 998400:90 1094400:80" > /sys/devices/system/cpu/cpufreq/interactive/target_loads
                echo 50000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
                # enable thermal core_control now
                echo 1 > /sys/module/msm_thermal/core_control/enabled
            fi
            # Bring up all cores online
            echo 1 > /sys/devices/system/cpu/cpu1/online
            echo 1 > /sys/devices/system/cpu/cpu2/online
            echo 1 > /sys/devices/system/cpu/cpu3/online
            # Enable all LPMs by default
            if [ -f /sys/module/lpm_levels/parameters/sleep_disabled ]; then
                echo N > /sys/module/lpm_levels/parameters/sleep_disabled
            elif [ -f /sys/module/lpm_levels_legacy/parameters/sleep_disabled ]; then
                echo N > /sys/module/lpm_levels_legacy/parameters/sleep_disabled
            else
                echo "can not enable LPMs"
            fi
            for cpubw in /sys/class/devfreq/soc:qcom,cpubw*
            do
                echo "bw_hwmon" > $cpubw/governor
            done
        ;;
        esac
;;
esac

echo "post boot settings completed"
echo "++++ $0 -> post boot settings completed" > /dev/kmsg
