`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2020 07:45:20 PM
// Design Name: 
// Module Name: apb_master
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


module apb_master(
output reg [7:0]apb_prdata_out,
output reg pslverr,                     //
input pclk,preset,ptransfer,pwrite,write_again,
input [7:0] apb_pwaddr,apb_praddr,
input [7:0] apb_pwdata
    );
   wire pready;

   reg psel,penable;
   reg [7:0]paddr;       //RAM
   reg [7:0]pwdata;
   wire [7:0]prdata;             //RAM


   reg [1:0]pstate,nstate;


 parameter idle=2'b00,setup=2'b01,access=2'b10,temp=2'b11;

 always @(posedge pclk)begin
 if(!preset)
 begin
 pstate<=idle;
 end
 else
 begin
 pstate<=nstate;
 end
 end

 always @(*)begin
 if(!pwrite)begin
 case(pstate)
 idle : begin
        if(!ptransfer)begin
        psel=0;
        penable=0;
        end
        else
        nstate=setup;
        end

 setup :begin
        if(!pready && ptransfer)begin
        psel=1;
        if(psel && penable)
           pslverr=1;
        end
        else if(!ptransfer) begin
        nstate=idle; end
        else begin
        nstate=access;
        end
        end

 access:begin
        if(pready && ptransfer)begin
        penable=1;
        paddr=apb_praddr;
        apb_prdata_out=prdata;
        end
        else if(!pready && ptransfer)
        begin
        penable=0;
        pslverr=1;
        nstate=setup;
        end
        else
        nstate=idle;
        end

 default :begin
          nstate<=idle;
          end
 endcase
 end

 else begin

 case(pstate)
 idle : begin
        if(!ptransfer)begin
        psel=0;
        penable=0;
        end
        else
        nstate=setup;
        end

 setup :begin
        if(!pready && ptransfer)begin
        psel=1;
        paddr=apb_pwaddr;
        pwdata=apb_pwdata;
         if(psel && penable)
           pslverr=1;
        end
        else if(!ptransfer)begin
        nstate=idle;end
        else begin
            if(apb_pwdata!=pwdata | apb_pwaddr!=paddr)    //
            pslverr=1;
            else
            nstate=access;
        end
        end

 access:begin
        if(pready && ptransfer)begin
        penable=1;
        if(!write_again)begin
        //penable=1;
        nstate=setup;end
        else begin
        nstate=temp;end
        end
        else if(!pready && ptransfer)
        begin
        penable=0;
        pslverr=1;
        end
        else
        nstate=idle;
        end

temp : begin
        paddr=apb_pwaddr;
        pwdata=apb_pwdata;
        nstate=access;
       end

 default:begin
         nstate<=idle;
         end
 endcase
end
end

apb_slave apb1(.pready(pready),.prdata(prdata),.psel(psel),.penable(penable),.pclk(pclk),.pwrite(pwrite),.pwdata(pwdata),.paddr(paddr));

endmodule
