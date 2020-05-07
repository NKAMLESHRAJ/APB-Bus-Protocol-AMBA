----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2020 11:20:14 PM
-- Design Name: 
-- Module Name: RAM - Behavioral
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
--use ieee.std_logic_signed.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM is
  Port (psel,penable,pclk,pwrite : in std_logic;
  paddr,pwdata : in std_logic_vector(7 downto 0);
  prdata:out std_logic_vector (7 downto 0);
  pready : out std_logic );
end RAM;

architecture Behavioral of RAM is 
type memory_type is array(0 to 127) of std_logic_vector(7 downto 0);
signal mem: memory_type; 
begin

process (pclk)
begin
if(rising_edge (pclk)) then
    if(psel = '1' ) then 
    pready <= '1';
        if (penable ='1')then
            if (pwrite ='1') then
                mem (to_integer(unsigned(paddr)))<= pwdata;
                pready <= '0';
            else 
                prdata <= mem (to_integer(unsigned(paddr)));
                pready <= '0';
            end if;
--        else
--        pready <= '0';
        end if;
    else
    pready <= '0';
    end if; 
end if;
end process;

end Behavioral;
