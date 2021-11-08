#! /bin/sh
# Copyright (c) 2020 The Linux Foundation. All rights reserved.
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

configure_memory_parameters () {
    # Set Memory paremeters.
    #
    # Set per_process_reclaim tuning parameters
    # 2GB 64-bit will have aggressive settings when compared to 1GB 32-bit
    # 1GB and less will use vmpressure range 50-70, 2GB will use 10-70
    # 1GB and less will use 512 pages swap size, 2GB will use 1024
    #
    # Set Low memory killer minfree parameters
    # 32 bit all memory configurations will use 15K series
    # 64 bit up to 2GB with use 14K, and above 2GB will use 18K
    #
    # Set ALMK parameters (usually above the highest minfree values)
    # 32 bit will have 53K & 64 bit will have 81K
    #
    # Set ZCache parameters
    # max_pool_percent is the percentage of memory that the compressed pool
    # can occupy.
    # clear_percent is the percentage of memory at which zcache starts
    # evicting compressed pages. This should be slighlty above adj0 value.
    # clear_percent = (adj0 * 100 / avalible memory in pages)+1
    #
    arch_type=`uname -m`
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}
    MemTotalPg=$((MemTotal / 4))
    adjZeroMinFree=18432
    # Read adj series and set adj threshold for PPR and ALMK.
    # This is required since adj values change from framework to framework.
    adj_series=`cat /sys/module/lowmemorykiller/parameters/adj`
    adj_1="${adj_series#*,}"
    set_almk_ppr_adj="${adj_1%%,*}"
    # PPR and ALMK should not act on HOME adj and below.
    # Normalized ADJ for HOME is 6. Hence multiply by 6
    # ADJ score represented as INT in LMK params, actual score can be in decimal
    # Hence add 6 considering a worst case of 0.9 conversion to INT (0.9*6).
    set_almk_ppr_adj=$(((set_almk_ppr_adj * 6) + 6))
    echo $set_almk_ppr_adj > /sys/module/lowmemorykiller/parameters/adj_max_shift
    echo $set_almk_ppr_adj > /sys/module/process_reclaim/parameters/min_score_adj
    echo 1 > /sys/module/process_reclaim/parameters/enable_process_reclaim
    echo 70 > /sys/module/process_reclaim/parameters/pressure_max
    echo 30 > /sys/module/process_reclaim/parameters/swap_opt_eff
    echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
    if [ "$arch_type" == "aarch64" ] && [ $MemTotal -gt 2097152 ]; then
        echo 10 > /sys/module/process_reclaim/parameters/pressure_min
        echo 1024 > /sys/module/process_reclaim/parameters/per_swap_size
        echo "18432,23040,27648,32256,55296,80640" > /sys/module/lowmemorykiller/parameters/minfree
        echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
        adjZeroMinFree=18432
    elif [ "$arch_type" == "aarch64" ] && [ $MemTotal -gt 1048576 ]; then
        echo 10 > /sys/module/process_reclaim/parameters/pressure_min
        echo 1024 > /sys/module/process_reclaim/parameters/per_swap_size
        echo "14746,18432,22118,25805,40000,55000" > /sys/module/lowmemorykiller/parameters/minfree
        echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
        adjZeroMinFree=14746
    elif [ "$arch_type" == "aarch64" ]; then
        echo 50 > /sys/module/process_reclaim/parameters/pressure_min
        echo 512 > /sys/module/process_reclaim/parameters/per_swap_size
        echo "14746,18432,22118,25805,40000,55000" > /sys/module/lowmemorykiller/parameters/minfree
        echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
        adjZeroMinFree=14746
    else
        echo 50 > /sys/module/process_reclaim/parameters/pressure_min
        echo 512 > /sys/module/process_reclaim/parameters/per_swap_size
        echo "15360,19200,23040,26880,34415,43737" > /sys/module/lowmemorykiller/parameters/minfree
        echo 53059 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
        adjZeroMinFree=15360
    fi
    clearPercent=$((((adjZeroMinFree * 100) / MemTotalPg) + 1))
    echo $clearPercent > /sys/module/zcache/parameters/clear_percent
    echo 30 >  /sys/module/zcache/parameters/max_pool_percent

    # Zram disk - 512MB size
    zram_enable=`getprop ro.config.zram`
    if [ "$zram_enable" == "true" ] && [ -f /dev/block/zram0 ]; then
        echo 536870912 > /sys/block/zram0/disksize
        mkswap /dev/block/zram0
        swapon /dev/block/zram0 -p 32758
    fi

    SWAP_ENABLE_THRESHOLD=1048576
    swap_enable=`getprop ro.config.swap`

    if [ -f /sys/devices/soc0/soc_id ]; then
        soc_id=`cat /sys/devices/soc0/soc_id`
    else
        soc_id=`cat /sys/devices/system/soc/soc0/id`
    fi

    # Enable swap initially only for 1 GB targets
    if [ "$MemTotal" -le "$SWAP_ENABLE_THRESHOLD" ] && [ "$swap_enable" == "true" ]; then
        # Static swiftness
        echo 1 > /proc/sys/vm/swap_ratio_enable
        echo 70 > /proc/sys/vm/swap_ratio

        # Swap disk - 200MB size
        if [ ! -f /data/system/swap/swapfile ]; then
            dd if=/dev/zero of=/data/system/swap/swapfile bs=1m count=200
        fi
        mkswap /data/system/swap/swapfile
        swapon /data/system/swap/swapfile -p 32758
    fi
}

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
    "sm6150" | "qcs610" | "qcs410")

    # Set the default IRQ affinity to the silver cluster. When a
    # CPU is isolated/hotplugged, the IRQ affinity is adjusted
    # to one of the CPU from the default IRQ affinity mask.
    echo 3f > /proc/irq/default_smp_affinity

    if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
    else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
    fi

    case "$soc_id" in
        "355" | "369" | "401")

        # Core control parameters on silver
        echo 0 0 0 0 1 1 > /sys/devices/system/cpu/cpu0/core_ctl/not_preferred
        echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
        echo 60 > /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
        echo 40 > /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
        echo 100 > /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms
        echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster
        echo 8 > /sys/devices/system/cpu/cpu0/core_ctl/task_thres
        echo 0 > /sys/devices/system/cpu/cpu6/core_ctl/enable

        # Disabling Core control parameters on silver
        echo 6 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
        echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable

        # configure governor settings for big cluster
        echo "schedutil" > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
        echo 0 > /sys/devices/system/cpu/cpu6/cpufreq/schedutil/rate_limit_us
        echo 1209600 > /sys/devices/system/cpu/cpu6/cpufreq/schedutil/hispeed_freq
        echo 768000 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq

        # sched_load_boost as -6 is equivalent to target load as 85. It is per cpu tunable.
        echo -6 >  /sys/devices/system/cpu/cpu6/sched_load_boost
        echo -6 >  /sys/devices/system/cpu/cpu7/sched_load_boost
        echo 85 > /sys/devices/system/cpu/cpu6/cpufreq/schedutil/hispeed_load

        # cpuset parameters
        echo 0-5 > /dev/cpuset/background/cpus
        echo 0-5 > /dev/cpuset/system-background/cpus
        ;;
    esac

    case "$soc_id" in
        "406")
        # QCS410
        # configure governor settings for big cluster
        echo "schedutil" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
        echo 0 > /sys/devices/system/cpu/cpu2/cpufreq/schedutil/rate_limit_us
        echo 1209600 > /sys/devices/system/cpu/cpu2/cpufreq/schedutil/hispeed_freq
        echo 768000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq

        # sched_load_boost as -6 is equivalent to target load as 85. It is per cpu tunable.
        echo -6 >  /sys/devices/system/cpu/cpu2/sched_load_boost
        echo -6 >  /sys/devices/system/cpu/cpu3/sched_load_boost
        echo 85 > /sys/devices/system/cpu/cpu2/cpufreq/schedutil/hispeed_load

        ;;
    esac

    # Setting b.L scheduler parameters
    # default sched up and down migrate values are 90 and 85
    echo 65 > /proc/sys/kernel/sched_downmigrate
    echo 71 > /proc/sys/kernel/sched_upmigrate
    # default sched up and down migrate values are 100 and 95
    echo 85 > /proc/sys/kernel/sched_group_downmigrate
    echo 100 > /proc/sys/kernel/sched_group_upmigrate
    echo 1 > /proc/sys/kernel/sched_walt_rotate_big_tasks

    # configure governor settings for little cluster
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/rate_limit_us
    echo 1209600 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_freq
    echo 90 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_load
    echo 576000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

    # sched_load_boost as -10 is equivalent to target load as 90. It is per cpu tunable.
    echo -10 >  /sys/devices/system/cpu/cpu0/sched_load_boost
    echo -10 >  /sys/devices/system/cpu/cpu1/sched_load_boost
    echo -10 >  /sys/devices/system/cpu/cpu2/sched_load_boost
    echo -10 >  /sys/devices/system/cpu/cpu3/sched_load_boost
    echo -10 >  /sys/devices/system/cpu/cpu4/sched_load_boost
    echo -10 >  /sys/devices/system/cpu/cpu5/sched_load_boost

    echo "0:1209600" > /sys/module/cpu_boost/parameters/input_boost_freq
    echo 40 > /sys/module/cpu_boost/parameters/input_boost_ms

    # Set Memory parameters
    configure_memory_parameters

    # Enable bus-dcvs
    for device in /sys/devices/platform/soc
    do
        for cpubw in $device/*cpu-cpu-llcc-bw/devfreq/*cpu-cpu-llcc-bw
        do
            echo "bw_hwmon" > $cpubw/governor
            echo 50 > $cpubw/polling_interval
            echo "2288 4577 7110 9155 12298 14236" > $cpubw/bw_hwmon/mbps_zones
            echo 20 > $cpubw/bw_hwmon/sample_ms
            echo 68 > $cpubw/bw_hwmon/io_percent
            echo 20 > $cpubw/bw_hwmon/hist_memory
            echo 0 > $cpubw/bw_hwmon/hyst_length
            echo 80 > $cpubw/bw_hwmon/down_thres
            echo 0 > $cpubw/bw_hwmon/guard_band_mbps
            echo 250 > $cpubw/bw_hwmon/up_scale
            echo 1600 > $cpubw/bw_hwmon/idle_mbps
        done
        for llccbw in $device/*cpu-llcc-ddr-bw/devfreq/*cpu-llcc-ddr-bw
        do
            echo "bw_hwmon" > $llccbw/governor
            echo 40 > $llccbw/polling_interval
            echo "1144 1720 2086 2929 3879 5931 6881" > $llccbw/bw_hwmon/mbps_zones
            echo 20 > $llccbw/bw_hwmon/sample_ms
            echo 68 > $llccbw/bw_hwmon/io_percent
            echo 20 > $llccbw/bw_hwmon/hist_memory
            echo 0 > $llccbw/bw_hwmon/hyst_length
            echo 80 > $llccbw/bw_hwmon/down_thres
            echo 0 > $llccbw/bw_hwmon/guard_band_mbps
            echo 250 > $llccbw/bw_hwmon/up_scale
            echo 1600 > $llccbw/bw_hwmon/idle_mbps
        done

        #Enable mem_latency governor for L3, LLCC, and DDR scaling
        for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat
        do
            echo "mem_latency" > $memlat/governor
            echo 10 > $memlat/polling_interval
            echo 400 > $memlat/mem_latency/ratio_ceil
        done

        #Enable compute governor for gold latfloor
        for latfloor in $device/*cpu*-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*
        do
            echo "compute" > $latfloor/governor
            echo 10 > $latfloor/polling_interval
        done
    done
    # Turn off scheduler boost at the end
    echo 0 > /proc/sys/kernel/sched_boost
    # Turn on sleep modes.
    echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
    ;;
esac

echo "post boot settings completed"
echo "++++ $0 -> post boot settings completed" > /dev/kmsg
