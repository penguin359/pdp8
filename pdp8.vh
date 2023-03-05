localparam A_WIDTH = 12;
localparam D_WIDTH = 12;

localparam [2:0] OPCODE_AND = 3'b000;
localparam [2:0] OPCODE_TAD = 3'b001;
localparam [2:0] OPCODE_ISZ = 3'b010;
localparam [2:0] OPCODE_DCA = 3'b011;
localparam [2:0] OPCODE_JMS = 3'b100;
localparam [2:0] OPCODE_JMP = 3'b101;
localparam [2:0] OPCODE_IOT = 3'b110;
localparam [2:0] OPCODE_OPR = 3'b111;

localparam Z_BIT = 7;
localparam I_BIT = 8;

localparam UC_GROUP1_BIT = 8;
localparam UC_GROUP2_BIT = 0;

// uC Group 1 bits
localparam CLA_BIT = 7;
localparam CLL_BIT = 6;
localparam CMA_BIT = 5;
localparam CML_BIT = 4;
localparam RAR_BIT = 3;
localparam RAL_BIT = 2;
localparam BSW_BIT = 1;
localparam IAC_BIT = 0;

// uC Group 2 bits
//localparam CLA_BIT = 7;
localparam SMA_BIT = 6;
localparam SZA_BIT = 5;
localparam SNL_BIT = 4;
localparam AND_BIT = 3;
localparam OSR_BIT = 2;
localparam HLT_BIT = 1;

// uC Group 3 bits
//localparam CLA_BIT = 7;
localparam MQA_BIT = 6;
localparam SCA_BIT = 5;
localparam MQL_BIT = 4;
// 3:1 Code bits
