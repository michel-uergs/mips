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
        PCenable            : out  std_logic; 
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
    type STATE_TYPE is (START, BUSCA_INSTRUCTION, EXECUTE, DECODE, REG, FIM_EXEC, MEMORY, FIM_MEMORY, FIM_MEMORY_2, FIM_PC_ENABLE, JUMP, FIM);
    signal ESTADO_ATUAL   : STATE_TYPE;
    signal PROXIMO_ESTADO : STATE_TYPE;
    
begin 
    process (rst_n, clk)
    begin
        if (clk'event and clk='1') then
            if (rst_n = '1') then   
                ESTADO_ATUAL <= BUSCA_INSTRUCTION;
            else 
                ESTADO_ATUAL <= PROXIMO_ESTADO; 
            end if;
        end if;
    end process;

    process (ESTADO_ATUAL, decoded_inst)
    begin
        case ESTADO_ATUAL is

            when START => 
            write_mem_en <= '0';
            PCenable     <= '0'; 
            IRwrite      <= '1';
            PROXIMO_ESTADO <= DECODE;
            
            when DECODE => PROXIMO_ESTADO <= EXECUTE;
            
            when EXECUTE =>
                case (decoded_inst) is
                    when I_NOP    => PROXIMO_ESTADO <= START;
                    when I_HLT    => PROXIMO_ESTADO <= FIM;
                    when I_ADD    => PROXIMO_ESTADO <= REG;
                    when I_SUB    => PROXIMO_ESTADO <= REG;   
                    when I_STORE  => PROXIMO_ESTADO <= MEMORY;   
                    when I_LOAD   => PROXIMO_ESTADO <= MEMORY;   
                    when I_AND    => PROXIMO_ESTADO <= REG;   
                    when I_OR     => PROXIMO_ESTADO <= REG;
                    when others   => PROXIMO_ESTADO <= START;
                end case;
                
            when REG => 
                --ALUop <= "0000";
                case (decoded_inst) is
                    when I_ADD    => ALUop <= "0001";
                    when I_SUB    => ALUop <= "0010";  
                    when I_AND    => ALUop <= "0011";   
                    when I_OR     => ALUop <= "0100";
                    when others   => ALUop <= "0000";
                end case;
                PROXIMO_ESTADO <= FIM_EXEC;
            
            when FIM_EXEC =>
                MentoREG <= '0';
                PROXIMO_ESTADO <= START;
            
            when MEMORY => 
            ALUSrcA    <= '1'; 
            ALUSrcB    <= '1'; 
            ALUop      <= "0000";
            PROXIMO_ESTADO <= FIM_MEMORY;

            when FIM_MEMORY =>
            IorD       <= '1';
            MemRead    <= '1';
            IRwrite    <= '0'; 
            MentoReg   <= '1';  
            RegDst     <= '0'; 
            RegWrite   <= '1'; 
            PCenable   <= '1'; 
            PROXIMO_ESTADO <=START;
            
            when FIM_MEMORY_2 => 
            RegWrite   <= '1';
            PCenable <= '0'; 
            PROXIMO_ESTADO <= START;

            when JUMP => PROXIMO_ESTADO <= FIM;

            when FIM => 
            PCenable <= '0';
            PROXIMO_ESTADO <= FIM;

            when others => PROXIMO_ESTADO <= START;
                
        end case;
    end process;
end rtl;