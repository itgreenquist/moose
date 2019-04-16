rm part_a_out.*
rm part_b_out.*
rm part_c_out.*
rm part_d_exo.*
rm part_d_out.*

caffeinate -d &
mpiexec -n 8 ../phase_field-opt -i part_a.i
mpiexec -n 8 ../phase_field-opt -i part_b.i
mpiexec -n 8 ../phase_field-opt -i part_c.i
mpiexec -n 8 ../phase_field-opt -i part_d.i
killall caffeinate
