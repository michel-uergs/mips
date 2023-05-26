----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: michel fritsch & robert perquim
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library mito;
use mito.mito_pkg.all;

entity control_unit is
    Port 
    ( 
        clk                 : in  std_logic;
        rst_n               : in  std_logic;
        write_mem_en        : out std_logic;
        ------------------------------------------
        -- Nao alterar os sinais de cima ---------
        ------------------------------------------
        PCWrite             : out  std_logic;     
        IorD                : out  std_logic;
        PCsource            : out  std_logic;
        MemRead             : out  std_logic;
        MemWrite            : out  std_logic;
        MentoReg            : out  std_logic;
        IRWrite             : out  std_logic;
        RegDst              : out  std_logic;
        RegWrite            : out  std_logic;
        ALUSrcA             : out  std_logic;
        ALUSrcB             : out  std_logic;
        ALUop               : out  std_logic_vector (3 downto 0);
        decoded_inst        : in   decoded_instruction_type;
        zero                : in   std_logic;
        neg                 : in   std_logic

    );
end control_unit;


architecture rtl of control_unit is
        
begin
    PCWrite    <= '0';
    IorD       <= '0';
    PCsource   <= '0';
    MemRead    <= '0';
    MemWrite   <= '0';
    MentoReg   <= '0';
    IRWrite    <= '0';
    RegDst     <= '0';
    RegWrite   <= '0';
    ALUSrcA    <= '0';
    ALUSrcB    <= '0';
    ALUop      <= "0000";

end rtl;

