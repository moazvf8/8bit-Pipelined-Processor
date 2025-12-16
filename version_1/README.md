# 📘 ELC3030 – 8-bit Pipelined Processor  
### Cairo University – Faculty of Engineering  
**Advanced Processor Architecture – Fall 2025**

## 📌 Project Overview
This project implements a simple **8-bit pipelined processor** based on a RISC-like Instruction Set Architecture (ISA).  
The processor supports **32 instructions**, a **4-register file**, **stack operations**, **interrupt handling**, and both **direct** and **indirect** memory addressing modes.

The design is written entirely in **Verilog**, simulated using **ModelSim / Vivado / EDA Playground**, and verified using waveform analysis.

---

## 🎯 Objectives
- Implement a fully functional **8-bit pipelined processor** (Harvard).
- Design an **FSM-based control unit** with proper control signals.
- Handle **resource sharing**, especially the unified memory module.
- Implement **interrupts** and **stack operations**.
- Verify functionality using **testbenches + waveform outputs**.

---

## 🧩 Processor Architecture

### ✔ Main Components
- **Program Counter (PC)** – 8 bits  
- **4 General-Purpose Registers (R0–R3)**  
  - R3 also functions as **Stack Pointer (SP)**
- **ALU** supporting arithmetic, logical, and shift operations  
- **Condition Code Register (CCR)** — Z, N, C, V flags  
- **Unified 256-byte Memory**  
- **I/O Ports:**  
  - `IN.PORT`  
  - `OUT.PORT`  
  - External non-maskable interrupt pin  
- **FSM Control Unit**  
- **Pipelining Logic** with forwarding (if implemented)

---

## 🖥 Instruction Set Architecture (ISA)
Instructions are **1-byte or 2-bytes**, using the following formats:

### **A-Format (1 byte)**  
Register-to-register ALU, logic, stack, and I/O instructions.

### **B-Format (1 byte)**  
Branch, jump, call, return, and loop instructions.

### **L-Format (1–2 bytes)**  
Load and store with direct and indirect addressing.

The processor supports **all 32 instructions**, including:
- ADD, SUB, AND, OR  
- RLC, RRC, SETC, CLRC  
- PUSH, POP, IN, OUT  
- JZ, JN, JC, JV, JMP, LOOP, CALL, RET, RTI  
- LDM, LDD, STD, LDI, STI  

---

## 🛠 Implementation

### **Languages & Tools**
- **Verilog**  
- **ModelSim / Vivado / EDA Playground**  
- **GTKWave / ModelSim waveform viewer**

## ✔ Project Features Implemented
- [x] Full ISA (32 instructions)  
- [x] Pipelined architecture  
- [x] Stack operations + calls/returns  
- [x] Direct & Indirect memory addressing  
- [x] Interrupt handling & RTI  
- [x] Unified memory design  
- [x] Fully verified with test cases 
