----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2020 10:50:01 PM
-- Design Name: 
-- Module Name: apb_master - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity apb_master is
  Port ( pclk,preset,ptransfer,pwrite,pready:in std_logic;
         apb_waddr,apb_raddr,apb_wdata:in std_logic_vector(7 downto 0);
         psel,penable,pslverr:out std_logic;
         paddr,pwdata,apb_rdata : out std_logic_vector(7 downto 0);
         prdata:in std_logic_vector (7 downto 0)
              );
end apb_master;

architecture Behavioral of apb_master is

--fsm states
type state is (idle,setup,acces);
signal pstate,nstate:state;
--temporary register
signal paddr1_temp,paddr2_temp,paddr1_temp1,paddr2_temp1,pwdata_temp,prdata_temp:std_logic_vector(7 downto 0);
--signals
signal penable1: std_logic;
signal paddr_temp1,paddr_temp2:std_logic_vector(7 downto 0);
signal apb_waddr1,apb_raddr1,apb_wdata1,pwdata_temp1,prdata1:std_logic_vector(7 downto 0);
begin

penable_signal:process (penable1,paddr_temp1,paddr_temp2) 
begin
penable <= penable1;
paddr1_temp <= paddr_temp1;
paddr2_temp <= paddr_temp2;
end process;

registering: process (pclk)
begin
if(rising_edge (pclk)) then
apb_waddr1<=apb_waddr;
apb_raddr1<=apb_raddr; 
apb_wdata1<=apb_wdata;
pwdata_temp1<=pwdata_temp;
prdata1<=prdata;
if (pwrite = '1')then
paddr1_temp1<=paddr1_temp1;
else
paddr2_temp1<=paddr2_temp1;
end if;
end if;
end process;

states:process (pclk)
begin
if(rising_edge (pclk)) then
if (preset ='1')then
pstate <= idle;
else
pstate <= nstate; 
end if;
end if;
end process;

process_and_output:process (prdata,ptransfer,pstate,pwrite,preset,pready,apb_raddr,apb_waddr,apb_wdata,
apb_raddr1,apb_waddr1,apb_wdata1,paddr1_temp,paddr2_temp,prdata_temp,penable1,pwdata_temp,pwdata_temp1,prdata1,paddr1_temp1,paddr2_temp1)
begin
case (pstate) is
when idle=> 
    psel <= '0';
    penable1  <= '0'; 
    pslverr <= '0';
    paddr_temp1<=apb_waddr1;
    paddr_temp2<=apb_raddr1; 
    pwdata_temp<=apb_wdata1;
    pwdata<=pwdata_temp1;
    apb_rdata<=prdata1;
    if (pwrite = '1')then
    paddr<=paddr1_temp1;
    else
    paddr<=paddr2_temp1;
    end if;
    if (ptransfer = '1') then 
    nstate<=setup;
    else 
    nstate<=idle;
    end if;
    
when setup=> 
    psel <= '1';
    penable1  <= '0'; 
    
    --error penable and psel is 1 in same clock
    if (penable1 = '1') then
    pslverr <= '1';
    else
    pslverr <= '0';
    end if;
    pwdata<=pwdata_temp1;
    apb_rdata<=prdata1;
    if (pwrite = '1')then
    paddr<=paddr1_temp1;
    else
    paddr<=paddr2_temp1;
    end if;
    --load fdata and address
    paddr_temp1<=apb_waddr;
    paddr_temp2<=apb_raddr; 
    pwdata_temp<=apb_wdata;
    
    nstate<=acces;
    
when acces=> 
    psel <= '1';
    penable1  <= '1';  
    if (ptransfer = '1') then
        if(pready = '1') then
           if (pwrite = '1') then
                if(apb_wdata = pwdata_temp and apb_waddr = paddr1_temp) then
                
                paddr_temp1<=apb_waddr1;
                paddr_temp2<=apb_raddr1; 
                pwdata_temp<=apb_wdata1;
                apb_rdata<=prdata1;
                
                paddr<=paddr1_temp;
                pwdata<=pwdata_temp;
                pslverr<='0';
                nstate<=setup;
                else
                
                paddr_temp1<=apb_waddr1;
                paddr_temp2<=apb_raddr1; 
                pwdata_temp<=apb_wdata1;
                pwdata<=pwdata_temp1;
                apb_rdata<=prdata1;
                paddr<=paddr1_temp1;
                --error data changed in access phase
                pslverr<='1';
                nstate<=setup;
                end if;
            else
                if(apb_raddr = paddr2_temp) then
                paddr_temp1<=apb_waddr1;
                paddr_temp2<=apb_raddr1;
                pwdata_temp<=apb_wdata1;
                pwdata<=pwdata_temp1;
                
                paddr<=paddr2_temp;
                apb_rdata<=prdata;
                pslverr<= '0';
                nstate<=setup;
                else
                paddr_temp1<=apb_waddr1;
                paddr_temp2<=apb_raddr1; 
                pwdata_temp<=apb_wdata1;
                pwdata<=pwdata_temp1;
                apb_rdata<=prdata1;
                paddr<=paddr2_temp1;
                --error data changed in access phase
                pslverr<='1';
                nstate<=setup;
                end if;
            end if;
        else
        paddr_temp1<=apb_waddr1;
        paddr_temp2<=apb_raddr1; 
        pwdata_temp<=apb_wdata1;
        pwdata<=pwdata_temp1;
        apb_rdata<=prdata1;
        if (pwrite = '1')then
        paddr<=paddr1_temp1;
        else
        paddr<=paddr2_temp1;
        end if;
        --error ready not available in 3 clock cycle
        pslverr<= '1';
        nstate<=acces;
        end if;
    else
    paddr_temp1<=apb_waddr1;
    paddr_temp2<=apb_raddr1; 
    pwdata_temp<=apb_wdata1;
    pwdata<=pwdata_temp1;
    apb_rdata<=prdata1;
    if (pwrite = '1')then
    paddr<=paddr1_temp1;
    else
    paddr<=paddr2_temp1;
    end if;
    --no error --ptransfer is low
    pslverr<= '0';
    nstate<=idle;
    end if;
    when others =>
    paddr_temp1<=apb_waddr1;
    paddr_temp2<=apb_raddr1; 
    pwdata_temp<=apb_wdata1;
    pwdata<=pwdata_temp1;
    apb_rdata<=prdata1;
    if (pwrite = '1')then
    paddr<=paddr1_temp1;
    else
    paddr<=paddr2_temp1;
    end if;
    psel<= '0';
    penable1<= '0';
    pslverr<= '0';
    nstate<=idle;
    
end case; 

end process; 
end Behavioral;
