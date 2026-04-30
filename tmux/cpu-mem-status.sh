#!/usr/bin/env bash
#
# Outputs raw CPU and memory status data for tmux status composition:
#
#   <cpu_pct> <cpu_color> <mem_pct> <mem_color>
#
# Percentages are always two digits (00-99; 100 is capped to 99).

color_for_cpu_pct() {
    local p=$1
    if   [ "$p" -gt 85 ]; then echo "colour196"
    elif [ "$p" -gt 70 ]; then echo "colour208"
    elif [ "$p" -gt 50 ]; then echo "colour226"
    elif [ "$p" -gt 25 ]; then echo "colour93"
    else                        echo "colour33"
    fi
}

color_for_mem_pct() {
    local p=$1
    if   [ "$p" -gt 98 ]; then echo "colour196"
    elif [ "$p" -gt 94 ]; then echo "colour208"
    elif [ "$p" -gt 89 ]; then echo "colour226"
    elif [ "$p" -gt 79 ]; then echo "colour93"
    else                        echo "colour33"
    fi
}

if [[ "$(uname -s)" == "Linux" ]]; then
    # CPU from 1m load average normalized by logical CPU count.
    read -r cpu_pct mem_pct < <(
        awk '
            FNR==1 && NR==1 {
                load=$1 + 0
                next
            }

            /^processor[[:space:]]*:/ { cpus++ }

            /^MemTotal:/     { mem_total=$2 + 0 }
            /^MemAvailable:/ { mem_avail=$2 + 0 }

            END {
                if (cpus <= 0) cpus = 1
                cp = int((load / cpus) * 100)
                if (cp < 0) cp = 0
                if (cp > 99) cp = 99

                if (mem_total > 0 && mem_avail >= 0) {
                    mp = int(((mem_total - mem_avail) / mem_total) * 100)
                } else {
                    mp = 0
                }
                if (mp < 0) mp = 0
                if (mp > 99) mp = 99

                printf "%d %d\n", cp, mp
            }
        ' /proc/loadavg /proc/cpuinfo /proc/meminfo
    )
else
    # Feed sysctl (3 lines) followed by vm_stat into a single awk pass.
    read -r cpu_pct mem_pct < <(
        { sysctl -n vm.loadavg hw.logicalcpu hw.memsize 2>/dev/null; vm_stat 2>/dev/null; } | awk '
            NR==1 { load=$2 }                          # "{ 1m 5m 15m }"
            NR==2 { cpus=$1 }                          # logical CPU count
            NR==3 { memsize=$1 }                       # total RAM in bytes
            /page size of/ { pgsize=$(NF-1)+0 }        # vm_stat header

            # vm_stat page counters (strip trailing period)
            /Pages active:/                    { v=$NF; gsub(/[^0-9]/,"",v); active=v+0 }
            /Pages inactive:/                  { v=$NF; gsub(/[^0-9]/,"",v); inactive=v+0 }
            /Pages speculative:/               { v=$NF; gsub(/[^0-9]/,"",v); spec=v+0 }
            /Pages wired down:/                { v=$NF; gsub(/[^0-9]/,"",v); wired=v+0 }
            /Pages occupied by compressor:/   { v=$NF; gsub(/[^0-9]/,"",v); compressor=v+0 }
            /Pages purgeable:/                 { v=$NF; gsub(/[^0-9]/,"",v); purgeable=v+0 }
            /File-backed pages:/               { v=$NF; gsub(/[^0-9]/,"",v); filebacked=v+0 }
            /Pages free:/                      { v=$NF; gsub(/[^0-9]/,"",v); free=v+0 }

            END {
                # CPU: load-average / CPU-count, capped at 99
                cp = (cpus > 0) ? int(load / cpus * 100) : 0
                if (cp > 99) cp = 99

                # Memory (same formula as Activity Monitor / tmux-cpu plugin):
                #   used_and_cached = active + inactive + spec + wired + compressor
                #   cached          = purgeable + file-backed
                #   used            = used_and_cached - cached
                #   total           = used_and_cached + free
                used_and_cached = active + inactive + spec + wired + compressor
                cached          = purgeable + filebacked
                used_pages      = used_and_cached - cached
                total_pages     = used_and_cached + free
                mp = (total_pages > 0) ? int(used_pages / total_pages * 100) : 0
                if (mp > 99) mp = 99
                if (mp < 0)  mp = 0

                printf "%d %d\n", cp, mp
            }
        '
    )
fi

cpu_pct=${cpu_pct:-0}
mem_pct=${mem_pct:-0}

cc=$(color_for_cpu_pct "$cpu_pct")
mc=$(color_for_mem_pct "$mem_pct")

printf '%02d %s %02d %s\n' "$cpu_pct" "$cc" "$mem_pct" "$mc"
