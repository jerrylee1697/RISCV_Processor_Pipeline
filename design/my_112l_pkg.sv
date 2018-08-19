package my_112l_pkg;

`define RF_ADDRESS 5    // Reg File Address
`define DM_ADDRESS 5    // Data Mem Address
`define ALU_CC_W   4    // ALU Control Code Width
`define INST_W     32   // Instruction Width
`define DATA_W     32   // Data Width
`define PC_W       9    // Program Counter Width

// 4 Structs in between stages
// Instruction Fetch/Decode
typedef struct packed {
    logic [32-1:0] instruction;
    logic [9-1:0] pc;
    logic [9-1:0] pcplus4;
} IF_ID;

// Instruction Decode/Execute
typedef struct packed {
    logic [9-1:0] pc;
    logic [9-1:0] pcplus4;
    logic [32-1:0] reg1, reg2;
    logic [32-1:0] imm;
    logic [4:0] rs1, rs2;
    logic [5-1:0] rd;
    logic [6:0] funct7;
    logic [2:0] funct3;

    // Control Bits
    logic stall;
    logic ALUSrc;
    logic [1:0] memtoreg;
    logic regwrite;
    logic memread;
    logic memwrite;
    logic branch;
    logic jalr;
    logic jal;
    logic lui;
    logic load, store;
    logic [1:0] ALUop;
} ID_EX;

// Execute/Memory
typedef struct packed {
    logic [9-1:0] pcplus4;
    logic [31:0] PCJump;
    logic [32-1:0] ALUResult;
    logic [32-1:0] memwritedata; // Register 2
    logic [5-1:0] rd;

    // Control Bits
    logic stall;
    logic branch;
    logic jal;
    logic jalr;
    logic regwrite;
    logic memwrite;
    logic memread;
    logic [2:0] readdatasel;
    logic [1:0] writedatasel;
    logic [1:0] memtoreg;
} EX_MEM;

// Memory/Writeback
typedef struct packed {
    logic [9-1:0] pcplus4;
    logic [32-1:0] PCJump;
    logic [32-1:0] readdata;
    logic [32-1:0] ALUResult;   // ALUResult
    logic [5-1:0] rd;

    // Control Bits
    logic stall;
    logic [1:0] memtoreg;
    logic [2:0] readdatasel;
    logic regwrite;
} MEM_WB;

endpackage
