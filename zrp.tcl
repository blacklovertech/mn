# Create NS2 simulator instance
set ns [new Simulator]

# Open trace and NAM files
set tracefile [open zrp_trace.tr w]
$ns trace-all $tracefile

set namfile [open zrp_simulation.nam w]
$ns namtrace-all $namfile

# Define finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam zrp_simulation.nam &
    exit 0
}

# Set routing protocols (OLSR for Intrazone, AODV for Interzone)
set opt(intrazone_routing) OLSR
set opt(interzone_routing) AODV

# Create 10 nodes
set num_nodes 10
for {set i 0} {$i < $num_nodes} {incr i} {
    set n($i) [$ns node]
}

# Create bidirectional links (2Mb bandwidth, 10ms delay)
for {set i 0} {$i < [expr $num_nodes - 1]} {incr i} {
    $ns duplex-link $n($i) $n([expr $i + 1]) 2Mb 10ms DropTail
}

# Assign routing protocols (OLSR in zone, AODV outside)
for {set i 0} {$i < $num_nodes} {incr i} {
    if {$i < 5} {
        # Nodes 0-4 use OLSR (Intrazone Routing)
        $n($i) set adhocRouting OLSR
    } else {
        # Nodes 5-9 use AODV (Interzone Routing)
        $n($i) set adhocRouting AODV
    }
}

# UDP agent on node 0 (source)
set udp0 [new Agent/UDP]
$ns attach-agent $n(0) $udp0

# Null agent on node 9 (destination)
set null0 [new Agent/Null]
$ns attach-agent $n(9) $null0

# Connect UDP agent to Null agent
$ns connect $udp0 $null0

# CBR Traffic over UDP
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 512
$cbr set interval_ 0.2
$cbr attach-agent $udp0

# Start & stop CBR traffic
$ns at 1.0 "$cbr start"
$ns at 4.0 "$cbr stop"

# End simulation at 5 seconds
$ns at 5.0 "finish"

# Run the simulation
$ns run
