# FIFO Verification Project
 
A complete SystemVerilog functional verification environment for a parameterized FIFO design. The environment includes constrained-random stimulus, a scoreboard-based reference model, functional coverage, and SVA assertions — achieving **100% coverage** across all metrics.
 
---
 
## 📁 Project Structure
 
```
fifo-verification/
│
├── rtl/
│   └── FIFO.sv                  # DUT — parameterized FIFO design
│
├── tb/
│   ├── FIFO_if.sv               # Interface 
│   ├── FIFO_tb.sv               # Testbench — constrained-random stimulus
│   ├── FIFO_monitor.sv          # Samples interface, drives scoreboard & coverage
│   ├── FIFO_scoreboard.sv       # Reference model & data correctness checker
│   ├── FIFO_coverage.sv         # Functional covergroups with cross coverage
│   ├── FIFO_transaction.sv      # Randomizable transaction class with constraints
│   └── shared_pkg.sv            # Shared package
│
├── top/
│   └── top_module.sv            # Top-level
│
├── run.do                   # ModelSim/QuestaSim simulation script
├──src_files.list            # Ordered compilation file list
│
└── README.md
```
 
---
 
## ⚙️ Design Parameters
 
| Parameter    | Default | Description               |
|--------------|---------|---------------------------|
| `FIFO_WIDTH` | 16      | Data bus width (bits)     |
| `FIFO_DEPTH` | 8       | Number of entries in FIFO |
 
---
 
## 🧩 Environment Overview
 
- **Interface (`FIFO_if.sv`):** Defines `DUT`, `tb`, and `mon` modports to cleanly separate signal directions across components.
- **Transaction (`FIFO_transaction.sv`):** Randomizable class with constraints on `rst_n`, `wr_en`, and `rd_en` distributions (default: 70% write, 30% read activity).
- **Testbench (`FIFO_tb.sv`):** Drives 9,000 randomized transactions through the interface and triggers a `sample_event` each cycle.
- **Monitor (`FIFO_monitor.sv`):** Captures all signals on `sample_event` and forks to feed both the scoreboard and coverage collector simultaneously.
- **Scoreboard (`FIFO_scoreboard.sv`):** Maintains a queue as the golden reference model, compares `data_out` against expected values, and tracks error/correct counts.
- **Coverage (`FIFO_coverage.sv`):** Covergroup `CovFIFO` with cross coverage across `wr_en`, `rd_en`, and all status flags (`full`, `empty`, `overflow`, `underflow`, `wr_ack`, `almostfull`, `almostempty`).
---
 
## ✅ SVA Assertions
 
11 concurrent assertions written in `FIFO.sv`, covering: reset behavior, `wr_ack`, overflow, underflow, empty, full, almost-empty, almost-full, write/read pointer wraparound, and pointer threshold bounds.
 
---
 
## 📊 Results
 
| Metric                        | Result   |
|-------------------------------|----------|
| Functional Coverage           | 100%     |
| Statement / Branch / Toggle   | 100%     |
| Assertion Coverage            | 100%     |
| Correct Transactions          | 9001     |
| Errors                        | 0        |
 
---
 
## 🚀 How to Run
 
**Prerequisites:** ModelSim or QuestaSim installed and on your PATH.
 
```bash
# 1. Clone the repo
git clone https://github.com/<your-username>/fifo-verification.git
cd fifo-verification
 
# 2. Run the simulation
vsim -do scripts/run.do
```
---
