#Remove previous output files
rm part_*.e* #exodus output files
rm part_*.csv #csv postprocessor files
rm part_*log.txt #terminal output files

#Prevent the computer from going to sleep during these jobs
caffeinate & #& makes this command run in the background

#Run all of the jobs
mpiexec -n 8 ../combined-opt -i part_a.i
mpiexec -n 8 ../combined-opt -i part_b.i
mpiexec -n 8 ../combined-opt -i part_c.i
mpiexec -n 8 ../combined-opt -i part_d.i
mpiexec -n 8 ../combined-opt -i part_e.i
mpiexec -n 8 ../combined-opt -i part_f.i
mpiexec -n 8 ../combined-opt -i part_g.i
mpiexec -n 8 ../combined-opt -i part_h.i

#Allow the computer to sleep again
killall caffeinate
