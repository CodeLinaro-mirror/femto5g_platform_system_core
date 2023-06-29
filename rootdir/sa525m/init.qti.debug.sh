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

configure_coresight()
{
	chmod 660 /dev/byte-cntr
	chown diag:root /dev/byte-cntr
	chmod 660 /sys/bus/coresight/reset_source_sink
	chown diag:root /sys/bus/coresight/reset_source_sink
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

	#Tsense
	echo 0xc222004 > $DCC_PATH/config
	echo 0xc271014 > $DCC_PATH/config
	echo 0xc2710e0 > $DCC_PATH/config
	echo 0xc2710ec > $DCC_PATH/config
	echo 0xc2710a0 16 > $DCC_PATH/config
	echo 0xc2710e8 > $DCC_PATH/config
	echo 0xc27113c > $DCC_PATH/config

	#Silver LLVM
	echo 0x17b784a0 12 > $DCC_PATH/config
	echo 0x17b78520 > $DCC_PATH/config
	echo 0x17b78588 > $DCC_PATH/config
	echo 0x17b78d90 8 > $DCC_PATH/config
	echo 0x17b79010 6 > $DCC_PATH/config
	echo 0x17b79090 6 > $DCC_PATH/config
	echo 0x17b79a90 4 > $DCC_PATH/config

	#Turing LLM
	#echo 0x32310220 3 > $DCC_PATH/config
	#echo 0x323102a0 3 > $DCC_PATH/config
	#echo 0x323104a0 6 > $DCC_PATH/config
	#echo 0x32310520 > $DCC_PATH/config
	#echo 0x32310588 > $DCC_PATH/config
	#echo 0x32310d90 8 > $DCC_PATH/config
	#echo 0x32311010 6 > $DCC_PATH/config
	#echo 0x32311090 6 > $DCC_PATH/config
	#echo 0x32311a90 3 > $DCC_PATH/config

	# Central Broadcast
	echo 0xec80010 > $DCC_PATH/config
	echo 0xec81000 > $DCC_PATH/config
	#echo 0xec81010 64 > $DCC_PATH/config

	# CORE_HANG_THRESHOLD
	echo 0x17800058 > $DCC_PATH/config
	echo 0x17810058 > $DCC_PATH/config
	echo 0x17820058 > $DCC_PATH/config
	echo 0x17830058 > $DCC_PATH/config
	# CORE_HANG_VALUE
	echo 0x1780005c > $DCC_PATH/config
	echo 0x1781005c > $DCC_PATH/config
	echo 0x1782005c > $DCC_PATH/config
	echo 0x1783005c > $DCC_PATH/config
	#first core hang
	echo 0x1740003c > $DCC_PATH/config
	# CORE_HANG_CONFIG
	echo 0x17800060 > $DCC_PATH/config
	echo 0x17810060 > $DCC_PATH/config
	echo 0x17820060 > $DCC_PATH/config
	echo 0x17830060 > $DCC_PATH/config
	#CORE_HANG_DBG_STS
	echo 0x17800064 > $DCC_PATH/config
	echo 0x17810064 > $DCC_PATH/config
	echo 0x17820064 > $DCC_PATH/config
	echo 0x17830064 > $DCC_PATH/config

	#MIBU Debug registers
	echo 0x17600238 > $DCC_PATH/config

	#GNOC Hang counters
	echo 0x17600404 > $DCC_PATH/config
	echo 0x1760041c 2 > $DCC_PATH/config
	echo 0x17600434 > $DCC_PATH/config
	echo 0x1760043c 2 > $DCC_PATH/config

	#CPRh
	echo 0x17900908 > $DCC_PATH/config
	echo 0x17900c18 > $DCC_PATH/config

	# pll status for all banks and all domains
	# silver PLL
	echo 0x17a80000 0x8007 > $DCC_PATH/config_write
	echo 0x17a80000 > $DCC_PATH/config
	echo 0x17a80028 0x0 > $DCC_PATH/config_write
	echo 0x17a80028 > $DCC_PATH/config
	echo 0x17a80024 0x0 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x40 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x80 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0xc0 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x100 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x140 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x180 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x1c0 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x200 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x240 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x280 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x2c0 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x300 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x340 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x380 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x3c0 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x4000 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a80024 0x0 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a80024 0x0 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a80024 0x0 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config
	echo 0x17a80024 0x40 > $DCC_PATH/config_write
	echo 0x17a80024 > $DCC_PATH/config
	echo 0x17a8003c > $DCC_PATH/config

	# L3 pll
	echo 0x17a84000 0x8007 > $DCC_PATH/config_write
	echo 0x17a84000 > $DCC_PATH/config
	echo 0x17a84018 0x0 > $DCC_PATH/config_write
	echo 0x17a84018 > $DCC_PATH/config
	echo 0x17a84014 0x0 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x40 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x80 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0xc0 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x100 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x140 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x180 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x1c0 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x200 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x240 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x280 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x2c0 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x300 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x340 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x380 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x3c0 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84018 0x4000 > $DCC_PATH/config_write
	echo 0x17a84018 > $DCC_PATH/config
	echo 0x17a84014 0x0 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a84014 0x0 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a84014 0x0 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config
	echo 0x17a84014 0x40 > $DCC_PATH/config_write
	echo 0x17a84014 > $DCC_PATH/config
	echo 0x17a8403c > $DCC_PATH/config

	#rpmh
	echo 0xc201244 > $DCC_PATH/config
	echo 0xc202244 > $DCC_PATH/config

	#L3-ACD
	echo 0x17a94030 > $DCC_PATH/config
	echo 0x17a9408c > $DCC_PATH/config
	echo 0x17a9409c 0x78 > $DCC_PATH/config_write
	echo 0x17a9409c 0x0  > $DCC_PATH/config_write
	echo 0x17a94048 0x1  > $DCC_PATH/config_write
	echo 0x17a94090 0x0  > $DCC_PATH/config_write
	echo 0x17a94090 0x25 > $DCC_PATH/config_write
	echo 0x17a94098 > $DCC_PATH/config
	echo 0x17a94048 0x1D > $DCC_PATH/config_write
	echo 0x17a94090 0x0  > $DCC_PATH/config_write
	echo 0x17a94090 0x25 > $DCC_PATH/config_write
	echo 0x17a94098 > $DCC_PATH/config

	#SILVER-ACD
	echo 0x17a90030 > $DCC_PATH/config
	echo 0x17a9008c > $DCC_PATH/config
	echo 0x17a9009c 0x78 > $DCC_PATH/config_write
	echo 0x17a9009c 0x0  > $DCC_PATH/config_write
	echo 0x17a90048 0x1  > $DCC_PATH/config_write
	echo 0x17a90090 0x0  > $DCC_PATH/config_write
	echo 0x17a90090 0x25 > $DCC_PATH/config_write
	echo 0x17a90098 > $DCC_PATH/config
	echo 0x17a90048 0x1D > $DCC_PATH/config_write
	echo 0x17a90090 0x0  > $DCC_PATH/config_write
	echo 0x17a90090 0x25 > $DCC_PATH/config_write
	echo 0x17a90098 > $DCC_PATH/config

	echo 0x17ba0000 6 > $DCC_PATH/config
	echo 0x17ba0020 5 > $DCC_PATH/config
	echo 0x17ba0050 > $DCC_PATH/config
	echo 0x17ba0070 > $DCC_PATH/config
	echo 0x17ba0080 25 > $DCC_PATH/config
	echo 0x17ba0100 > $DCC_PATH/config
	echo 0x17ba0120 > $DCC_PATH/config
	echo 0x17ba0140 > $DCC_PATH/config
	echo 0x17ba0200 6 > $DCC_PATH/config
	echo 0x17ba0700 > $DCC_PATH/config
	echo 0x17ba070c 3 > $DCC_PATH/config
	echo 0x17ba0780 32 > $DCC_PATH/config
	echo 0x17ba0808 > $DCC_PATH/config
	echo 0x17ba0c48 > $DCC_PATH/config
	echo 0x17ba080c > $DCC_PATH/config
	echo 0x17ba0c4c > $DCC_PATH/config
	echo 0x17ba0810 > $DCC_PATH/config
	echo 0x17ba0c50 > $DCC_PATH/config
	echo 0x17ba0814 > $DCC_PATH/config
	echo 0x17ba0c54 > $DCC_PATH/config
	echo 0x17ba0818 > $DCC_PATH/config
	echo 0x17ba0c58 > $DCC_PATH/config
	echo 0x17ba081c > $DCC_PATH/config
	echo 0x17ba0c5c > $DCC_PATH/config
	echo 0x17ba0824 > $DCC_PATH/config
	echo 0x17ba0c64 > $DCC_PATH/config
	echo 0x17ba0828 > $DCC_PATH/config
	echo 0x17ba0c68 > $DCC_PATH/config
	echo 0x17ba082c > $DCC_PATH/config
	echo 0x17ba0c6c > $DCC_PATH/config
	echo 0x17ba0840 > $DCC_PATH/config
	echo 0x17ba0c80 > $DCC_PATH/config
	echo 0x17ba0844 > $DCC_PATH/config
	echo 0x17ba0c84 > $DCC_PATH/config
	echo 0x17ba0848 > $DCC_PATH/config
	echo 0x17ba0c88 > $DCC_PATH/config
	echo 0x17ba084c > $DCC_PATH/config
	echo 0x17ba0c8c > $DCC_PATH/config
	echo 0x17ba0850 > $DCC_PATH/config
	echo 0x17ba0c90 > $DCC_PATH/config
	echo 0x17ba0854 > $DCC_PATH/config
	echo 0x17ba0c94 > $DCC_PATH/config
	echo 0x17ba0858 > $DCC_PATH/config
	echo 0x17ba0c98 > $DCC_PATH/config
	echo 0x17ba085c > $DCC_PATH/config
	echo 0x17ba0c9c > $DCC_PATH/config
	echo 0x17ba0860 > $DCC_PATH/config
	echo 0x17ba0ca0 > $DCC_PATH/config
	echo 0x17ba0864 > $DCC_PATH/config
	echo 0x17ba0ca4 > $DCC_PATH/config
	echo 0x17ba0868 > $DCC_PATH/config
	echo 0x17ba0ca8 > $DCC_PATH/config
	echo 0x17ba086c > $DCC_PATH/config
	echo 0x17ba0cac > $DCC_PATH/config
	echo 0x17ba0870 > $DCC_PATH/config
	echo 0x17ba0cb0 > $DCC_PATH/config
	echo 0x17ba0874 > $DCC_PATH/config
	echo 0x17ba0cb4 > $DCC_PATH/config
	echo 0x17ba0878 > $DCC_PATH/config
	echo 0x17ba0cb8 > $DCC_PATH/config
	echo 0x17ba087c > $DCC_PATH/config
	echo 0x17ba0cbc > $DCC_PATH/config
	echo 0x17ba3500 80 > $DCC_PATH/config
	echo 0x17ba3a00 3 > $DCC_PATH/config
	echo 0x17ba3aa8 18 > $DCC_PATH/config
	echo 0x17ba3b00 2 > $DCC_PATH/config
	echo 0x17ba3b20 3 > $DCC_PATH/config
	echo 0x17ba3b30 11 > $DCC_PATH/config
	echo 0x17ba3b64 > $DCC_PATH/config
	echo 0x17ba3b00 2 > $DCC_PATH/config
	echo 0x17ba3b20 3 > $DCC_PATH/config
	echo 0x17ba3b30 11 > $DCC_PATH/config
	echo 0x17ba3b70 2 > $DCC_PATH/config

	#APM
	echo 0x17b00000 70 > $DCC_PATH/config

	#PCU -DCC for LPM path
	#Read only registers
	#core#0
	echo 0x17800010 > $DCC_PATH/config
	echo 0x17800024 > $DCC_PATH/config
	echo 0x17800038 6 > $DCC_PATH/config
	echo 0x1780006c > $DCC_PATH/config
	echo 0x178000f0 2 > $DCC_PATH/config
	# core#1
	echo 0x17810010 > $DCC_PATH/config
	echo 0x17810024 > $DCC_PATH/config
	echo 0x17810038 6 > $DCC_PATH/config
	echo 0x1781006c > $DCC_PATH/config
	echo 0x178100f0 2 > $DCC_PATH/config
	# core#2
	echo 0x17820010 > $DCC_PATH/config
	echo 0x17820024 > $DCC_PATH/config
	echo 0x17820038 6 > $DCC_PATH/config
	echo 0x1782006c > $DCC_PATH/config
	echo 0x178200f0 2 > $DCC_PATH/config
	# core#3
	echo 0x17830010 > $DCC_PATH/config
	echo 0x17830024 > $DCC_PATH/config
	echo 0x17830038 6 > $DCC_PATH/config
	echo 0x1783006c > $DCC_PATH/config
	echo 0x178300f0 2 > $DCC_PATH/config
	# L3
	echo 0x17880010 > $DCC_PATH/config
	echo 0x17880024 > $DCC_PATH/config
	echo 0x17880038 3 > $DCC_PATH/config
	#APPS CL
	echo 0x17880044 3 > $DCC_PATH/config
	echo 0x1788006c 5 > $DCC_PATH/config
	# APSS_BOOTFSM_STS
	echo 0x17880084 > $DCC_PATH/config
	# APSS_SILVER_PLL
	echo 0x178800f4 5 > $DCC_PATH/config
	# APSS_ITM_SILVER
	echo 0x17880134 2 > $DCC_PATH/config
	# APSS_SILVER_PWR_CTL_STS
	echo 0x178801b4 > $DCC_PATH/config
	# APSS_CL_PCU_PWR_CTL_STS
	echo 0x178801bc 2 > $DCC_PATH/config
	echo 0x178801c8 > $DCC_PATH/config

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

	echo 0x17d80100 144 > $DCC_PATH/config
	# EPSSSLOW_CLKDOM0
	echo 0x17d9001c > $DCC_PATH/config
	echo 0x17d900dc > $DCC_PATH/config
	echo 0x17d900e8 > $DCC_PATH/config
	echo 0x17d90320 > $DCC_PATH/config
	echo 0x17d90020 > $DCC_PATH/config
	echo 0x17d9034c > $DCC_PATH/config
	echo 0x17d90300 > $DCC_PATH/config
	# EPSSSLOW_CLKDOM1
	echo 0x17d9101c > $DCC_PATH/config
	echo 0x17d910dc > $DCC_PATH/config
	echo 0x17d910e8 > $DCC_PATH/config
	echo 0x17d91320 > $DCC_PATH/config
	echo 0x17d91020 > $DCC_PATH/config
	echo 0x17d9134c > $DCC_PATH/config
	echo 0x17d91300 > $DCC_PATH/config

	echo 0x26822000 2 > $DCC_PATH/config
	echo 0x26824c00 > $DCC_PATH/config
	echo 0x26824d04 2 > $DCC_PATH/config
	echo 0x17d98014 4 > $DCC_PATH/config
	echo 0x17d900e0 > $DCC_PATH/config
	echo 0x17d90410 > $DCC_PATH/config
	echo 0x17d90074 > $DCC_PATH/config
	echo 0x17d90064 > $DCC_PATH/config
	echo 0x17d91074 > $DCC_PATH/config
	echo 0x17d910e0 > $DCC_PATH/config
	echo 0x17d91410 > $DCC_PATH/config

	echo 1 > $DCC_PATH/sw_trig
	echo 1 > $DCC_PATH/enable

	echo "++++ $0 -> DCC-Enable END" > /dev/kmsg

	configure_coresight

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
