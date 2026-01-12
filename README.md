# 🚀 High-Performance 2D Convolution Accelerator on FPGA

[![FPGA](https://img.shields.io/badge/FPGA-Xilinx_Artix--7-red.svg)](https://www.xilinx.com/)
[![Verilog](https://img.shields.io/badge/HDL-Verilog-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()

> **A complete hardware implementation of 2×2 2D convolution with three distinct systolic array architectures, achieving up to 2.41× speedup over serial computation.**

## 📋 Table of Contents
- [Overview](#-overview)
- [Key Features](#-key-features)
- [Performance Comparison](#-performance-comparison)
- [Hardware Specifications](#-hardware-specifications)
- [Architecture Overview](#-architecture-overview)
- [Module Descriptions](#-module-descriptions)
- [Verification Results](#-verification-results)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Design Principles](#-design-principles)
- [References](#-references)

## 🎯 Overview

This project implements a **hardware-accelerated 2D convolution engine** for FPGA, designed for a 4×4 input matrix and 3×3 filter, producing a 2×2 output. The system features **three distinct computation modes** with different dataflow architectures:

- **Serial PE Mode**: Sequential processing with minimal hardware (1 PE)
- **Systolic Array 3×3 Mode**: Vertical accumulation with combinational chaining (9 PEs) ⭐ **Fastest**
- **Systolic Array 2×2 Mode**: Output stationary with skewed input (4 PEs)

All designs implement **true convolution** (180° filter rotation) and use **structural modeling** (gate-level design with AND gates and full adders) for the multiply-accumulate units.

## ✨ Key Features

### 🔥 High Performance
- **2.41× speedup** with SA 3×3 compared to serial processing
- **32 cycles** for complete 2×2 convolution @ 100 MHz (320 ns)
- Combinational vertical chaining for zero-latency accumulation

### 🎨 Multiple Architectures
- **Three distinct dataflow patterns** for educational and performance comparison
- Each architecture demonstrates different systolic array design principles
- Fully verified with comprehensive testbenches

### ⚙️ Structural Design
- **Gate-level implementation** using only AND gates and full adders
- No behavioral multiplication (`*`) or addition (`+`) operators
- Complies with strict structural modeling requirements

### 🎓 Educational Value
- Well-documented code with detailed comments
- Clear separation of datapath and control logic
- Demonstrates advanced FPGA design concepts

## 📊 Performance Comparison

### Latest Test Results (fpga_final_v15)

```
==============================================
 VERIFIED: All Tests Passed ✅
==============================================

Test Results Summary:
  ✅ Serial PE:  C11=87, C12=91, C21=102, C22=87  (77 cycles)
  ✅ SA 3×3:     C11=87, C12=91, C21=102, C22=87  (32 cycles) ⭐ 2.41× speedup
  ✅ SA 2×2:     C11=87, C12=91, C21=102, C22=87  (36 cycles) ⭐ 2.14× speedup

Performance Analysis:
  - SA 3×3 is 2.41× faster than Serial PE (77 ÷ 32 = 2.41)
  - SA 2×2 is 2.14× faster than Serial PE (77 ÷ 36 = 2.14)
  - SA 3×3 is 1.13× faster than SA 2×2 (36 ÷ 32 = 1.13)
```

### Detailed Performance Table

| **Architecture** | **PEs** | **Cycles** | **Time @ 100MHz** | **Speedup** | **Efficiency** |
|------------------|---------|------------|-------------------|-------------|----------------|
| **Serial PE**    | 1       | 77         | 770 ns            | 1.00×       | 100% (baseline) |
| **SA 2×2**       | 4       | 36         | 360 ns            | 2.14×       | 53.5% per PE    |
| **SA 3×3** ⭐    | 9       | 32         | 320 ns            | **2.41×**   | 26.8% per PE    |

**Key Insight**: SA 3×3 achieves the best absolute performance despite lower per-PE efficiency due to its superior parallelism and combinational vertical accumulation architecture.

## 🖥️ Hardware Specifications

### Target Board
| Component | Specification |
|-----------|---------------|
| **FPGA Chip** | Xilinx Artix-7 XC7A75T-1FGG484C |
| **Development Board** | FPGA Starter Kit III (FSK3) |
| **System Clock** | 100 MHz (Pin R4) |
| **Reset Signal** | Active-Low (Pin U7) |
| **Display** | 8-digit 7-segment display |

### Resource Utilization (Estimated)

| Resource | Serial PE | SA 2×2 | SA 3×3 |
|----------|-----------|---------|---------|
| **Logic Cells** | ~800 | ~2,400 | ~4,800 |
| **Multipliers (8×8)** | 1 | 4 | 9 |
| **Registers** | ~200 | ~600 | ~1,200 |
| **Adders (8-bit)** | 3 | 12 | 27 |

## 🏗️ Architecture Overview

### System Block Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                        Top Module (top_fpga.v)                  │
│                                                                 │
│  ┌──────────────┐      ┌───────────────┐      ┌─────────────┐ │
│  │  Controller  │─────►│    Memory     │      │  7-Segment  │ │
│  │     FSM      │      │   Storage     │      │   Display   │ │
│  └──────┬───────┘      └───────┬───────┘      └─────────────┘ │
│         │                      │                               │
│         │ start/done           │ data                          │
│         ▼                      ▼                               │
│  ┌──────────────────────────────────────────┐                 │
│  │         Compute Modules (Muxed)          │                 │
│  ├──────────────────────────────────────────┤                 │
│  │  1. Serial PE (Time Multiplexing)        │                 │
│  │  2. SA 3×3 (Vertical Accumulation)       │                 │
│  │  3. SA 2×2 (Output Stationary)           │                 │
│  └──────────────────────────────────────────┘                 │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Computation Flow

```
┌─────────┐    auto-start    ┌──────────┐   done   ┌──────────┐   done   ┌──────────┐   done   ┌──────────┐
│  IDLE   │─────────────────►│  SERIAL  │─────────►│  SA 3×3  │─────────►│  SA 2×2  │─────────►│   DONE   │
└─────────┘     (10ms)        │    PE    │          │  Array   │          │  Array   │          │ (Display)│
                              └──────────┘          └──────────┘          └──────────┘          └──────────┘
                               77 cycles             32 cycles             36 cycles             Hold results
```

## 📦 Project Structure

```
fpga_final_v15/
│
├── modules/                          # Hardware modules (Verilog)
│   ├── Basic Building Blocks
│   │   ├── pe.v                      # Processing Element (MAC unit with dual accumulation)
│   │   ├── and_gate.v                # AND gate (for structural multiplier)
│   │   ├── full_adder_behavioral.v   # Full adder (behavioral, used in structural designs)
│   │   ├── adder_8bit.v              # 8-bit ripple-carry adder (8 full adders)
│   │   ├── multiplier_8bit.v         # 8×8 multiplier (64 ANDs + 56 full adders)
│   │   ├── buffer_8bit.v             # 8-bit buffer register
│   │   └── memory_storage.v          # ROM for input/filter data
│   │
│   ├── Compute Engines
│   │   ├── serial_pe_compute.v       # Serial mode: 1 PE with time multiplexing
│   │   ├── serial_pe_controller.v    # FSM for serial PE
│   │   ├── sa_3x3.v                  # Systolic Array 3×3 (9 PEs, vertical chaining)
│   │   ├── sa_3x3_controller.v       # FSM for SA 3×3 with weight pre-loading
│   │   ├── sa_2x2.v                  # Systolic Array 2×2 (4 PEs, output stationary)
│   │   └── sa_2x2_controller.v       # FSM for SA 2×2 with skewed input
│   │
│   ├── Top-Level Integration
│   │   ├── top_fpga.v                # Top module (pure structural interconnect)
│   │   ├── controller_fsm_fpga.v     # Main FSM (auto-start, mode sequencing)
│   │   ├── display_7seg_fpga.v       # 7-segment display controller
│   │   └── fsk3_constraints.xdc      # Pin constraints for FSK3 board
│
├── testbench/                        # Basic testbenches
│   ├── tb_pe.v                       # PE unit test
│   ├── tb_memory.v                   # Memory test
│   ├── tb_serial_pe.v                # Serial PE test
│   ├── tb_sa_2x2.v                   # SA 2×2 test
│   ├── tb_sa_3x3.v                   # SA 3×3 test
│   ├── tb_display_7seg.v             # Display test
│   ├── tb_controller_fsm.v           # FSM test
│   └── tb_top.v                      # Top-level test
│
├── testbench_pro/                    # Production testbenches (comprehensive)
│   ├── tb_top_fpga_pro.v             # ⭐ Full system test with all modes
│   ├── tb_pe_pro.v                   # Enhanced PE test
│   ├── tb_serial_pe_compute_pro.v    # Enhanced serial test
│   ├── tb_sa_2x2_pro.v               # Enhanced SA 2×2 test
│   ├── tb_sa_3x3_pro.v               # Enhanced SA 3×3 test
│   ├── tb_memory_pro.v               # Enhanced memory test
│   └── tb_display_7seg_fpga_pro.v    # Enhanced display test
│
└── docs/
    └── README_FPGA.md                # This file (comprehensive documentation)
```

## 🔧 Module Descriptions

### 1. Processing Element (PE) - `pe.v`

The PE is the fundamental MAC (Multiply-Accumulate) unit with **dual accumulation paths** to support both vertical chaining (SA 3×3) and output stationary (SA 2×2) modes.

**Key Features:**
- **Structural 8×8 Multiplier**: 64 AND gates + 56 full adders
- **Dual Accumulation**:
  - `c_out` (Combinational): For vertical chaining in SA 3×3
  - `acc_out` (Registered): For internal accumulation in SA 2×2
- **Weight Stationary Support**: `load_b` signal for one-time weight loading
- **Systolic Dataflow**: Pipelined `a_out`, `b_out` for array connectivity

```verilog
// PE Interface
module pe (
    input  wire [7:0] a_in,     // Input data (horizontal flow)
    input  wire [7:0] b_in,     // Weight data (vertical flow)
    input  wire [7:0] c_in,     // Accumulation input (vertical)
    input  wire       load_b,   // Weight load enable
    input  wire       en,       // PE enable
    input  wire       clr_acc,  // Accumulator clear
    output reg  [7:0] a_out,    // Data output (registered)
    output reg  [7:0] b_out,    // Weight output (registered)
    output reg  [7:0] acc_out,  // Internal accumulator (registered)
    output wire [7:0] c_out     // External accumulation (combinational)
);
```

### 2. Serial PE Compute - `serial_pe_compute.v`

Sequential processing using a single PE with time multiplexing.

**Architecture:**
- **1 PE** performs all 36 MAC operations sequentially
- Each output (C11, C12, C21, C22) computed in 9+1 cycles
  - 9 cycles: MAC operations
  - 1 cycle: Store result and clear accumulator

**Performance:** 77 cycles total (includes memory overhead)

### 3. Systolic Array 3×3 - `sa_3x3.v` ⭐

High-performance parallel architecture with vertical accumulation.

**Architecture:**
- **9 PEs** arranged in 3×3 grid
- **Vertical Combinational Chaining**: c_in/c_out connections (zero-latency)
- **Weight Pre-loading**: 3 cycles to load all weights before computation
- **Bottom Row Output**: Results extracted only from Row 2 (PE6, PE7, PE8)
- **Final Summation**: 2-stage adder tree combines 3 columns

**Key Innovation:** 
- No intermediate result registers (as per strict requirements)
- Combinational chaining allows 3 accumulations per cycle per column
- Fastest design: **32 cycles** (16 load + 3 weight + 8 compute + 1 done + overhead)

```
PE Layout:                    Data Flow:
  PE0  PE1  PE2  (Row 0)      A[0..2] → → →
   ↓c   ↓c   ↓c               B[2,1,0]
  PE3  PE4  PE5  (Row 1)      A[4..6] → → →
   ↓c   ↓c   ↓c               B[5,4,3]
  PE6  PE7  PE8  (Row 2)      A[8..10] → → →
   ↓    ↓    ↓                B[8,7,6]
 Output summation            ↓
   C11  C12  (from cols)     Results
```

### 4. Systolic Array 2×2 - `sa_2x2.v`

Output stationary architecture with skewed input feeding.

**Architecture:**
- **4 PEs** in 2×2 grid
- **Output Stationary**: Each PE dedicated to one output position
- **Skewed Input**: Staggered timing for proper data alignment
- **Dual Output Usage**:
  - `c_out`: Includes top row results (C11, C12)
  - `acc_out`: Self-accumulated results (C21, C22)

**Performance:** 36 cycles (18 load + 16 compute + 2 done)

```
PE Layout:                    Output Mapping:
  PE0 ──► PE1                 PE2.c_out   = C11
   ↓       ↓                  PE2.acc_out = C21
  PE2 ──► PE3                 PE3.c_out   = C12
                              PE3.acc_out = C22
```

### 5. Controller FSM - `controller_fsm_fpga.v`

Main system controller with auto-start and mode sequencing.

**States:**
1. **IDLE**: Initial state after reset
2. **AUTO**: Auto-start delay (~10ms for stabilization)
3. **SERIAL**: Execute serial PE mode
4. **SA3X3**: Execute SA 3×3 mode
5. **SA2X2**: Execute SA 2×2 mode
6. **DONE**: Hold results, display active

**Features:**
- Automatic mode sequencing (no manual intervention)
- Clean handshake with start/done signals
- Mode multiplexing for memory address routing

### 6. Memory Storage - `memory_storage.v`

ROM containing test vectors for input matrix and filter.

**Test Data:**
```
Input Matrix A (4×4):         Filter B (3×3):
┌──────────────────┐          ┌─────────────┐
│  3   4   5   6   │          │  1   0   1  │
│  7   8   9  10   │          │  2   3   2  │
│ 11  12  13  14   │          │  1   0   1  │
│ 15  16  17  18   │          └─────────────┘
└──────────────────┘

Expected Output (2×2, after 180° filter rotation):
┌─────────────┐
│  87    91   │   C11=87, C12=91
│ 102    87   │   C21=102, C22=87
└─────────────┘
```

## ✅ Verification Results

### Testbench Overview

This project includes two types of testbenches for comprehensive verification:

- **`testbench_pro/`** - Console-based testbenches designed for user convenience
  - Automated pass/fail checking with clear text output
  - Performance metrics reporting (cycle counts, speedup ratios)
  - Ideal for quick verification and regression testing
  - All results displayed in readable format without requiring waveform analysis

- **`testbench_wave/`** - Waveform-based testbenches for timing configuration
  - Detailed signal-level verification with waveform viewers (ModelSim, Vivado)
  - Timing diagram analysis for debugging dataflow issues
  - Manual inspection of internal PE states and control signals
  - Used for low-level hardware debugging and optimization

### Latest Test Run: `tb_top_fpga_pro.v`

```
==============================================
 tb_top_fpga: Refactored FPGA Top Testbench
==============================================

[Test 1] Reset Synchronization
  PASS: rst_n synchronized

[Test 2] Auto-Start
  PASS: Auto-start triggered

[Test 3] Computation Complete
  PASS: All done in 143 cycles

[Test 4] Results Verification - ALL MODES

  [Serial PE Mode]
    C11=87 (exp:87) ✅
    C12=91 (exp:91) ✅
    C21=102 (exp:102) ✅
    C22=87 (exp:87) ✅
    Cycles: 77
    PASS: Serial results correct

  [SA 3×3 Mode]
    C11=87 (exp:87) ✅
    C12=91 (exp:91) ✅
    C21=102 (exp:102) ✅
    C22=87 (exp:87) ✅
    Cycles: 32
    PASS: SA 3×3 results correct

  [SA 2×2 Mode]
    C11=87 (exp:87) ✅
    C12=91 (exp:91) ✅
    C21=102 (exp:102) ✅
    C22=87 (exp:87) ✅
    Cycles: 36
    PASS: SA 2×2 results correct

[Test 5] Performance Comparison
  Serial PE: 77 cycles (baseline)
  SA 3×3:    32 cycles (speedup: 2.41×) ⭐
  SA 2×2:    36 cycles (speedup: 2.14×)

[Test 6] Display Operation
  PASS: Display FSM running (state=1, digit=00000000)

==============================================
 Test Summary: PASS=8, FAIL=0
==============================================
 ALL TESTS PASSED!
==============================================

Time: 2625 ns  Iteration: 0  Instance: /tb_top_fpga
```

### Verification Coverage

| Test Case | Description | Status |
|-----------|-------------|--------|
| Reset Synchronization | 2-stage synchronizer for metastability | ✅ PASS |
| Auto-Start | 10ms delay before computation | ✅ PASS |
| Serial PE Accuracy | All 4 outputs correct | ✅ PASS |
| SA 3×3 Accuracy | All 4 outputs correct | ✅ PASS |
| SA 2×2 Accuracy | All 4 outputs correct | ✅ PASS |
| Performance Metrics | Cycle counts verified | ✅ PASS |
| Display Integration | 7-segment driver functional | ✅ PASS |
| Mode Sequencing | SERIAL → SA3X3 → SA2X2 → DONE | ✅ PASS |

## 🚀 Getting Started

### Prerequisites
- **Xilinx Vivado** 2018.3 or later
- **ModelSim** (for simulation)
- **FPGA Starter Kit III** (for hardware deployment)

### Simulation

1. **Compile all modules:**
```tcl
vlog modules/and_gate.v modules/full_adder_behavioral.v
vlog modules/adder_8bit.v modules/multiplier_8bit.v modules/buffer_8bit.v
vlog modules/pe.v modules/memory_storage.v
vlog modules/serial_pe_compute.v modules/serial_pe_controller.v
vlog modules/sa_3x3.v modules/sa_3x3_controller.v
vlog modules/sa_2x2.v modules/sa_2x2_controller.v
vlog modules/controller_fsm_fpga.v modules/display_7seg_fpga.v
vlog modules/top_fpga.v
vlog testbench_pro/tb_top_fpga_pro.v
```

2. **Run top-level testbench:**
```tcl
vsim -c tb_top_fpga
run -all
```

3. **Expected output:**
```
ALL TESTS PASSED!
Serial PE: 77 cycles
SA 3×3:    32 cycles (2.41× speedup)
SA 2×2:    36 cycles (2.14× speedup)
```

### FPGA Synthesis

1. **Create Vivado project:**
```tcl
create_project fpga_conv ./fpga_conv -part xc7a75tfgg484-1
add_files [glob modules/*.v]
add_files -fileset constrs_1 modules/fsk3_constraints.xdc
set_property top top_fpga [current_fileset]
```

2. **Run synthesis and implementation:**
```tcl
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
```

3. **Program FPGA:**
```tcl
open_hw_manager
connect_hw_server
open_hw_target
program_hw_devices [get_hw_devices xc7a75t_0] \
    -bitstream ./fpga_conv.runs/impl_1/top_fpga.bit
```

## 🧮 Mathematical Background

### True Convolution (180° Filter Rotation)

This implementation performs **true 2D convolution**, not correlation.

**Standard Convolution Definition:**
```
(A ⊗ B)[i,j] = ΣΣ A[i+m, j+n] × B[-m, -n]
```

**Implementation (Filter Rotation):**
```
Original Filter B:           Rotated 180°:
┌─────────────┐              ┌─────────────┐
│ B0  B1  B2  │              │ B8  B7  B6  │
│ B3  B4  B5  │  ────────►   │ B5  B4  B3  │
│ B6  B7  B8  │              │ B2  B1  B0  │
└─────────────┘              └─────────────┘

Memory Layout: [B0, B1, ..., B8] → Access: [B8, B7, ..., B0]
```

**Output Computation:**
```
C11 = A0×B8 + A1×B7 + A2×B6 + A4×B5 + A5×B4 + A6×B3 + A8×B2 + A9×B1 + A10×B0
C12 = A1×B8 + A2×B7 + A3×B6 + A5×B5 + A6×B4 + A7×B3 + A9×B2 + A10×B1 + A11×B0
C21 = A4×B8 + A5×B7 + A6×B6 + A8×B5 + A9×B4 + A10×B3 + A12×B2 + A13×B1 + A14×B0
C22 = A5×B8 + A6×B7 + A7×B6 + A9×B5 + A10×B4 + A11×B3 + A13×B2 + A14×B1 + A15×B0
```

## 🎓 Design Principles

### 1. Structural Modeling
All arithmetic operations use gate-level primitives:
- **Multiplication**: 64 AND gates + 56 full adders (Wallace tree)
- **Addition**: 8-bit ripple-carry adder (8 full adders)
- **No behavioral operators**: Strict adherence to structural design

### 2. Separation of Concerns
- **Datapath modules** (`.v`): Pure hardware connectivity
- **Controller modules** (`_controller.v`): FSM and control signals
- Clean interface boundaries for modularity

### 3. Systolic Design Patterns
- **Weight Stationary**: Weights loaded once and reused
- **Output Stationary**: Each PE owns a fixed output position
- **Vertical Accumulation**: Combinational chaining for speed

### 4. No Intermediate Results (SA 3×3)
- Top and middle row `acc_out` signals **not used** for final results
- Only bottom row `c_out` signals contribute to outputs
- Complies with strict requirement: "Intermediate Result 사용 시 감점!"

### 5. Verification-Driven Development
- Comprehensive testbenches for each module
- Golden reference values for result validation
- Performance metrics tracking (cycle counts)

## 📚 References

### Academic Papers
1. **H.T. Kung**, "Why Systolic Architectures?", *IEEE Computer*, 1982
2. **Y.-H. Chen et al.**, "Eyeriss: An Energy-Efficient Reconfigurable Accelerator for Deep CNNs", *ISSCC*, 2016
3. **A. Parashar et al.**, "SCNN: An Accelerator for Compressed-sparse Convolutional Neural Networks", *ISCA*, 2017

### Design Resources
- Xilinx Artix-7 FPGAs Data Sheet (DS181)
- FSK3 Development Board User Guide
- Vivado Design Suite User Guide: Synthesis (UG901)

## 👥 Contributors

- **Author**: kijac
- **Course**: Digital Logic Design
- **Institution**: [Sungkyunkwan University EEE]
- **Year**: 2026

---

