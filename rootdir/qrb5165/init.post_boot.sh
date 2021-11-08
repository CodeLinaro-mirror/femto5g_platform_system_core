#! /bin/sh

# Copyright (c) 2012-2013, 2016-2020, The Linux Foundation. All rights reserved.
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

echo -n "Starting init_post_boot: "

if [ -f /sys/devices/soc0/machine ]; then
    target=`cat /sys/devices/soc0/machine | tr [:upper:] [:lower:]`
else
    target=`getprop ro.board.platform`
fi

function configure_read_ahead_kb_values() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    # Set 128 for <= 3GB &
    # set 512 for >= 4GB targets.
    if [ $MemTotal -le 3145728 ]; then
        echo 128 > /sys/block/sda/queue/read_ahead_kb
    else
        echo 512 > /sys/block/sda/queue/read_ahead_kb
    fi
}

function disable_core_ctl() {
    if [ -f /sys/devices/system/cpu/cpu0/core_ctl/enable ]; then
        echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable
    else
        echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/disable
    fi
}

function enable_swap() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    SWAP_ENABLE_THRESHOLD=1048576
    swap_enable=`getprop ro.vendor.qti.config.swap`

    # Enable swap initially only for 1 GB targets
    if [ "$MemTotal" -le "$SWAP_ENABLE_THRESHOLD" ] && [ "$swap_enable" == "true" ]; then
        # Static swiftness
        echo 1 > /proc/sys/vm/swap_ratio_enable
        echo 70 > /proc/sys/vm/swap_ratio

        # Swap disk - 200MB size
        if [ ! -f /data/vendor/swap/swapfile ]; then
            dd if=/dev/zero of=/data/vendor/swap/swapfile bs=1m count=200
        fi
        mkswap /data/vendor/swap/swapfile
        swapon /data/vendor/swap/swapfile -p 32758
    fi
}

function configure_memory_parameters() {
    # Set Memory parameters.
    #
    # Set per_process_reclaim tuning parameters
    # All targets will use vmpressure range 50-70,
    # All targets will use 512 pages swap size.
    #
    # Set Low memory killer minfree parameters
    # 32 bit Non-Go, all memory configurations will use 15K series
    # 32 bit Go, all memory configurations will use uLMK + Memcg
    # 64 bit will use Google default LMK series.
    #
    # Set ALMK parameters (usually above the highest minfree values)
    # vmpressure_file_min threshold is always set slightly higher
    # than LMK minfree's last bin value for all targets. It is calculated as
    # vmpressure_file_min = (last bin - second last bin ) + last bin
    #
    # Set allocstall_threshold to 0 for all targets.
    #

if [ "$target" == "kona" ] ; then
      # Enable ZRAM
      configure_zram_parameters
      configure_read_ahead_kb_values
      echo 0 > /proc/sys/vm/page-cluster
      echo 100 > /proc/sys/vm/swappiness
fi
}

