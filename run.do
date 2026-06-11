vlib work
vlog SPI_slave_interface.v SPI_wrapper.v SPI_wrapper_tb.v single_port_sync_ram.v
vsim -voptargs=+acc work.SPI_wrapper_tb
add wave *
add wave -position insertpoint  \
sim:/SPI_wrapper_tb/DUT/SPI_slave/tx_valid \
sim:/SPI_wrapper_tb/DUT/SPI_slave/tx_data \
sim:/SPI_wrapper_tb/DUT/SPI_slave/rx_valid \
sim:/SPI_wrapper_tb/DUT/SPI_slave/rx_data
add wave -position insertpoint  \
sim:/SPI_wrapper_tb/DUT/RAM/read_address \
sim:/SPI_wrapper_tb/DUT/RAM/write_address \
sim:/SPI_wrapper_tb/DUT/RAM/mem
run -all
#quit -sim