#!/bin/bash

set -e

readonly ProtocolName=$1

if [[ $# != 1 ]] ; then printf "\nError: protocol name expected as a parameter\n\n" ; exit 1; fi


n_min=$(head -n 1 ../data/${ProtocolName}_throughput.dat | cut -d " " -f 1)
n_max=$(tail -n 1 ../data/${ProtocolName}_throughput.dat | cut -d " " -f 1)
thr_min=$(head -n 1 ../data/${ProtocolName}_throughput.dat | cut -d " " -f 2)
thr_max=$(tail -n 1 ../data/${ProtocolName}_throughput.dat | cut -d " " -f 2)

B=$(echo "scale=9; (${n_max}-${n_min})/((${n_max}/${thr_max})-(${n_min}/${thr_min}))" | bc -l)
L=$(echo "scale=9; (${n_min}/${thr_min})-((${n_min})/${B})"| bc -l)

gnuplot <<-MYeNDgNUPLOTcOMMAND
	set term png size 900, 700
	set output "../data/throughput_${ProtocolName}_latency_bwidth.png"
	set logscale x 2
	set logscale y 10
	set xlabel "msg size (B)"
	set ylabel "throughput (KB/s)"
	f(x) = x / ( $L + x / $B )
	plot "../data/${ProtocolName}_throughput.dat" using 1:2 title "${ProtocolName} median Throughput" \
			with linespoints, \
		"../data/${ProtocolName}_throughput.dat" using 1:3 title "${ProtocolName} average Throughput" \
			with linespoints, \
  f(x) title "Latency-Bandwidth model with L=$L and B=$B" with linespoints
			clear
MYeNDgNUPLOTcOMMAND