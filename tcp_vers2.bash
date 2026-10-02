#!/bin/bash

set -e

n_min=$(head -n 2 ../data/tcp_throughput.dat | tail -n 1 | cut -d " " -f 1)
n_max=$(tail -n 1 ../data/tcp_throughput.dat | cut -d " " -f 1)
thr_min=$(head -n 2 ../data/tcp_throughput.dat | tail -n 1 | cut -d " " -f 2)
thr_max=$(tail -n 1 ../data/tcp_throughput.dat | cut -d " " -f 2)

B=$(echo "scale=9; (${n_max}-${n_min})/((${n_max}/${thr_max})-(${n_min}/${thr_min}))" | bc -l)
L=$(echo "scale=9; (${n_min}/${thr_min})-((${n_min})/${B})"| bc -l)

gnuplot <<-eNDgNUPLOTcOMMAND
	set term png size 900, 700
	set output "../data/tcp_thr_from_48_latency.png"
	set logscale x 2
	set logscale y 10
	set xlabel "msg size (B)"
	set ylabel "throughput (KB/s)"

	f(x) = x / ( $L + x / $B )
	plot "../data/tcp_throughput.dat" using 1:2 title "tcp median Throughput" \
			with linespoints, \
		"../data/tcp_throughput.dat" using 1:3 title "tcp average Throughput" \
			with linespoints, \
  f(x) title "Latency-Bandwidth model with L=$L and B=$B" with linespoints
			clear
eNDgNUPLOTcOMMAND
