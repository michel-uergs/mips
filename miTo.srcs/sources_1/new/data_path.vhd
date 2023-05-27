----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: michel fritsch & robert perquim
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
library mito;
use mito.mito_pkg.all;

entity data_path is
  Port 
   (
    clk                 : in  std_logic;
    rst_n               : in  std_logic;
    address             : out std_logic_vector (8 downto 0);
    saida_memoria       : in  std_logic_vector (31 downto 0);       -- memory to instruction register and/or data register
    entrada_memoria     : out std_logic_vector (31 downto 0);       -- ula_out or reg_out to memory
--------------------------------------------------------------------------------------------------
    PCWrite             : in  std_logic;     
    IorD                : in  std_logic;
    PCsource            : in  std_logic;
    MemRead             : in  std_logic;
    MemWrite            : in  std_logic;
    MentoReg            : in  std_logic;
    IRWrite             : in  std_logic;
    RegDst              : in  std_logic;
    RegWrite            : in  std_logic;
    ALUSrcA             : in  std_logic;
    ALUSrcB             : in  std_logic;
    ALUop               : in  std_logic_vector (3 downto 0);
    decoded_inst        : out decoded_instruction_type;
    zero                : out std_logic;
    neg                 : out std_logic
  );

end data_path;

architecture rtl of data_path is

  -- REGISTRADORES PRO MULTICICLO
  signal instruction_register     : std_logic_vector (31 downto 0);   -- instrucao da memoria
  signal memory_data_register     : std_logic_vector (31 downto 0);   -- dado da memoria
  signal ALUout                   : std_logic_vector (31 downto 0);   -- registrador da saida da alu
  signal REG_A                    : std_logic_vector (31 downto 0);
  signal REG_B                    : std_logic_vector (31 downto 0); 

  -- ENDERECO DOS REGISTRADORES
  signal a_addr                   : std_logic_vector(4 downto 0);     -- endereco registrador a
  signal b_addr                   : std_logic_vector(4 downto 0);     -- endereco registrador b
  signal c_addr                   : std_logic_vector(4 downto 0);     -- endereco registrador c

  -- OPERADORES DA ALU
  signal A_operand                : std_logic_vector (31 downto 0);
  signal B_operand                : std_logic_vector (31 downto 0);
  signal alu_out                  : std_logic_vector (31 downto 0); 
  signal NEG_B_operand            : std_logic_vector (31 downto 0);

  --Flags
  signal zero_datapath            :  std_logic;
  signal neg_datapath             :  std_logic;
  signal overflow_datapath        :  std_logic;
  signal unsigned_overflow        :  std_logic;

  -- DADO A SER ESCRITO NOS REGISTRADORES
  signal write_data               : std_logic_vector (31 downto 0);

  -- OUTROS SINAIS
  signal program_counter          : std_logic_vector (8  downto 0);
  signal jump_adress              : std_logic_vector (8  downto 0); -- sinal alternativo que ta ligado no PC

  -- REGISTRADORES
  signal reg0                     : std_logic_vector (31 downto 0);
  signal reg1                     : std_logic_vector (31 downto 0);
  signal reg2                     : std_logic_vector (31 downto 0);
  signal reg3                     : std_logic_vector (31 downto 0);
  signal reg4                     : std_logic_vector (31 downto 0);
  signal reg5                     : std_logic_vector (31 downto 0);
  signal reg6                     : std_logic_vector (31 downto 0);
  signal reg7                     : std_logic_vector (31 downto 0);
  signal reg8                     : std_logic_vector (31 downto 0);
  signal reg9                     : std_logic_vector (31 downto 0);
  signal reg10                    : std_logic_vector (31 downto 0);
  signal reg11                    : std_logic_vector (31 downto 0);
  signal reg12                    : std_logic_vector (31 downto 0);
  signal reg13                    : std_logic_vector (31 downto 0);
  signal reg14                    : std_logic_vector (31 downto 0);
  signal reg15                    : std_logic_vector (31 downto 0);
  signal reg16                    : std_logic_vector (31 downto 0);
  signal reg17                    : std_logic_vector (31 downto 0);
  signal reg18                    : std_logic_vector (31 downto 0);
  signal reg19                    : std_logic_vector (31 downto 0);
  signal reg20                    : std_logic_vector (31 downto 0);
  signal reg21                    : std_logic_vector (31 downto 0);
  signal reg22                    : std_logic_vector (31 downto 0);
  signal reg23                    : std_logic_vector (31 downto 0);
  signal reg24                    : std_logic_vector (31 downto 0);
  signal reg25                    : std_logic_vector (31 downto 0);
  signal reg26                    : std_logic_vector (31 downto 0);
  signal reg27                    : std_logic_vector (31 downto 0);
  signal reg28                    : std_logic_vector (31 downto 0);
  signal reg29                    : std_logic_vector (31 downto 0);
  signal reg30                    : std_logic_vector (31 downto 0);
  signal reg31                    : std_logic_vector (31 downto 0);

