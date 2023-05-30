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
    -- State Machine
    type STATE_TYPE is (START, BUSCA_INSTRUCTION, DECODE, REG, MEMORY, JUMP, FIM);
    signal ESTADO_ATUAL : STATE_TYPE;
    signal PROXIMO_ESTADO : STATE_TYPE;
    
begin 
    process (rst_n, clk)
    begin
        if (rst_n = '0') then
            ESTADO_ATUAL <= BUSCA_INSTRUCTION;
        elsif (rising_edge(clk)) then
            ESTADO_ATUAL <= PROXIMO_ESTADO;
        end if;
    end process;

    process (ESTADO_ATUAL, decoded_inst)
    begin
        case ESTADO_ATUAL is

            when START =>
                if (rst_n = '0') then
                    PROXIMO_ESTADO <= BUSCA_INSTRUCTION;
                end if;
            
            when BUSCA_INSTRUCTION =>
                MemRead    <= '1';
                IRWrite    <= '1';
                if (decoded_inst = I_HLT) then
                    PROXIMO_ESTADO <= FIM;
                else
                    PROXIMO_ESTADO <= DECODE;
                end if;
                
            when DECODE =>
                case (decoded_inst) is
                    when I_NOP    => PROXIMO_ESTADO <= BUSCA_INSTRUCTION;
                    when I_HLT    => PROXIMO_ESTADO <= FIM;
                    when I_ADD    => PROXIMO_ESTADO <= REG;
                    when I_SUB    => PROXIMO_ESTADO <= BUSCA_INSTRUCTION;   
                    when I_STORE  => PROXIMO_ESTADO <= BUSCA_INSTRUCTION;   
                    when I_LOAD   => PROXIMO_ESTADO <= BUSCA_INSTRUCTION;   
                    when I_AND    => PROXIMO_ESTADO <= BUSCA_INSTRUCTION;   
                    when I_OR     => PROXIMO_ESTADO <= BUSCA_INSTRUCTION;
                    when others   => PROXIMO_ESTADO <= BUSCA_INSTRUCTION;
                end case;
                
            when REG =>
                PCWrite    <= '1';
                IorD       <= '1';
                PCsource   <= '1';
                MemRead    <= '1';
                MemWrite   <= '1';
                MentoReg   <= '1';
                IRWrite    <= '1';
                RegDst     <= '1';
                RegWrite   <= '1';
                ALUSrcA    <= '1';
                ALUSrcB    <= '1';
                ALUop      <= "0010";
                PROXIMO_ESTADO <= BUSCA_INSTRUCTION;
            
                when MEMORY =>
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
                PROXIMO_ESTADO <= FIM;
            
            when JUMP =>
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
                PROXIMO_ESTADO <= FIM;

            when FIM =>
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
                PROXIMO_ESTADO <= FIM;

            when others => PROXIMO_ESTADO <= FIM;
                
        end case;
    end process;
end rtl;