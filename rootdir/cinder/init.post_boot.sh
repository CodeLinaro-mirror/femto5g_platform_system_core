#! /bin/sh
# Copyright (c) 2022-2023 Qualcomm Innovation Center, Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted (subject to the limitations in the
# disclaimer below) provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#
#     * Neither the name of Qualcomm Innovation Center, Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
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

echo -n "Starting init_post_boot: "

echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor

# Enable CPUidle states and auto suspend
echo N > /sys/devices/system/cpu/qcom_lpm/parameters/sleep_disabled
echo mem > /sys/power/autosleep

# set the io-scheduler default to bfq on all mq support devices
echo "bfq" > /sys/class/block/mmcblk0/queue/scheduler
echo "bfq" > /sys/class/block/mmcblk1/queue/scheduler

# update io-scheduler tunables
echo 0 > /sys/class/block/mmcblk0/queue/iosched/slice_idle
echo 0 > /sys/class/block/mmcblk1/queue/iosched/slice_idle

# Disbaling proactive compaction since there is no benefit of higher order
# pages here hence proactive compaction activity would be wasteful.
echo 0 > /proc/sys/vm/compaction_proactiveness

# Setting perf prop to signal postboot completion
setprop vendor.post_boot.parsed 1


# Support for flashless device to communicate to host when device is booted

# ctrl_msg_send - Send a string over an mhi channel
# @FILE:  file descriptor of an open mhi channel
# @MSG: message to send
#
# Returns 0 on success
mhi_ch_sendmsg() {
    local MHI_CH="$1"
    shift 1
    local MSG="$*"
    local ch_fd=$(get_mhi_ch_fd $MHI_CH)

    if [ -z "$ch_fd" ]; then
        echo "MHI channel $MHI_CH is not open" >&2
        return 1
    fi

    eval "echo $MSG >&$ch_fd"
    ret="$?"
    if [ "$ret" -ne 0 ]; then
        echo "Failed to send on $MHI_CH" >&2
    fi

    return $ret
}

MHI_RECV_TIMEOUT=10
# mhi_ch_recvmsg - Receive a single string over an mhi channel
# @MHI_CH:  Path to mhi channel
# @TIMEOUT: (optional) Seconds to receive message in seconds; default MHI_RECV_TIMEOUT
#
# Return 0 if messages was receieved
# If received, received message is printed
mhi_ch_recvmsg() {
    local MHI_CH="$1"
    local TIMEOUT="$2"
    local ch_fd=$(get_mhi_ch_fd $MHI_CH)

    if [ -z "$ch_fd" ]; then
        echo "MHI channel $MHI_CH is not open" >&2
        return 1
    fi

    local ctrl_fd="${READ_FD[$ch_fd]}"
    if [ -z "$ctrl_fd" ]; then
        echo "Read file desc is not open" >&2
        return 1
    fi

    if [ -z "$TIMEOUT" ]; then
        TIMEOUT="$MHI_RECV_TIMEOUT"
    fi

    IFS= read -u$ctrl_fd -t $TIMEOUT -r line
    ret="$?"
    if [ "$ret" -ne 0 ]; then
        echo "Failed to receive on $MHI_CH" >&2
        return $ret
    fi

    echo $line

    return $ret
}

