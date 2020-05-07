----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2020 12:09:22 AM
-- Design Name: 
-- Module Name: apb_vhdl - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity apb_vhdl is
  Port ( pclk,preset,ptransfer,pwrite:in std_logic;
         apb_waddr,apb_raddr,apb_wdata:in std_logic_vector(7 downto 0);
         apb_rdata : out std_logic_vector(7 downto 0);
         pslverr:out std_logic);
end apb_vhdl;

architecture Behavioral of apb_vhdl is
component apb_master is
  Port ( pclk,preset,ptransfer,pwrite,pready:in std_logic;
         apb_waddr,apb_raddr,apb_wdata:in std_logic_vector(7 downto 0);
         psel,penable,pslverr:out std_logic;
         paddr,pwdata,apb_rdata : out std_logic_vector(7 downto 0);
         prdata:in std_logic_vector (7 downto 0));
   end component;
component RAM is
  Port (psel,penable,pclk,pwrite : in std_logic;
  paddr,pwdata : in std_logic_vector(7 downto 0);
  prdata:out std_logic_vector (7 downto 0);
  pready : out std_logic );
  end component;
  
   signal pready:std_logic;
   signal psel,penable:std_logic;
   signal paddr,pwdata: std_logic_vector(7 downto 0);
   signal prdata:std_logic_vector (7 downto 0); 
    
begin

master:apb_master Port map 
(pclk=>pclk, 
 preset=>preset, 
 ptransfer=>ptransfer,
 pwrite=>pwrite,
 pready=>pready,
 apb_waddr=>apb_waddr,
 apb_raddr=>apb_raddr,
 apb_wdata=>apb_wdata,
 psel=>psel,
 penable=>penable,
 pslverr=>pslverr,
 paddr=>paddr,
 pwdata=>pwdata,
 apb_rdata=>apb_rdata,
 prdata=>prdata);
 
slave:RAM Port map
(psel=>psel,
penable=>penable, 
pclk=>pclk,
pwrite=>pwrite,
paddr=>paddr,
pwdata=>pwdata,
prdata=>prdata,
pready=>pready);

end Behavioral;
