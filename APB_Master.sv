//Operating states Module

module APB_Master(
    input logic PCLK,
    input logic PRESETn,
    input logic PREADY,
    input logic[31:0] PRDATA,
    input logic  Transfer,
    output logic PSELx,
    output logic PENABLE,
    output logic[31:0] PADDR,
    output logic PWRITE,
    output logic [31:0] PWDATA,
    output logic [3:0] PSTRB
);

// State Definitions
parameter IDLE = 2'b00;
parameter SETUP =2'b01;
parameter ACCESS =2'b10;

/* synthesis fsm_encoding="gray" */ 
logic [1:0] cs, ns;  // Current State (cs) and Next State (ns)

//State Memory
always@(posedge PCLK) begin
    if(~PRESETn)
        cs<=IDLE;
    else
        cs<=ns;    
end

//output Logic
always @(cs) begin
    if(~PRESETn) begin 
        PSELx=0;
        PENABLE=0;
        PADDR=0;
        PWRITE=0;
        PWDATA=0;
        PSTRB=0;
    end
    else
        case (cs)
            IDLE: begin
                PSELx=0;
                PENABLE=0;
                end
            SETUP: begin
                PSELx=1;
                PWRITE=1;
                PENABLE=0;
                end
            ACCESS: begin
                PSELx=1;
                PENABLE=1;
                end
            default: begin
                PSELx=0;
                PENABLE=0;    
            end
        endcase
    end

//Next State Logic
always @(cs,PREADY,PRDATA) begin
    case (cs)
        IDLE: begin
            if(Transfer) ns=SETUP;
            else ns=IDLE;
        end
        SETUP: ns=ACCESS;
        ACCESS: begin
            if(~PREADY) ns=cs;
            else if(PREADY && Transfer) ns=SETUP;
            else if(PREADY && ~Transfer) ns=IDLE;
            else ns= IDLE;
        end
    endcase
end

endmodule
