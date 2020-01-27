`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2020 07:46:30 PM
// Design Name: 
// Module Name: apb_slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module apb_slave
(output reg pready,
output reg [7:0]prdata,
input psel,penable,pclk,pwrite,
input [7:0]pwdata,
input [7:0]paddr
);

  reg [7:0]RAM[0:7];

    always @ (posedge pclk)begin
    if(psel)begin
    pready<=1;
        if(penable)begin
            if(pwrite)
            RAM[paddr]<=pwdata;
            else
            prdata<=RAM[paddr];
    end
    end
    else
    pready<=0;
    end
endmodule