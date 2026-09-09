IVERILOG ?= iverilog
VVP ?= vvp
IVERILOG_FLAGS ?= -g2012 -Wall

BUILD_DIR := build
ALU_TEST := $(BUILD_DIR)/rv32i_alu_tb

.PHONY: test test-alu clean

test: test-alu

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(ALU_TEST): rtl/rv32i_alu.sv tb/rv32i_alu_tb.sv | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -s rv32i_alu_tb -o $(ALU_TEST) $^

test-alu: $(ALU_TEST)
	$(VVP) $(ALU_TEST)

clean:
	rm -rf $(BUILD_DIR)

