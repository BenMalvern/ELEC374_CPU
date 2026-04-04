## Design Decisions

### Phase 1 – Single-Bus Datapath

The initial datapath design used a **single shared bus architecture**, where only one register or functional unit can drive the bus at any given time. This simplifies wiring and control logic but increases the number of clock cycles required to move data between components.

#### Key Design Choices

- **Bus Arbitration**
  - A **32-to-5 priority encoder** feeds a **32-to-1 multiplexer** to select which register drives the bus.
  - Ensures only one component drives the bus at a time, preventing contention.
  - Provides a scalable and structured approach to datapath control.

- **Register Structure**
  - Standard datapath registers include:
    - `PC` – Program Counter  
    - `IR` – Instruction Register  
    - `MAR` – Memory Address Register  
    - `MDR` – Memory Data Register  
    - `Y` – Temporary ALU operand register  
    - `Z` – ALU result register  
    - `HI` / `LO` – Registers for multiplication and division results  

- **ALU Design**
  - Addition and subtraction are implemented using a **Carry Lookahead Adder (CLA)**.
  - The CLA significantly reduces propagation delay by computing carry signals in parallel.
  - A single unit performs both operations:
    - **Addition:** normal carry propagation  
    - **Subtraction:** via **two’s complement** (invert + carry-in = 1)

- **Multiplication**
  - Implemented using **Booth bit-pair recoding**
  - Reduces the number of partial products compared to shift-and-add multiplication
  - Produces a **64-bit result**:
    - `LO` → lower 32 bits  
    - `HI` → upper 32 bits  

- **Division**
  - Implemented using the **non-restoring division algorithm**
  - Avoids restoring the remainder after each subtraction, improving efficiency
  - Outputs:
    - `LO` → quotient  
    - `HI` → remainder  

- **Memory System**
  - Implemented using **Verilog’s built-in RAM modeling**
  - Supports:
    - **Byte-addressable memory**
    - **Little-endian format**
  - Memory is accessed through `MAR` (address) and `MDR` (data interface)

#### Design Tradeoff

Because only one value can be placed on the bus at a time, intermediate values must be staged through registers such as `Y` and `Z`. This increases the number of control steps required per instruction.

**Key takeaway:**  
This phase emphasizes correctness and simplicity, closely resembling a classic educational CPU datapath while implementing realistic arithmetic algorithms.

---

### Phase 2 – Three-Bus Datapath

To improve performance, the datapath was redesigned using a **three-bus architecture**, enabling parallel data movement and reducing instruction latency.

#### Bus Roles

- **Bus A** → First ALU operand  
- **Bus B** → Second ALU operand  
- **Bus C** → Writeback path  

This allows:

- Two operands to be read simultaneously  
- A result to be written back in the same cycle  
- Fewer micro-operations per instruction  

#### Key Improvements

- **Reduced Dependency on Temporary Registers**
  - The **Y register is no longer required**, since operands are supplied directly via Bus A and Bus B
  - Retained only for compatibility with the Phase 1 design and testing

- **Improved Select & Encode Logic**
  - The select/encode system was updated to support multiple buses:
    - **Bus A driven by `Gra`**
    - **Bus B driven by `Grb`**
  - Enables independent selection of registers for each bus

- **Memory Design Integration**
  - Continued use of **Verilog RAM modeling**
  - Maintains:
    - Byte-addressable structure  
    - Little-endian storage  
  - Clean integration with the datapath through MAR/MDR

- **Parallel Data Flow**
  - Multiple transfers can occur in a single cycle:
    - Register → Bus A  
    - Register → Bus B  
    - ALU result → Bus C → Register  

#### Design Impact

- Reduced number of clock cycles per instruction  
- Increased parallelism  
- Cleaner and more efficient control sequencing  

**Key takeaway:**  
This phase demonstrates a shift toward a more realistic CPU architecture, where performance is improved through parallel data movement rather than additional clock cycles.

---

### Phase 3 – Control Unit

Building on the datapath from the previous phases, this phase introduces the **Control Unit (CU)** to enable full instruction execution.

#### Key Enhancements

- **Full Control Signal Generation**
  - The CU generates all required control signals for:
    - Register transfers  
    - ALU operations  
    - Memory access  
  - Implements instruction execution as a sequence of **timed control steps (T-states)**

- **Enhanced Bus C Functionality**
  - Bus C is now **functionally equivalent to Bus A and Bus B**
  - Initially, register values could not be placed directly onto Bus C:
    - Required routing through the **MDR**, adding extra cycles
  - This limitation was removed, allowing:
    - **Direct register output onto Bus C**
    - Elimination of unnecessary intermediate steps

- **Refined Select & Encode Logic**
  - Updated to support:
    - Independent control of all three buses  
    - Separate signals: `Gra`, `Grb`, `Grc`  
  - Enables flexible routing between registers and buses

- **Instruction Execution Support**
  - Supports full instruction cycle:
    - Fetch  
    - Decode  
    - Execute  
  - Control sequences are aligned with datapath capabilities

#### Design Impact

- Eliminated unnecessary cycles caused by datapath limitations  
- Improved efficiency of instruction execution  
- Greater flexibility in register-to-bus routing  

**Key takeaway:**  
The addition of the Control Unit completes the processor design, transforming the datapath into a fully operational CPU capable of executing structured instruction sequences efficiently.