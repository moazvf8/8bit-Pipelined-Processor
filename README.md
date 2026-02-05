# 📘 ELC3030 – 8-bit Pipelined Processor  
**Advanced Processor Architecture (ELC3030)**  
*Cairo University – Faculty of Engineering*  
**Fall 2025**

---

## 📌 Project Overview
This project presents the design and implementation of a **custom 8-bit pipelined RISC processor** based on a simplified Instruction Set Architecture (ISA).  
The processor supports **32 instructions**, a **4-register file**, **stack-based operations**, **interrupt handling**, and both **direct** and **indirect** memory addressing modes.

The entire design is implemented in **Verilog HDL**, simulated using **ModelSim / Vivado / EDA Playground**, and functionally verified through **testbenches and waveform analysis**.

---

## 🎯 Design Objectives
- Design and implement a **fully functional 8-bit Harvard-style pipelined processor**
- Develop an **FSM-based control unit** with accurate control signal generation
- Handle **resource sharing** across pipeline stages
- Support **interrupt handling and stack-based subroutine execution**
- Verify correctness through **comprehensive testbenches and waveform validation**

---

## 🧩 Processor Architecture

### 🔹 Core Components
- **Program Counter (PC)** – 8-bit  
- **4 General-Purpose Registers (R0–R3)**  
  - `R3` additionally functions as the **Stack Pointer (SP)**
- **Arithmetic Logic Unit (ALU)**  
  - Supports arithmetic, logical, and shift operations
- **Condition Code Register (CCR)**  
  - Flags: Zero (Z), Negative (N), Carry (C), Overflow (V)
- **Unified 256-byte Memory**
- **I/O Interface**
  - `IN.PORT`
  - `OUT.PORT`
  - External non-maskable interrupt pin
- **Finite State Machine (FSM) Control Unit**
- **Pipeline Registers & Hazard Handling Logic**
  - Includes data forwarding where applicable

---

## 🖥 Instruction Set Architecture (ISA)

Instructions are encoded using **1-byte or 2-byte formats**, categorized as follows:

### **A-Format (1 byte)**
Register-to-register operations including:
- ALU & logical operations
- Stack manipulation
- I/O instructions

### **B-Format (1 byte)**
Control-flow instructions:
- Conditional & unconditional branches
- Jump, call, return, loop, and interrupt control

### **L-Format (1–2 bytes)**
Memory access instructions supporting:
- Direct addressing
- Indirect addressing

### 🔹 Supported Instructions (32 Total)
- **Arithmetic & Logic:** `ADD`, `SUB`, `AND`, `OR`
- **Bit & Flag Ops:** `RLC`, `RRC`, `SETC`, `CLRC`
- **Stack & I/O:** `PUSH`, `POP`, `IN`, `OUT`
- **Control Flow:** `JZ`, `JN`, `JC`, `JV`, `JMP`, `LOOP`
- **Subroutines & Interrupts:** `CALL`, `RET`, `RTI`
- **Memory Access:** `LDM`, `LDD`, `STD`, `LDI`, `STI`

---

## 🛠 Implementation Details

### 🔧 Languages & Tools
- **Verilog HDL**
- **ModelSim / Vivado / EDA Playground**
- **GTKWave / ModelSim Waveform Viewer**

---

## ✅ Implemented Features
- [x] Complete 32-instruction ISA  
- [x] Pipelined processor datapath  
- [x] Stack-based procedure calls and returns  
- [x] Direct & indirect memory addressing  
- [x] Interrupt handling with `RTI` support  
- [x] Unified memory architecture  
- [x] Functional verification using testbenches and waveform analysis  

---

## 📈 Future Enhancements
- Branch prediction
- Pipeline stall optimization
- Cache-based memory hierarchy
- Extended register file
