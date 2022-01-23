# Design Implementation of APB Master with SRAM as Slave

# Concepts Involved
Digital Design, AMBA Protocol, DFT

# Requirements
Verilog, SystemVerilog, Makefile, C++

# Overview
The implementation routine involves synchronising between the APB Master and APB Slave. The working of both is explained below in detail.


# Control Flow
## Step 1:
The testbench initialises Read or Write transaction with all the necessary control signals.

## Step 2:
Then the testbench carries the stimulus forward to the FIFO which serially feeds the APB Master.

## Step 3:
The APB Master has its own thumb rule of working and once the control is inside the FSM (finite state machine) the master directly communicates with the slave with the slave bridge as a pass through phase that needs to be satisfied.

## Step 4:
The APB slave interface validates the PADDR in the slave and helps in locating the same.

## Step 5:
The slave (SRAM in this case) does the corresponding operations once the pre-requisites are met.


# APB Master
The APB Master is the heart of the whole APB setup. The master is coded in Verilog.

## Basic Signals

PCLK, PRESETn, PREADY, PRDATA are input signals. PCLK is system clock. PADDR, PSELx, PENABLE, PWRITE, PSTRB, PWDATA are output signals. If PRESETn is asserted then master drives PADDR, PWDATA, PSELx, PENABLE,PWRITE and PSTRB to 0(zero). Master decides the next state on the basis of PRESETn, PSELx, PENABLE and PREADY. There are three states IDLE, SETUP and ACCESS.

## Finite State Machine

IDLE is the default state of the APB. when transfer is required the bus moves into the SETUP state, where the appropriate select signal, PSELx is asserted. The bus only remains in the SETUP state for one clock cycle and always moves to the ACCESS state on the next rising edge of the clock. In ACCESS state the enable signal, PENABLE is asserted. The address, write, select, and write data signals must remain stable during the transition from the SETUP to ACCESS state. Exit from the ACCESS state is controlled by the PREADY signal from the slave. If PREADY is held LOW by the slave then the peripheral bus remains in the ACCESS state. If PREADY is driven HIGH by the slave then the ACCESS state is exited and the bus returns to the IDLE state, if no more transfers are required. Alternatively, the bus moves directly to the SETUP state if another transfer follows. Master initiates the Read or Write transaction on the basis of PWRITE signal. It has separate 32 bit wide bus for read and write operation.

<p align="center">
  <img width="400" height="500" src="https://github.com/iPranjalJoshi/AMBA-APB4-Bridge-Interface/blob/151631b1b6a2fc9d76a15dfed00500151e085ed6/StateDiagram.jpg">
</p>


## Interfacing signals between master and fifo

The transaction between Master and FIFO is carried out with the help of interfacing signals namely: PADDR[9:0], PWDATA[31:0], PSELx[1:0], PWRITE, full, empty, completed.
Full and empty are output from FIFO to Master and they indicate whether the FIFO contains data or not. completed signal is input to FIFO from Master which indicates success of previous transaction.

# Sample Output of the Write and Read Transaction

<p align="center">
  <img width="700" height="400" src="https://github.com/iPranjalJoshi/AMBA-APB4-Bridge-Interface/blob/151631b1b6a2fc9d76a15dfed00500151e085ed6/Write+Read.jpg">
</p>


# Citation
If this design and repository is useful to you, please write to me at pranjaljoshi@live.com and consider citing the following:
```
@article{sinha2019design,
  title={Design Implementation Plan for APB Master with SRAM as Slave},
  author={Sinha, Hemlata and Joshi, Pranjal and Patel, Bhavik and Agrawal, Shashank and Rai, Sakshi and Shrivastava, Simi},
  journal={International Journal of Management, Technology And Engineering},
  volume={9},
  number={3},
  pages={5648--5654},
  year={2019},
  publisher={DOI:16.10089.IJMTE.2019.V9I3.19.28148}
}
```
