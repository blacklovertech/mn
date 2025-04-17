set ns [new Simulator] 
set tracefile [open aodv_trace.tr w] 
set namfile [open aodv_simulation.nam w] 
$ns trace-all $tracefile 
$ns namtrace-all $namfile 
proc finish {} { 
global ns tracefile namfile 
$ns flush-trace 
close $tracefile 
close $namfile 
exec nam aodv_simulation.nam & 
exit 0 
} 
# Create 10 nodes
set num_nodes 10
for {set i 0} {$i < $num_nodes} {incr i} {
    set n($i) [$ns node]
}

# Create bidirectional links (2Mb bandwidth, 10ms delay)
for {set i 0} {$i < [expr $num_nodes - 1]} {incr i} {
    $ns duplex-link $n($i) $n([expr $i + 1]) 2Mb 10ms DropTail
}

set opt(adhocRouting) DSR/GSR/AODV/DSDV/OLSR

set null0 [new Agent/Null] 
$ns attach-agent $n(0) $udp0 
$ns attach-agent $n(9) $null0 
$ns connect $udp0 $null0 
set cbr [new Application/Traffic/CBR] 
$cbr set packetSize_ 512 
$cbr set interval_ 0.2 
$cbr attach-agent $udp0 
$ns at 1.0 "$cbr start" 
$ns at 4.0 "$cbr stop" 
$ns at 5.0 "finish" 
$ns run
