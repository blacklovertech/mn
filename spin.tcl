# Create NS2 simulator instance
set ns [new Simulator]

# Open trace nd NAM files
set tracefile [open spin.tr w]
$ns trace-all $tracefile

set namfile [open spin.nam w]
$ns namtrace-all $namfile

# Define finish procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam spin.nam &
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

# Define UDP agents
set udp0 [new Agent/UDP]
set udp9 [new Agent/UDP]

# Attach agents to nodes
$ns attach-agent $n(0) $udp0
$ns attach-agent $n(9) $udp9

# Connect UDP agents
$ns connect $udp0 $udp9

# Define CBR Traffic
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 512
$cbr0 set interval_ 0.2
$cbr0 attach-agent $udp0

# Define SPIN data negotiation
proc start-SPIN {src dst} {
    global ns
    puts "Node $src sending ADV message to Node $dst"
    $ns at 1.0 "puts \"[get-time] Node $src: Sending ADV message\""
    $ns at 1.5 "puts \"[get-time] Node $dst: Receiving ADV message\""
    $ns at 2.0 "puts \"[get-time] Node $dst: Sending REQ message\""
    $ns at 2.5 "puts \"[get-time] Node $src: Sending DATA message\""
}

# Function to get simulation time
proc get-time {} {
    return "[format "%.2f" [ns now]] sec"
}

# Start SPIN transmission
$ns at 0.5 "start-SPIN 0 9"

# Start & stop CBR traffic
$ns at 1.0 "$cbr0 start"
$ns at 4.0 "$cbr0 stop"

# End simulation at 5 seconds
$ns at 5.0 "finish"

# Run the simulation
$ns run
