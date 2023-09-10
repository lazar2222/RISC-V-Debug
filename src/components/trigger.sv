module trigger (
    input clk,
    input rst_n,

    input  [31:0] tdata1_in,
    input  [31:0] tdata2_in,
    input  [31:0] tdata3_in,
    input         tdata1_write,
    input         tdata2_write,
    input         tdata3_write,
    output [31:0] tdata1_out,
    output [31:0] tdata2_out,
    output [31:0] tdata3_out,
    output [31:0] tinfo,

    input [31:0] pc,
    input [31:0] ir,
    input [31:0] addr,
    input [31:0] mem_out,
    input [31:0] mem_in,
    input [ 1:0] mem_size,

    input debug,
    input retire,
    input loada,
    input loadd,
    input store,

    output trigger
);
    localparam logic [31:0] AmtMask  = {5'b00110,6'd0,2'b11,1'b0,2'b11,4'd0,1'b0,4'd0,1'b1,3'd0,3'b111};
    localparam logic [31:0] AmtValue = {5'b00101,6'd0,2'b00,1'b0,2'b00,4'd1,1'b0,4'd0,1'b0,3'd0,3'b000};
    localparam logic [31:0] IctMask  = {5'b00110,2'b00,1'b1,{14{1'b1}},1'b1,3'd0,6'd0};
    localparam logic [31:0] IctValue = {5'b00111,2'b00,1'b0,{14{1'b0}},1'b0,3'd0,6'd1};

    reg [3:0] newtype;

    wire [31:0] mask  = newtype == 4'd2 ? AmtMask  :  IctMask;
    wire [31:0] value = newtype == 4'd2 ? AmtValue :  IctValue;

    wire valid = tdata1_in[31:28] == 4'd2 || tdata1_in[31:28] == 4'd3;

    reg [31:0] tdata1;
    reg [31:0] tdata2;

    wire amt = tdata1[31:28] == 4'd2;
    wire ict = tdata1[31:28] == 4'd3;

    wire       amt_select = tdata1[19];
    wire [1:0] amt_size   = tdata1[17:16];
    wire       amt_en     = tdata1[6];
    wire       amt_exec   = tdata1[2];
    wire       amt_store  = tdata1[1];
    wire       amt_load   = tdata1[0];

    wire [13:0] ict_count = tdata1[23:10];
    wire        ict_en    = tdata1[9];

    wire load = amt_select ? loadd : loada;

    wire size_ok =
    (amt_size == 2'd0 && 1'b1) ||
    (amt_size == 2'd1 && mem_size == 2'd0) ||
    (amt_size == 2'd2 && mem_size == 2'd1) ||
    (amt_size == 2'd3 && mem_size == 2'd2);

    wire amt_exec_hit  =           (amt_select ? ir      : pc  ) == tdata2  && (amt_size == 2'd0 || amt_size == 2'd3);
    wire amt_store_hit = store && ((amt_select ? mem_in  : addr) == tdata2) && size_ok;
    wire amt_load_hit  = load  && ((amt_select ? mem_out : addr) == tdata2) && size_ok;

    wire amt_hit = amt && amt_en && ((amt_exec && amt_exec_hit) || (amt_store && amt_store_hit) || (amt_load && amt_load_hit));
    wire ict_hit = ict && ict_en && ict_count == 14'd0;

    assign trigger = (amt_hit || ict_hit) && !debug;

    assign tdata1_out = tdata1;
    assign tdata2_out = tdata2;
    assign tdata3_out = {32'd0};
    assign tinfo      = {16'd0,12'd0,4'b1100};

    always @(posedge clk) begin
        if (!rst_n) begin
            tdata1 <= AmtValue;
            tdata2 <= {32'd0};
        end else begin
            if (amt_hit) begin
                tdata1[20] <= 1'b1;
            end
            if (ict_hit) begin
                tdata1[24] <= 1'b1;
            end
            if (retire && ict && ict_en) begin
                tdata1[23:10] <= tdata1[23:10] - 14'd1;
            end
            if(tdata1_write) begin
                newtype = tdata1_in[31:28];
                if(!valid) begin
                    newtype = 4'd2;
                end
                tdata1 <= ({newtype,tdata1_in[27:0]} & mask) | (value & ~mask);
            end
            if(tdata2_write) begin
                tdata2 <= tdata2_in;
            end
        end
    end

endmodule
