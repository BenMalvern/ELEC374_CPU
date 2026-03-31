## Design Decisions

### Phase 1 – Single Bus Datapath

The initial datapath design used a **single shared bus architecture**. In this design, only one register or functional unit can drive the bus at any given time. This simplifies wiring and control logic but requires more clock cycles to move data between registers.

Key design choices:

- **Bus Arbitration**
  - A **32-to-5 priority encoder** feeds a **32-to-1 multiplexer** to select which register drives the bus.
  - This ensures that only one component can place data on the bus at a time, preventing bus contention.

- **Register Structure**
  - Standard datapath registers include:
    - `PC` – Program Counter
    - `IR` – Instruction Register
    - `MAR` – Memory Address Register
    - `MDR` – Memory Data Register
    - `Y` – Temporary ALU operand register
    - `Z` – ALU result register
    - `HI` and `LO` – Registers used for multiplication and division results

- **ALU Design**
  - Addition and subtraction are implemented using a **Carry Lookahead Adder (CLA)**.
  - A CLA was chosen instead of a ripple-carry adder because it significantly reduces propagation delay by computing carry signals in parallel.
  - The same CLA unit performs both operations:
    - **Addition:** standard carry propagation
    - **Subtraction:** performed using **two's complement arithmetic**, where the second operand is inverted and a carry-in of 1 is applied.

- **Multiplication Implementation**
  - Multiplication was implemented using **Booth bit-pair recoding**, which reduces the number of partial products compared to a naive shift-and-add multiplier.
  - The multiplication operation produces a **64-bit result**:
    - **LO register** stores the **lower 32 bits** of the product
    - **HI register** stores the **upper 32 bits** of the product

- **Division Implementation**
  - Division was implemented using the **non-restoring division algorithm**, which avoids repeatedly restoring the remainder after subtraction.
  - After completion:
    - **LO register** contains the **quotient**
    - **HI register** contains the **remainder**

Because the architecture uses a single bus, intermediate values must often be stored temporarily in registers such as **Y** or **Z**, increasing the number of control steps required for some instructions.

---

### Phase 2 – Three-Bus Datapath

To improve performance and reduce the number of micro-operations required per instruction, the datapath was redesigned to use a **three-bus architecture**.

The buses serve different roles:

- **Bus A**
  - Used to drive the **first operand input of the ALU**

- **Bus B**
  - Used to drive the **second operand input of the ALU**

- **Bus C**
  - Used for **writeback**, allowing the ALU output or other sources to be written directly into destination registers

This design allows **two operands to be read simultaneously while writing back a result in the same cycle**, significantly reducing the number of required control steps.

Key implications of this change:

- The **Y register is no longer strictly required**, since the ALU can receive both operands directly from Bus A and Bus B.
- The register was **kept in the design for compatibility with the Phase 1 datapath and testing purposes**, but it could be removed in a fully optimized implementation.
- Overall instruction execution becomes **faster and more parallel**, as multiple data transfers can occur in a single cycle.

The transition from a **single-bus architecture to a three-bus architecture** represents a common evolution in CPU datapath design, trading slightly increased hardware complexity for significantly improved instruction throughput.


use the verilog built in functionality for simulating ram memory
	ram is designed for byte addressing that is little endian
remove the need for Y register because of 2 buses
for the select encoder, the a bus drives Gra and b bus drives Grb

### Phase 2 – Control unit
bus c is now functionaly the same as bus a and B
	there were issues with getting register outputs onto the c bus (had to use the mdr as an intermediary)
	this led to certain instructions taking an extra cycle. Now that is fixed.
also updated the select and encode logic so that you can choose which bus is used from register input/output
	also added independant Gra, Grb, Grc signals for each bus