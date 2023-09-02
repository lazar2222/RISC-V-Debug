`include "dmi_if.svh"

module dtm (
    input clk,
    input rst_n,

    input  tck_ns,
    input  tms_ns,
    input  tdi_ns,
    output tdo,

    dmi_if dmi
);
    localparam logic [3:0] TEST_LOGIC_RESET = 4'h0;
    localparam logic [3:0] RUN_TEST_IDLE    = 4'h1;
    localparam logic [3:0] SELECT_DR_SCAN   = 4'h2;
    localparam logic [3:0] SELECT_IR_SCAN   = 4'h3;
    localparam logic [3:0] CAPTURE_DR       = 4'h4;
    localparam logic [3:0] CAPTURE_IR       = 4'h5;
    localparam logic [3:0] SHIFT_DR         = 4'h6;
    localparam logic [3:0] SHIFT_IR         = 4'h7;
    localparam logic [3:0] EXIT1_DR         = 4'h8;
    localparam logic [3:0] EXIT1_IR         = 4'h9;
    localparam logic [3:0] PAUSE_DR         = 4'hA;
    localparam logic [3:0] PAUSE_IR         = 4'hB;
    localparam logic [3:0] EXIT2_DR         = 4'hC;
    localparam logic [3:0] EXIT2_IR         = 4'hD;
    localparam logic [3:0] UPDATE_DR        = 4'hE;
    localparam logic [3:0] UPDATE_IR        = 4'hF;

    localparam logic [4:0] BYPASS = 5'h00;
    localparam logic [4:0] IDCODE = 5'h01;
    localparam logic [4:0] DTMCS  = 5'h10;
    localparam logic [4:0] DMIA   = 5'h11;

    localparam int IR_LEN     = 5;
    localparam int BYPASS_LEN = 1;
    localparam int IDCODE_LEN = 32;
    localparam int DTMCS_LEN  = 32;
    localparam int DMIA_LEN   = 41;
    localparam int SR_LEN     = 41;

    localparam logic [BYPASS_LEN-1:0] BYPASS_VALUE =  1'b0;
    localparam logic [IDCODE_LEN-1:0] IDCODE_VALUE = 32'h1;

    localparam logic [1:0] OP_NOP   = 2'd0;
    localparam logic [1:0] OP_READ  = 2'd1;
    localparam logic [1:0] OP_WRITE = 2'd2;

    reg [2:0] tck_reg, tms_reg, tdi_reg;
    reg tdo_reg, tdo_next, tdo_en;

    reg [3:0] state_reg, state_next;

    reg [  IR_LEN-1:0] ir;
    reg [DMIA_LEN-1:0] dmia;
    reg [  SR_LEN-1:0] sr, sr_next;

    int sr_len, sr_len_next;

    reg in_prog;

    wire [DTMCS_LEN-1:0] dtmcs = {20'd0,2'd0,6'd7,4'd1};

    wire [ 6:0] address = dmia[40:34];
    wire [31:0] data    = dmia[33:2];
    wire [ 1:0] op      = dmia[1:0];

    wire state_sdr = state_reg == SHIFT_DR;
    wire state_sir = state_reg == SHIFT_IR;

    wire read_op  = op == OP_READ;
    wire write_op = op == OP_WRITE;

    wire tck = tck_reg[1];
    wire tms = tms_reg[1];
    wire tdi = tdi_reg[1];
    wire tck_re = !tck_reg[2] &&  tck_reg[1];
    wire tck_fe =  tck_reg[2] && !tck_reg[1];

    assign tdo = tdo_reg && tdo_en;

    assign tdo_next = sr[SR_LEN-sr_len];

    assign dmi.read    = in_prog && read_op;
    assign dmi.write   = in_prog && write_op;
    assign dmi.address = address;
    assign dmi.data    = dmi.write ? data : {32{1'bz}};

    always @(posedge clk) begin
        if (!rst_n) begin
            tck_reg    <= 3'd0;
            tms_reg    <= 3'd0;
            tdi_reg    <= 3'd0;
            tdo_reg    <= 1'd0;
            tdo_en     <= 1'b0;
            state_reg  <= TEST_LOGIC_RESET;
            ir         <= IDCODE;
            dmia       <= {DMIA_LEN{1'b0}};
            sr         <= {SR_LEN{1'b0}};
            sr_len     <= 0;
            in_prog    <= 1'b0;
        end else begin
            tck_reg <= {tck_reg[1:0], tck_ns};
            tms_reg <= {tms_reg[1:0], tms_ns};
            tdi_reg <= {tdi_reg[1:0], tdi_ns};
            if (tck_re) begin
                state_reg <= state_next;
                case (state_reg)
                    CAPTURE_DR: begin sr <= sr_next;                              sr_len <= sr_len_next; end
                    CAPTURE_IR: begin sr <= {IDCODE_VALUE,{SR_LEN-IR_LEN{1'b0}}}; sr_len <= IR_LEN;      end
                    SHIFT_DR,
                    SHIFT_IR:   sr <= {tdi,sr[SR_LEN-1:1]};
                    default: ;
                endcase
            end
            if (tck_fe) begin
                tdo_reg <= tdo_next;
                tdo_en  <= state_sdr || state_sir;
            end
            if (tck_fe && state_reg == UPDATE_IR)                begin ir         <= sr[SR_LEN-1:SR_LEN-IR_LEN];                  end
            if (tck_fe && state_reg == UPDATE_DR && ir == DMIA)  begin dmia       <= sr;                         in_prog <= 1'b1; end
            if (in_prog) begin
                in_prog    <= 1'b0;
                dmia[ 1:0] <= 2'd0;
                if (OP_READ) begin
                    dmia[33:2] <= dmi.data;
                end
            end
        end
    end

    always_comb begin
        case (state_reg)
            TEST_LOGIC_RESET: state_next = tms ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
            RUN_TEST_IDLE:    state_next = tms ?   SELECT_DR_SCAN : RUN_TEST_IDLE;
            SELECT_DR_SCAN:   state_next = tms ?   SELECT_IR_SCAN :    CAPTURE_DR;
            SELECT_IR_SCAN:   state_next = tms ? TEST_LOGIC_RESET :    CAPTURE_IR;
            CAPTURE_DR:       state_next = tms ?         EXIT1_DR :      SHIFT_DR;
            CAPTURE_IR:       state_next = tms ?         EXIT1_IR :      SHIFT_IR;
            SHIFT_DR:         state_next = tms ?         EXIT1_DR :      SHIFT_DR;
            SHIFT_IR:         state_next = tms ?         EXIT1_IR :      SHIFT_IR;
            EXIT1_DR:         state_next = tms ?        UPDATE_DR :      PAUSE_DR;
            EXIT1_IR:         state_next = tms ?        UPDATE_IR :      PAUSE_IR;
            PAUSE_DR:         state_next = tms ?         EXIT2_DR :      PAUSE_DR;
            PAUSE_IR:         state_next = tms ?         EXIT2_IR :      PAUSE_IR;
            EXIT2_DR:         state_next = tms ?        UPDATE_DR :      SHIFT_DR;
            EXIT2_IR:         state_next = tms ?        UPDATE_IR :      SHIFT_IR;
            UPDATE_DR:        state_next = tms ?   SELECT_DR_SCAN : RUN_TEST_IDLE;
            UPDATE_IR:        state_next = tms ?   SELECT_DR_SCAN : RUN_TEST_IDLE;
            default:          state_next = TEST_LOGIC_RESET;
        endcase
        case (ir)
            IDCODE:  begin sr_next = {IDCODE_VALUE,{SR_LEN-IDCODE_LEN{1'b0}}}; sr_len_next = IDCODE_LEN; end
            DTMCS:   begin sr_next = {dtmcs,{SR_LEN-DTMCS_LEN{1'b0}}};         sr_len_next = DTMCS_LEN;  end
            DMIA:    begin sr_next = {dmia,{SR_LEN-DMIA_LEN{1'b0}}};           sr_len_next = DMIA_LEN;   end
            BYPASS:  begin sr_next = {SR_LEN{1'b0}};                           sr_len_next = BYPASS_LEN; end
            default: begin sr_next = {SR_LEN{1'b0}};                           sr_len_next = BYPASS_LEN; end
        endcase
    end

endmodule
