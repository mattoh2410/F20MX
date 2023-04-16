# ========================================================================================
# This is the main script.tcl file, receives from the SCEN_Gen the following 
# parameters:
# ========================================================================================
# Setting the arugments that passed From SCEN_Gen
# ========================================================================================
# By Dr. Idris Skloul Ibrahim

# =======================================================================================
# Printing Messages
# =======================================================================================
# =======================================================================================
# Define Simulation Options
# =======================================================================================
set opt(chan)          Channel/WirelessChannel  	;# channel type
set opt(prop)          Propagation/TwoRayGround 	;# radio-propagation model
set opt(ant)           Antenna/OmniAntenna      	;# Antenna type
set opt(ll)            LL                       	;# link layer type
set opt(ifqlen)        150                        	;# max packet in ifq
set opt(netif)         Phy/WirelessPhy          	;# network interface type
set opt(mac)           Mac/802_11               	;# MAC type
set opt(rp)            DSDV            			;# routing protocol 
set opt(nn)            129                   	   	;# number of nodes
set opt(x)             500                      	;# x coordinates
set opt(y)             500                      	;# y coordinates
set opt(stop)	       150	       	        ;# simulation time
#set opt(cs)            "./CBR-100-1-25-4"         	;# connection scenario
#set opt(ms)            "./scenario-129-matthew"                ;# movement scenario 
set opt(cs)            "./TCP-129-2.5-C50-R4_matthew"               ;# connection scenario
set opt(ms)            "./scenario-129-matthew"       ;# movement scenario
set opt(tr)            Trace.tr                  	;# Output trace file 
if { $opt(rp) == "DSR" } {
    set opt(ifq) CMUPriQueue;	         			;# interface queue type
} else {
    set opt(ifq) Queue/DropTail/PriQueue;			;# interface queue type DropTaiqueue drops the packets when queue is full. CMU priqueue manages packet at priority manner. 
}
# ==============================================================================

set ns_    [new Simulator]

#Trace in new format 
$ns_ use-newtrace

set tracefd     [open $opt(rp)_N$opt(nn)_$opt(tr) w]
$ns_ trace-all $tracefd    

set nf [open nam-out.nam w]
$ns_ namtrace-all-wireless $nf $opt(x) $opt(y)

set wtopo	[new Topography]
$wtopo load_flatgrid $opt(x) $opt(x)

set god_ [create-god $opt(nn)]

set chan_1_ [new $opt(chan)]

# Configure nodes
$ns_ node-config -adhocRouting $opt(rp) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -topoInstance $wtopo \
                 -channel $chan_1_ \
		 -agentTrace ON \
		 -routerTrace ON \
		 -macTrace ON \
		 -movementTrace OFF
		

# =======================================================================================
# Initialise nodes
# =======================================================================================
for {set i 0} {$i < $opt(nn) } {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0
}


# =======================================================================================
# Loading connection scenario
# =======================================================================================

# print 5 white lines
for {set m 0} {$m < 5} {incr m} {
    puts "  "
}
puts "Wait .... Loading connection scenario..."
source $opt(cs)


# =======================================================================================
# Loading movement scenario
# =======================================================================================
# print 5 white lines
for {set m 0} {$m < 5} {incr m} {
    puts "  "
}
puts "Wait ....  Loading movement scenario..."
source $opt(ms)

# =======================================================================================
# Tell nodes when the simulation ends
# =======================================================================================
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop) "$node_($i) reset";
}

$ns_ at $opt(stop).0000001 "stop"
$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"

#proc stop {} {
#    global ns_ tracefd
#    close $tracefd
#}
#Define a 'finish' procedure
proc stop {} {
    global ns_ nf tracefd
    $ns_ flush-trace

    close $tracefd
    close $nf
#    exec nam nam-out-test.nam
#    exec ~/home/isi3/ns-allinone-2.35/bin/nam nam-out-test.nam
#    exec ~/PowerNS2FD/bin/nam nam-out-test.nam
     exec nam nam-out.nam
     exit 0
}

for {set m 0} {$m < 5} {incr m} {
    puts "  "
}

# =======================================================================================
# Start simulation 
# =======================================================================================
#to print the following comments on the user's screen
puts "Simulation Starting Point..."
puts "wait Please ....it takes time to display"
puts "Also, at first glance in the Nam it will show a white screen, just hit Play and  wait"
# print 5 white lines
for {set m 0} {$m < 5} {incr m} {
    puts "  "
}
$ns_ run