# get_mhi_ch_fd - Find an file descriptor associated with an mhi channel
# @MHI_CH: Path to mhi channel
#
# Returns 0 if a file descriptor was found
# If found, assigned file descriptor for MHI_CH is printed
get_mhi_ch_fd() {
    local MHI_CH="$1"

    for i in ${!MHI_CH_FD[@]}; do
        if [ "${MHI_CH_FD[$i]}" = "$MHI_CH" ]; then
            echo $i
            return 0
        fi
    done

    for open_fd in $(ls -d /proc/$$/fd/*); do
        open_file="$(readlink $open_fd)"
        if [ "$open_file" = "$MHI_CH" ]; then
            ch_fd=$(basename $open_fd)
            echo "$ch_fd"
            return 0
        fi
    done
    return 1
}

# get_new_fd - Locates and prints a new file descriptor
get_new_fd() {
    local ch_fd=0
    while [ -e "/proc/$$/fd/$ch_fd" ]; do
        (( ch_fd += 1 ))
    done
    echo $ch_fd
}

# mhi_ch_open - Open an mhi channel as read/write
# @MHI_CH: Path to mhi channel
#
# Returns 0 if MHI_CH was successfully opened
mhi_ch_open() {
    local MHI_CH="$1"
    local ch_fd=0

    if [ ! -e "$MHI_CH" ]; then
        return 1
    fi

    ch_fd="$(get_mhi_ch_fd $MHI_CH)"
    if [ ! -z "$ch_fd" ]; then
        return 0
    fi

    ch_fd=$(get_new_fd)
    eval "exec $ch_fd<>$MHI_CH" 2>/dev/null
    ret="$?"
    if [ "$ret" -ne 0 ]; then
        echo "Could not open $MHI_CH" >&2
        return $ret
    fi

    cat - <&"$ch_fd" |&
    READ_PID[$ch_fd]="$!"

    ch_rfd=$(get_new_fd)
    eval "exec $ch_rfd<&p" 2>/dev/null
    ret="$?"
    if [ "$ret" -ne 0 ]; then
        echo "Error opening read process" >&2
        return $ret
    fi
    READ_FD[$ch_fd]="$ch_rfd"

    echo "Opened $MHI_CH" >&2
    MHI_CH_FD[$ch_fd]="$MHI_CH"
    return 0
}

# mhi_ch_close - Close an open mhi channel
# @MHI_CH: Path to mhi channel
#
# Returns 0 if file descriptor was able to close
mhi_ch_close() {
    local MHI_CH="$1"
    local ch_fd=$(get_mhi_ch_fd $MHI_CH)

    if [ -z "$ch_fd" ]; then
        echo "MHI channel $MHI_CH is not open" >&2
        return 1
    fi

    if [ ! -z "${READ_PID[$ch_fd]}" ]; then
        kill "${READ_PID[$ch_fd]}"
        READ_PID[$ch_fd]=""
    fi

    if [ ! -z "${READ_FD[$ch_fd]}" ]; then
        eval "exec ${READ_FD[$ch_fd]}>&-"
        READ_FD[$ch_fd]=""
    fi

    eval "exec $ch_fd>&-"
    ret="$?"
    if [ "$ret" -ne 0 ]; then
        echo "Could not close <$ch_fd>" >&2
        return $ret
    fi
    echo "Closed $MHI_CH" >&2

    MHI_CH_FD[$ch_fd]=""
    return 0
}

MHI_CH_RETRIES=300
# wait_for_mhi_ch - Waits on and opens a mhi channel to send/recv messages
# @MHI_CH:  Path to mhi channel
# @RETRIES: (optional) Retry count to open MHI_CH; default MHI_CH_RETRIES
#
# Returns 0 if MHI_CH was found and opened
wait_for_mhi_ch() {
    local MHI_CH="$1"
    local RETRIES="$2"

    if [ -z "$RETRIES" ]; then
        RETRIES="$MHI_CH_RETRIES"
    fi

    mhi_ch_open $MHI_CH
    ret="$?"

    while [ "$ret" -ne 0 ]; do
        if [ "$RETRIES" -le 0 ]; then
           echo "Timeout waiting for $MHI_CH" >&2
           return 1
        fi
        echo "Waiting on $MHI_CH..." >&2
        sleep 1
        (( RETRIES -= 1 ))
        mhi_ch_open $MHI_CH
        ret="$?"
    done

    return 0
}

# Send boot successful message to host server for flashless device
soc_hwplatform=`cat /sys/devices/soc0/hw_platform`
if [ $soc_hwplatform != "IDP" ]; then
    CTRL_DEV="/dev/mhi_pipe_16"
    wait_for_mhi_ch $CTRL_DEV
    ret="$?"
    if [ "$ret" -ne 0 ]; then
        echo "mhi_pipe_16 is not available"
        exit
    fi

    echo "Sending boot successful message"
    mhi_ch_sendmsg $CTRL_DEV BOOT_SUCCESSFUL
    ret="$?"
    if [ "$ret" -ne 0 ]; then
        echo "Could not send BOOT_SUCCESSFUL message"
        exit
    fi

    mhi_ch_close $CTRL_DEV
    ret="$?"
    if [ "$ret" -ne 0 ]; then
        echo "Could not close $CTRL_DEV"
    fi
fi

echo "init_post_boot completed"
