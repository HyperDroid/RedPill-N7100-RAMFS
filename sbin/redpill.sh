#!/sbin/busybox sh

mkdir /data/.redpill
chmod 777 /data/.redpill
ccxmlsum=`md5sum /res/customconfig/customconfig.xml | awk '{print $1}'`
if [ "a${ccxmlsum}" != "a`cat /data/.redpill/.ccxmlsum`" ];
then
  rm -f /data/.redpill/*.profile
  rm -f /data/.redpill/.active.profile
  echo ${ccxmlsum} > /data/.redpill/.ccxmlsum
fi
[ ! -f /data/.redpill/default.profile ] && cp /res/customconfig/default.profile /data/.redpill
[ ! -f /data/.redpill/battery.profile ] && cp /res/customconfig/battery.profile /data/.redpill/battery.profile
[ ! -f /data/.redpill/performance.profile ] && cp /res/customconfig/performance.profile /data/.redpill/performance.profile

. /res/customconfig/customconfig-helper
read_defaults
read_config

mount -o remount,rw /system
/sbin/busybox mount -t rootfs -o remount,rw rootfs

#Android Logger
if [ "$logger" == "on" ];then
insmod /lib/modules/logger.ko
fi

# Disable debugging on some modules
if [ "$logger" == "off" ];then
  rm -rf /dev/log
  echo 0 > /sys/module/ump/parameters/ump_debug_level
  echo 0 > /sys/module/mali/parameters/mali_debug_level
  echo 0 > /sys/module/kernel/parameters/initcall_debug
  echo 0 > /sys//module/lowmemorykiller/parameters/debug_level
  echo 0 > /sys/module/wakelock/parameters/debug_mask
  echo 0 > /sys/module/userwakelock/parameters/debug_mask
  echo 0 > /sys/module/earlysuspend/parameters/debug_mask
  echo 0 > /sys/module/alarm/parameters/debug_mask
  echo 0 > /sys/module/alarm_dev/parameters/debug_mask
  echo 0 > /sys/module/binder/parameters/debug_mask
  echo 0 > /sys/module/xt_qtaguid/parameters/debug_mask
fi

#Install STweaks
if [ ! -f /data/.redpill/stweaks-installed ];
then
cd /
rm /system/app/STweaks.apk
rm -f /data/app/com.gokhanmoral.STweaks*
rm -f /data/dalvik-cache/*STweaks.*
rm -f /data/app/com.gokhanmoral.stweaks*
rm -f /data/dalvik-cache/*stweaks*

cat /res/STweaks.apk > /system/app/STweaks.apk
chown 0.0 /system/app/STweaks.apk
chmod 644 /system/app/STweaks.apk
mkdir /data/.redpill
chmod 777 /data/.redpill
echo "1" > /data/.redpill/stweaks-installed
fi

# NTFS automounting
mount -o remount,rw /
mkdir -p /mnt/ntfs
chmod 777 /mnt/ntfs
mount -o mode=0777,gid=1000 -t tmpfs tmpfs /mnt/ntfs
mount -o remount,ro /

# Enable dmesg
if [ -e /proc/sys/kernel/dmesg_restrict ]; then
        echo "0" > /proc/sys/kernel/dmesg_restrict
fi

# Mount Tweaks
mount -o noatime,remount,ro,discard,barrier=0,commit=1,noauto_da_alloc,delalloc /system /system;
mount -o noatime,remount,rw,discard,barrier=0,commit=1,noauto_da_alloc,delalloc /data /data;

# SetCPU Min and Max Freq
echo "1600000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

# Pegasusq Governor Tweaks
echo "75" > /sys/devices/system/cpu/cpufreq/pegasusq/up_threshold
echo "30000" > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_rate
echo "2" > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_down_factor
echo "5" > /sys/devices/system/cpu/cpufreq/pegasusq/down_differential
echo "50" > /sys/devices/system/cpu/cpufreq/pegasusq/freq_step
echo "10" > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_up_rate
echo "20" > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_down_rate
echo "400000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_1_1
echo "300000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_2_0
echo "400000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_2_1
echo "300000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_3_0
echo "400000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_3_1
echo "300000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_4_0
echo "200" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_1_1
echo "100" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_2_0
echo "300" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_2_1
echo "200" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_3_0
echo "400" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_3_1
echo "300" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_4_0
echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/ignore_nice_load
echo "1" > /sys/devices/system/cpu/cpufreq/pegasusq/io_is_busy
echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/max_cpu_lock
echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_lock

# Miscellaneous Kernel tweaks

if [ -e /proc/sys/kernel/msgmni ]; then
        echo "64000" > /proc/sys/kernel/msgmni
fi
if [ -e /proc/sys/kernel/msgmax ]; then
        echo "64000" > /proc/sys/kernel/msgmax
fi
if [ -e /proc/sys/kernel/panic_on_oops ]; then
        echo "1" > /proc/sys/kernel/panic_on_oops
fi
if [ -e /proc/sys/kernel/panic ]; then
        echo "0" > /proc/sys/kernel/panic
fi
if [ -e /proc/sys/kernel/tainted ]; then
        echo "0" > /proc/sys/kernel/tainted
fi
if [ -e /proc/sys/kernel/sched_latency_ns ]; then
        echo "800000" > /proc/sys/kernel/sched_latency_ns
fi
if [ -e /proc/sys/kernel/sched_min_granularity_ns ]; then
        echo "100000" > /proc/sys/kernel/sched_min_granularity_ns
fi
if [ -e /proc/sys/kernel/sched_wakeup_granularity_ns ]; then
        echo "50000" > /proc/sys/kernel/sched_wakeup_granularity_ns
fi
if [ -e /proc/sys/kernel/hung_task_timeout_secs ]; then
        echo "30" > /proc/sys/kernel/hung_task_timeout_secs
fi
if [ -e /proc/sys/kernel/sem ]; then
        echo "500 512000 64 2048" > /proc/sys/kernel/sem
fi

# Miscellaneous VM tweaks

if [ -e /proc/sys/vm/page-cluster ]; then
        echo "4" > /proc/sys/vm/page-cluster
fi
if [ -e /proc/sys/vm/laptop_mode ]; then
        echo "10" > /proc/sys/vm/laptop_mode
fi
if [ -e /proc/sys/vm/dirty_writeback_centisecs ]; then
        echo "2500" > /proc/sys/vm/dirty_writeback_centisecs
fi
if [ -e  /proc/sys/vm/dirty_expire_centisecs ]; then
        echo "1000" > /proc/sys/vm/dirty_expire_centisecs
fi
if [ -e /proc/sys/vm/dirty_background_ratio ]; then
        echo "55" > /proc/sys/vm/dirty_background_ratio
fi
if [ -e /proc/sys/vm/dirty_ratio ]; then
        echo "90" > /proc/sys/vm/dirty_ratio
fi
if [ -e /proc/sys/vm/vfs_cache_pressure ]; then
        echo "20" > /proc/sys/vm/vfs_cache_pressure
fi
if [ -e /proc/sys/vm/overcommit_memory ]; then
        echo "1" > /proc/sys/vm/overcommit_memory
fi
if [ -e  /proc/sys/vm/oom_kill_allocating_task ]; then
        echo "0" > /proc/sys/vm/oom_kill_allocating_task
fi
if [ -e /proc/sys/vm/panic_on_oom ]; then
        echo "0" > /proc/sys/vm/panic_on_oom
fi
if [ -e /proc/sys/vm/swappiness ]; then
        echo "0" > /proc/sys/vm/swappiness
fi
if [ -e /proc/sys/vm/min_free_kbytes ]; then
        echo "1536" > /proc/sys/vm/min_free_kbytes
fi

# Miscellaneous Net tweaks

if [ -e /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts ]; then
        echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
fi
if [ -e /proc/sys/net/ipv4/icmp_echo_ignore_all ]; then
        echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all
fi
if [ -e /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses ]; then
        echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
fi
if [ -e /proc/sys/net/ipv4/tcp_max_syn_backlog ]; then
        echo "4096" > /proc/sys/net/ipv4/tcp_max_syn_backlog
fi
if [ -e /proc/sys/net/ipv4/tcp_timestamps ]; then
        echo "0" > /proc/sys/net/ipv4/tcp_timestamps
fi
if [ -e /proc/sys/net/ipv4/tcp_tw_reuse ]; then
        echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse
fi
if [ -e /proc/sys/net/ipv4/tcp_sack ]; then
        echo "1" > /proc/sys/net/ipv4/tcp_sack
fi
if [ -e /proc/sys/net/ipv4/tcp_ecn ]; then
        echo "0" > /proc/sys/net/ipv4/tcp_ecn
fi
if [ -e /proc/sys/net/ipv4/tcp_dsack ]; then
        echo "1" > /proc/sys/net/ipv4/tcp_dsack
fi
if [ -e /proc/sys/net/ipv4/tcp_tw_recycle ]; then
        echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle
fi
if [ -e /proc/sys/net/ipv4/tcp_window_scaling ]; then
        echo "1" > /proc/sys/net/ipv4/tcp_window_scaling
fi
if [ -e /proc/sys/net/ipv4/tcp_keepalive_probes ]; then
        echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes
fi
if [ -e /proc/sys/net/ipv4/tcp_keepalive_intvl ]; then
        echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl
fi
if [ -e /proc/sys/net/ipv4/tcp_fin_timeout ]; then
        echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout
fi
if [ -e /proc/sys/net/ipv4/tcp_moderate_rcvbuf ]; then
        echo "1" > /proc/sys/net/ipv4/tcp_moderate_rcvbuf
fi
if [ -e /proc/sys/net/core/netdev_max_backlog ]; then
        echo "2500" > /proc/sys/net/core/netdev_max_backlog
fi

# Miscellaneous System tweaks

if [ -e /sys/module/lowmemorykiller/parameters/minfree ]; then
        echo "10240,12288,14336,16384,20480,24576" > /sys/module/lowmemorykiller/parameters/minfree
fi
if [ -e /proc/sys/fs/lease-break-time ]; then
        echo "10" > /proc/sys/fs/lease-break-time
fi

# Boost SD Cards
chmod 777 /sys/block/mmcblk0/queue/read_ahead_kb
echo "2048" > /sys/block/mmcblk0/queue/read_ahead_kb
chmod 777 /sys/block/mmcblk1/queue/read_ahead_kb
echo "2048" > /sys/block/mmcblk1/queue/read_ahead_kb
chmod 777 /sys/devices/virtual/bdi/179:0/read_ahead_kb
echo "2048" > /sys/devices/virtual/bdi/179:0/read_ahead_kb

# apply STweaks defaults
/res/uci.sh apply

# Run Init Scripts
if [ -d /system/etc/init.d ]; then
  /sbin/busybox run-parts /system/etc/init.d
fi

/sbin/busybox mount -t rootfs -o remount,ro rootfs
mount -o remount,ro /system
