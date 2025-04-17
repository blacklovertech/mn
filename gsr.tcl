# Create the simulator object
set ns [new Simulator]

# Open a trace file to log the simulation
set tracefile [open gsr_trace.tr w]
$ns trace-all $tracefile

# Open a NAM file to visualize the simulation
set namfile [open gsr_simulation.nam w]
$ns namtrace-all $namfile

# Define the finish procedure
proc finish {} {
    global ns tracefile namfile
    
    $ns flush-trace
    close $tracefile
    close $namfile
    
    exec nam gsr_simulation.nam &
    exit 0
}

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]

# Create links between the nodes (bandwidth, delay, queuing mechanism)
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2Mb 10ms DropTail
$ns duplex-link $n3 $n4 2Mb 10ms DropTail
$ns duplex-link $n4 $n5 2Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n7 $n8 2Mb 10ms DropTail
$ns duplex-link $n8 $n9 2Mb 10ms DropTail

# Enable the GSR routing protocol
set opt(adhocRouting) GSR

# Create a UDP agent and attach it to node 0 (source)
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

# Create a Null agent and attach it to node 9 (destination)
set null0 [new Agent/Null]
$ns attach-agent $n9 $null0

# Connect the UDP agent to the null agent (unicast communication)
$ns connect $udp0 $null0

# Create CBR (Constant Bit Rate) traffic over the UDP connection
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 512
$cbr set interval_ 0.2
$cbr attach-agent $udp0

# Schedule the CBR traffic to start and stop
$ns at 1.0 "$cbr start"
$ns at 4.0 "$cbr stop"

# Schedule the end of the simulation at 5 seconds
$ns at 5.0 "finish"

# Run the simulation
$ns run
