IVERILOG ?= iverilog
VVP ?= vvp
IVERILOG_FLAGS ?= -g2012 -Wall

BUILD_DIR := build
ALU_TEST := $(BUILD_DIR)/rv32i_alu_tb
REGISTER_FILE_TEST := $(BUILD_DIR)/rv32i_register_file_tb
DECODER_TEST := $(BUILD_DIR)/rv32i_decoder_tb
IMMEDIATE_TEST := $(BUILD_DIR)/rv32i_immediate_generator_tb
PROGRAM_COUNTER_TEST := $(BUILD_DIR)/rv32i_program_counter_tb
BRANCH_TEST := $(BUILD_DIR)/rv32i_branch_unit_tb

.PHONY: test test-alu test-register-file test-decoder test-immediate test-program-counter test-branch clean

test: test-alu test-register-file test-decoder test-immediate test-program-counter test-branch

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(ALU_TEST): rtl/rv32i_alu.sv tb/rv32i_alu_tb.sv | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -s rv32i_alu_tb -o $(ALU_TEST) $^

test-alu: $(ALU_TEST)
	$(VVP) $(ALU_TEST)

$(REGISTER_FILE_TEST): rtl/rv32i_register_file.sv tb/rv32i_register_file_tb.sv | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -s rv32i_register_file_tb -o $(REGISTER_FILE_TEST) $^

test-register-file: $(REGISTER_FILE_TEST)
	$(VVP) $(REGISTER_FILE_TEST)

$(DECODER_TEST): rtl/rv32i_decoder.sv tb/rv32i_decoder_tb.sv | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -s rv32i_decoder_tb -o $(DECODER_TEST) $^

test-decoder: $(DECODER_TEST)
	$(VVP) $(DECODER_TEST)

$(IMMEDIATE_TEST): rtl/rv32i_immediate_generator.sv tb/rv32i_immediate_generator_tb.sv | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -s rv32i_immediate_generator_tb -o $(IMMEDIATE_TEST) $^

test-immediate: $(IMMEDIATE_TEST)
	$(VVP) $(IMMEDIATE_TEST)

$(PROGRAM_COUNTER_TEST): rtl/rv32i_program_counter.sv tb/rv32i_program_counter_tb.sv | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -s rv32i_program_counter_tb -o $(PROGRAM_COUNTER_TEST) $^

test-program-counter: $(PROGRAM_COUNTER_TEST)
	$(VVP) $(PROGRAM_COUNTER_TEST)

$(BRANCH_TEST): rtl/rv32i_branch_unit.sv tb/rv32i_branch_unit_tb.sv | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -s rv32i_branch_unit_tb -o $(BRANCH_TEST) $^

test-branch: $(BRANCH_TEST)
	$(VVP) $(BRANCH_TEST)

clean:
	rm -rf $(BUILD_DIR)
