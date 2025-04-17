./configure --enable-qemu-system  --prefix=$RISCV --with-arch=rv32imc --with-abi=ilp32d --enable-multilib
#./configure --prefix=$RISCV --with-arch=rv32imac
make
#make build-sim SIM=qemu
#make newlib
#make report-newlib SIM=gdb
