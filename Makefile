IVERILOG ?= iverilog
VVP ?= vvp
IVERILOG_FLAGS ?= -g2012 -Wall

BUILD_DIR := build
ALU_TEST := $(BUILD_DIR)/rv32i_alu_tb
REGISTER_FILE_TEST := $(BUILD_DIR)/rv32i_register_file_tb
DECODER_TEST := $(BUILD_DIR)/rv32i_decoder_tb

.PHONY: test test-alu test-register-file test-decoder clean

test: test-alu test-register-file test-decoder

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

clean:
	rm -rf $(BUILD_DIR)