begin
 
  -- PC CONTROL
  process(PCWrite, rst_n)
  begin
    if (rst_n = '1') then
      program_counter <= "000000000";
    end if;

    if(PCWrite = '1') then
      program_counter <= jump_adress;
    else
      program_counter <= program_counter + 2;
    end if;
  end process;

  -- MUX ALU-A
 process (ALUSrcA, REG_A, program_counter)
begin
  if (ALUSrcA = '1') then
    A_operand <= REG_A;
  else
    A_operand(8 downto 0)  <= program_counter;
    A_operand(31 downto 9) <= "00000000000000000000000";
  end if;
end process;

  -- MUX ALU-B
process(ALUSrcB, REG_B,instruction_register(15 downto 0))
begin
  if (ALUSrcB='0') then
    B_operand <= REG_B;
  else
    B_operand (15 downto 0) <= instruction_register(15 downto 0);  -- mudei a ordem dos bit 
    B_operand (31 downto 16) <= "0000000000000000";                -- acho que isso :)
  end if;
end process;

  -- MUX C_ADDR 
process(RegDst, b_addr,instruction_register(15 downto 11))
begin
  if RegDst='0' then
    c_addr <= b_addr;
  else
    c_addr <= instruction_register(15 downto 11);
  end if;
end process;


-- MUX WRITE_DATA
process(MentoReg, ALUout, memory_data_register)
begin
  if (MentoReg='0') then
    write_data <= ALUout;
  else
    write_data <= memory_data_register;
  end if;
end process;
  
-- MUX PC
process(IorD, program_counter, ALUout)
begin
  if IorD ='0' then
    address <= program_counter;
  else
    address <= ALUout(8 downto 0);
  end if;
end process;

-- MUX JUMP
process(PCsource, ALUout, program_counter)
begin
  if IorD ='0' then
    jump_adress <= ALUout(8 downto 0);
  else
    jump_adress <= program_counter;
  end if;
end process;


 -- DECODER 
process(instruction_register)
begin
  case instruction_register(31 downto 26) is
    when "111111" => 
        decoded_inst <= I_HLT;
        when "000000" => decoded_inst <= I_NOP;
        when "000001" => decoded_inst <= I_LOAD;
        when "000010" => decoded_inst <= I_STORE;
        when "000011" => decoded_inst <= I_ADD;        
        when "000100" => decoded_inst <= I_SUB;        
        when "000101" => decoded_inst <= I_AND;        
        when "000110" => decoded_inst <= I_OR;        
        when "000111" => decoded_inst <= I_JUMP;        
        when "001000" => decoded_inst <= I_BQE;        
        when "001001" => decoded_inst <= I_LOAD;                         
        when others   => decoded_inst <= I_NOP;
  end case;  