case "$target" in
	"kona")

	ddr_type=`od -An -tx /proc/device-tree/memory/ddr_device_type`
	ddr_type4="07"
	ddr_type5="08"

	# Make unbound workqueue not run on cpu0, since all irqs are
	# handled by cpu0 as default, it will preempt the workqueue if
	# the workqueue also run on cpu0, and the latency is out of control.
	echo fe > /sys/devices/virtual/workqueue/cpumask

	# Core control parameters for gold
	echo 2 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
	echo 60 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
	echo 30 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
	echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
	echo 3 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres

	# Core control parameters for gold+
	echo 0 > /sys/devices/system/cpu/cpu7/core_ctl/min_cpus
	echo 60 > /sys/devices/system/cpu/cpu7/core_ctl/busy_up_thres
	echo 30 > /sys/devices/system/cpu/cpu7/core_ctl/busy_down_thres
	echo 100 > /sys/devices/system/cpu/cpu7/core_ctl/offline_delay_ms
	echo 1 > /sys/devices/system/cpu/cpu7/core_ctl/task_thres
	# Controls how many more tasks should be eligible to run on gold CPUs
	# w.r.t number of gold CPUs available to trigger assist (max number of
	# tasks eligible to run on previous cluster minus number of CPUs in
	# the previous cluster).
	#
	# Setting to 1 by default which means there should be at least
	# 4 tasks eligible to run on gold cluster (tasks running on gold cores
	# plus misfit tasks on silver cores) to trigger assitance from gold+.
	echo 1 > /sys/devices/system/cpu/cpu7/core_ctl/nr_prev_assist_thresh

	# Disable Core control on silver
	echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable
	echo 0 > /sys/devices/system/cpu/cpu4/core_ctl/enable
	echo 0 > /sys/devices/system/cpu/cpu7/core_ctl/enable


	# Setting b.L scheduler parameters
	echo 85 85 > /proc/sys/kernel/sched_upmigrate
	echo 75 75 > /proc/sys/kernel/sched_downmigrate
	echo 90 > /proc/sys/kernel/sched_group_upmigrate
	echo 75 > /proc/sys/kernel/sched_group_downmigrate
	echo 1 > /proc/sys/kernel/sched_walt_rotate_big_tasks
	echo 400000000 > /proc/sys/kernel/sched_coloc_downmigrate_ns

	# cpuset parameters
	echo 0-3 > /dev/cpuset/background/cpus
	echo 0-3 > /dev/cpuset/system-background/cpus

	# Turn off scheduler boost at the end
	echo 0 > /proc/sys/kernel/sched_boost

	# configure governor settings for silver cluster
	echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
	echo 0 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us
        if [ `cat /sys/devices/soc0/revision` == "2.0" ]; then
		echo 1248000 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/hispeed_freq
	else
		echo 1228800 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/hispeed_freq
	fi
	echo 518400 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
	echo 1 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/pl

	# configure input boost settings
	echo "0:1324800" > /sys/devices/system/cpu/cpu_boost/input_boost_freq
	echo 120 > /sys/devices/system/cpu/cpu_boost/input_boost_ms

	# configure governor settings for gold cluster
	echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
	echo 0 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/down_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/up_rate_limit_us
	echo 1574400 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/hispeed_freq
	echo 1 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/pl

	# configure governor settings for gold+ cluster
	echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy7/scaling_governor
	echo 0 > /sys/devices/system/cpu/cpufreq/policy7/schedutil/down_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy7/schedutil/up_rate_limit_us
        if [ `cat /sys/devices/soc0/revision` == "2.0" ]; then
		echo 1632000 > /sys/devices/system/cpu/cpufreq/policy7/schedutil/hispeed_freq
	else
		echo 1612800 > /sys/devices/system/cpu/cpufreq/policy7/schedutil/hispeed_freq
	fi
	echo 1 > /sys/devices/system/cpu/cpufreq/policy7/schedutil/pl

	# Enable bus-dcvs
	for device in /sys/devices/platform/soc
	do
	    for cpubw in $device/*cpu-cpu-llcc-bw/devfreq/*cpu-cpu-llcc-bw
	    do
		echo "bw_hwmon" > $cpubw/governor
		echo 40 > $cpubw/polling_interval
		echo "4577 7110 9155 12298 14236 15258" > $cpubw/bw_hwmon/mbps_zones
		echo 4 > $cpubw/bw_hwmon/sample_ms
		echo 50 > $cpubw/bw_hwmon/io_percent
		echo 20 > $cpubw/bw_hwmon/hist_memory
		echo 10 > $cpubw/bw_hwmon/hyst_length
		echo 30 > $cpubw/bw_hwmon/down_thres
		echo 0 > $cpubw/bw_hwmon/guard_band_mbps
		echo 250 > $cpubw/bw_hwmon/up_scale
		echo 1600 > $cpubw/bw_hwmon/idle_mbps
		echo 14236 > $cpubw/max_freq
	    done

	    for llccbw in $device/*cpu-llcc-ddr-bw/devfreq/*cpu-llcc-ddr-bw
	    do
		echo "bw_hwmon" > $llccbw/governor
		echo 40 > $llccbw/polling_interval
		if [ ${ddr_type:4:2} == $ddr_type4 ]; then
			echo "1720 2086 2929 3879 5161 5931 6881 7980" > $llccbw/bw_hwmon/mbps_zones
		elif [ ${ddr_type:4:2} == $ddr_type5 ]; then
			echo "1720 2086 2929 3879 5931 6881 7980 10437" > $llccbw/bw_hwmon/mbps_zones
		fi
		echo 4 > $llccbw/bw_hwmon/sample_ms
		echo 80 > $llccbw/bw_hwmon/io_percent
		echo 20 > $llccbw/bw_hwmon/hist_memory
		echo 10 > $llccbw/bw_hwmon/hyst_length
		echo 30 > $llccbw/bw_hwmon/down_thres
		echo 0 > $llccbw/bw_hwmon/guard_band_mbps
		echo 250 > $llccbw/bw_hwmon/up_scale
		echo 1600 > $llccbw/bw_hwmon/idle_mbps
		echo 6881 > $llccbw/max_freq
	    done

	    for npubw in $device/*npu*-ddr-bw/devfreq/*npu*-ddr-bw
	    do
		echo 1 > /sys/devices/virtual/npu/msm_npu/pwr
		echo "bw_hwmon" > $npubw/governor
		echo 40 > $npubw/polling_interval
		if [ ${ddr_type:4:2} == $ddr_type4 ]; then
			echo "1720 2086 2929 3879 5931 6881 7980" > $npubw/bw_hwmon/mbps_zones
		elif [ ${ddr_type:4:2} == $ddr_type5 ]; then
			echo "1720 2086 2929 3879 5931 6881 7980 10437" > $npubw/bw_hwmon/mbps_zones
		fi
		echo 4 > $npubw/bw_hwmon/sample_ms
		echo 160 > $npubw/bw_hwmon/io_percent
		echo 20 > $npubw/bw_hwmon/hist_memory
		echo 10 > $npubw/bw_hwmon/hyst_length
		echo 30 > $npubw/bw_hwmon/down_thres
		echo 0 > $npubw/bw_hwmon/guard_band_mbps
		echo 250 > $npubw/bw_hwmon/up_scale
		echo 1600 > $npubw/bw_hwmon/idle_mbps
		echo 0 > /sys/devices/virtual/npu/msm_npu/pwr
	    done

	    for npullccbw in $device/*npu*-llcc-bw/devfreq/*npu*-llcc-bw
	    do
		echo 1 > /sys/devices/virtual/npu/msm_npu/pwr
		echo "bw_hwmon" > $npullccbw/governor
		echo 40 > $npullccbw/polling_interval
		echo "4577 7110 9155 12298 14236 15258" > $npullccbw/bw_hwmon/mbps_zones
		echo 4 > $npullccbw/bw_hwmon/sample_ms
		echo 160 > $npullccbw/bw_hwmon/io_percent
		echo 20 > $npullccbw/bw_hwmon/hist_memory
		echo 10 > $npullccbw/bw_hwmon/hyst_length
		echo 30 > $npullccbw/bw_hwmon/down_thres
		echo 0 > $npullccbw/bw_hwmon/guard_band_mbps
		echo 250 > $npullccbw/bw_hwmon/up_scale
		echo 1600 > $npullccbw/bw_hwmon/idle_mbps
		echo 0 > /sys/devices/virtual/npu/msm_npu/pwr
	    done
	    #Enable mem_latency governor for L3 scaling
	    for memlat in $device/*qcom,devfreq-l3/*cpu*-lat/devfreq/*cpu*-lat
	    do
		echo "mem_latency" > $memlat/governor
		echo 10 > $memlat/polling_interval
		echo 400 > $memlat/mem_latency/ratio_ceil
	    done

	    #Enable cdspl3 governor for L3 cdsp nodes
	    for l3cdsp in $device/*qcom,devfreq-l3/*cdsp-l3-lat/devfreq/*cdsp-l3-lat
	    do
                echo "cdspl3" > $l3cdsp/governor
	    done

	    #Enable mem_latency governor for LLCC and DDR scaling
	    for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat
	    do
		echo "mem_latency" > $memlat/governor
		echo 10 > $memlat/polling_interval
		echo 400 > $memlat/mem_latency/ratio_ceil
	    done

	    #Enable compute governor for gold latfloor
	    for latfloor in $device/*cpu-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*
	    do
		echo "compute" > $latfloor/governor
		echo 10 > $latfloor/polling_interval
	    done

	    #Gold L3 ratio ceil
	    for l3gold in $device/*qcom,devfreq-l3/*cpu4-cpu-l3-lat/devfreq/*cpu4-cpu-l3-lat
	    do
		echo 4000 > $l3gold/mem_latency/ratio_ceil
	    done

	    #Prime L3 ratio ceil
	    for l3prime in $device/*qcom,devfreq-l3/*cpu7-cpu-l3-lat/devfreq/*cpu7-cpu-l3-lat
	    do
		echo 20000 > $l3prime/mem_latency/ratio_ceil
	    done

	    #Enable mem_latency governor for qoslat
	    for qoslat in $device/*qoslat/devfreq/*qoslat
	    do
		echo "mem_latency" > $qoslat/governor
		echo 10 > $qoslat/polling_interval
		echo 50 > $qoslat/mem_latency/ratio_ceil
	    done
	done
    echo N > /sys/module/lpm_levels/parameters/sleep_disabled
    configure_memory_parameters
    ;;
esac


if [ -f /sys/devices/system/cpu/cpufreq/ondemand/ ]; then
    chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
    chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
    chown -h system /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
fi

emmc_boot=`getprop vendor.boot.emmc`
case "$emmc_boot"
    in "true")
        chown -h system /sys/devices/platform/rs300000a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300000a7.65536/sync_sts
        chown -h system /sys/devices/platform/rs300100a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300100a7.65536/sync_sts
    ;;
esac

# Let kernel know our image version/variant/crm_version
if [ -f /sys/devices/soc0/select_image ]; then
    image_version="10:"
    image_version+=`getprop ro.build.id`
    image_version+=":"
    image_version+=`getprop ro.build.version.incremental`
    image_variant=`getprop ro.product.name`
    image_variant+="-"
    image_variant+=`getprop ro.build.type`
    oem_version=`getprop ro.build.version.codename`
    echo 10 > /sys/devices/soc0/select_image
    echo $image_version > /sys/devices/soc0/image_version
    echo $image_variant > /sys/devices/soc0/image_variant
    echo $oem_version > /sys/devices/soc0/image_crm_version
fi

# Change console log level as per console config property
console_config=`getprop persist.console.silent.config`
case "$console_config" in
    "1")
        echo "Enable console config to $console_config"
        echo 0 > /proc/sys/kernel/printk
        ;;
esac

# Parse misc partition path and set property
if [ -f /dev/block/bootdevice/by-name/misc ]; then
    misc_link=$(ls -l /dev/block/bootdevice/by-name/misc)
    real_path=${misc_link##*>}
    setprop persist.vendor.mmi.misc_dev_path $real_path
fi

echo "init_post_boot completed"