end process;

  -- ALU
  process(ALUop, A_operand, B_operand, NEG_B_operand)

  begin
    case ALUop is
      when "00001" => alu_out <= A_operand + B_operand;       -- add
      when "00010" => alu_out <= A_operand + NEG_B_operand;   -- sub
      when "00011" => alu_out <= A_operand and 	B_operand;    -- and
      when "00100" => alu_out <= A_operand or	B_operand;      -- or
      when "00101" => alu_out <= A_operand nor B_operand;     -- nor
      when  others   => alu_out <= A_operand;
    end case;

    zero_datapath <= not(
                          alu_out(31) or 
                          alu_out(30) or 
                          alu_out(29) or 
                          alu_out(28) or 
                          alu_out(27) or 
                          alu_out(26) or 
                          alu_out(25) or 
                          alu_out(24) or 
                          alu_out(23) or 
                          alu_out(22) or 
                          alu_out(21) or 
                          alu_out(20) or 
                          alu_out(19) or 
                          alu_out(18) or 
                          alu_out(17) or 
                          alu_out(16) or 
                          alu_out(15) or 
                          alu_out(14) or 
                          alu_out(13) or 
                          alu_out(12) or 
                          alu_out(11) or 
                          alu_out(10) or 
                          alu_out(9) or 
                          alu_out(8) or 
                          alu_out(7) or 
                          alu_out(6) or 
                          alu_out(5) or 
                          alu_out(4) or 
                          alu_out(3) or 
                          alu_out(2) or 
                          alu_out(1) or 
                          alu_out(0)
                        );
    neg_datapath  <= alu_out(31);


  end process;

  -- SINAIS QUE MUDAM COM O CLOCK 
  process(clk)
  begin

    -- ENTRADA DA MEMORIA
    if(IRWrite = '1') then
      instruction_register <= saida_memoria;
    else
      memory_data_register <= saida_memoria;
    end if;

    --SAIDA ALU
    ALUout <= alu_out;
    zero   <= zero_datapath;
    neg    <= neg_datapath;
    --overflow_datapth  ???????????
    --unsigned_overflow ???????????

    -- BANCO DE REGISTERADORES
    case (a_addr) is
      when "00000" =>   REG_A <= reg0;
      when "00001" =>   REG_A <= reg1;
      when "00010" =>   REG_A <= reg2;
      when "00011" =>   REG_A <= reg3;
      when "00100" =>   REG_A <= reg4;  
      when "00101" =>   REG_A <= reg5;
      when "00110" =>   REG_A <= reg6;
      when "00111" =>   REG_A <= reg7;
      when "01000" =>   REG_A <= reg8;
      when "01001" =>   REG_A <= reg9;
      when "01010" =>   REG_A <= reg10;
      when "01011" =>   REG_A <= reg11;
      when "01100" =>   REG_A <= reg12;
      when "01101" =>   REG_A <= reg13;
      when "01110" =>   REG_A <= reg14;
      when "01111" =>   REG_A <= reg15;
      when "10000" =>   REG_A <= reg16;
      when "10001" =>   REG_A <= reg17;
      when "10010" =>   REG_A <= reg18;
      when "10011" =>   REG_A <= reg19;
      when "10100" =>   REG_A <= reg20;
      when "10101" =>   REG_A <= reg21;
      when "10110" =>   REG_A <= reg22;
      when "10111" =>   REG_A <= reg23;
      when "11000" =>   REG_A <= reg24;
      when "11001" =>   REG_A <= reg25;
      when "11010" =>   REG_A <= reg26;
      when "11011" =>   REG_A <= reg27;
      when "11100" =>   REG_A <= reg28;
      when "11101" =>   REG_A <= reg29;
      when "11110" =>   REG_A <= reg30;
      when "11111" =>   REG_A <= reg31;
    end case;
    case (b_addr) is
      when "00000" =>   REG_B <= reg0;
      when "00001" =>   REG_B <= reg1;
      when "00010" =>   REG_B <= reg2;
      when "00011" =>   REG_B <= reg3;
      when "00100" =>   REG_B <= reg4;  
      when "00101" =>   REG_B <= reg5;
      when "00110" =>   REG_B <= reg6;
      when "00111" =>   REG_B <= reg7;
      when "01000" =>   REG_B <= reg8;
      when "01001" =>   REG_B <= reg9;
      when "01010" =>   REG_B <= reg10;
      when "01011" =>   REG_B <= reg11;
      when "01100" =>   REG_B <= reg12;
      when "01101" =>   REG_B <= reg13;
      when "01110" =>   REG_B <= reg14;
      when "01111" =>   REG_B <= reg15;
      when "10000" =>   REG_B <= reg16;
      when "10001" =>   REG_B <= reg17;
      when "10010" =>   REG_B <= reg18;
      when "10011" =>   REG_B <= reg19;
      when "10100" =>   REG_B <= reg20;
      when "10101" =>   REG_B <= reg21;
      when "10110" =>   REG_B <= reg22;
      when "10111" =>   REG_B <= reg23;
      when "11000" =>   REG_B <= reg24;
      when "11001" =>   REG_B <= reg25;
      when "11010" =>   REG_B <= reg26;
      when "11011" =>   REG_B <= reg27;
      when "11100" =>   REG_B <= reg28;
      when "11101" =>   REG_B <= reg29;
      when "11110" =>   REG_B <= reg30;
      when "11111" =>   REG_B <= reg31;
    end case;
    if (RegWrite = '1') then
      case (c_addr) is
        when "00000" =>   reg0  <= write_data;
        when "00001" =>   reg1  <= write_data;
        when "00010" =>   reg2  <= write_data;
        when "00011" =>   reg3  <= write_data;
        when "00100" =>   reg4  <= write_data;  
        when "00101" =>   reg5  <= write_data;
        when "00110" =>   reg6  <= write_data;
        when "00111" =>   reg7  <= write_data;
        when "01000" =>   reg8  <= write_data;
        when "01001" =>   reg9  <= write_data;
        when "01010" =>   reg10 <= write_data;
        when "01011" =>   reg11 <= write_data;
        when "01100" =>   reg12 <= write_data;
        when "01101" =>   reg13 <= write_data;
        when "01110" =>   reg14 <= write_data;
        when "01111" =>   reg15 <= write_data;
        when "10000" =>   reg16 <= write_data;
        when "10001" =>   reg17 <= write_data;
        when "10010" =>   reg18 <= write_data;
        when "10011" =>   reg19 <= write_data;
        when "10100" =>   reg20 <= write_data;
        when "10101" =>   reg21 <= write_data;
        when "10110" =>   reg22 <= write_data;
        when "10111" =>   reg23 <= write_data;
        when "11000" =>   reg24 <= write_data;
        when "11001" =>   reg25 <= write_data;
        when "11010" =>   reg26 <= write_data;
        when "11011" =>   reg27 <= write_data;
        when "11100" =>   reg28 <= write_data;
        when "11101" =>   reg29 <= write_data;
        when "11110" =>   reg30 <= write_data;
        when "11111" =>   reg31 <= write_data;
      end case;
    end if;
  end process;
    
end rtl;