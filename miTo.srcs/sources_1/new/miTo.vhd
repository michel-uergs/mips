----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: michel fritsch & robert perquim
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library mito;
use mito.mito_pkg.all;

entity miTo is
  Port (
      rst_n                  : in  std_logic;
      clk                    : in  std_logic;
      saida_memoria          : in  std_logic_vector (31 downto 0);   -- in data read from memory
      entrada_memoria        : out std_logic_vector (31 downto 0);   -- out_reg or alu_out to memory 
      write_mem_en           : out std_logic
   );
end miTo;

architecture rtl of miTo is
  signal PCWrite_s        : std_logic;
  signal IorD_s           : std_logic;
  signal PCsource_s       : std_logic;
  signal MemRead_s        : std_logic;
  signal MemWrite_s       : std_logic;
  signal MentoReg_s       : std_logic;
  signal IRWrite_s        : std_logic;
  signal RegDst_s         : std_logic;
  signal RegWrite_s       : std_logic;
  signal ALUSrcA_s        : std_logic;
  signal ALUSrcB_s        : std_logic;
  signal ALUop_s          : std_logic_vector (3 downto 0);
  signal zero_s           : std_logic;
  signal neg_s              : std_logic;
  signal write_mem_en_s     : std_logic;
  signal adress_pc_s        : std_logic_vector(8 downto 0);
  signal saida_memoria_s    : std_logic_vector(31 downto 0);
  signal entrada_memoria_s  : std_logic_vector(31 downto 0);
  signal decoded_inst_s: decoded_instruction_type;
 


begin
  
control_unit_i : control_unit
    port map
    ( 
      clk            => clk           ,
      rst_n          => rst_n         ,
      write_mem_en   => write_mem_en_s,
      ------------------------------------------
      -- Nao alterar os sinais de cima ---------
      ------------------------------------------
      PCWrite        => PCWrite_s     ,               
      IorD           => IorD_s        ,       
      PCsource       => PCsource_s    ,      
      MemRead        => MemRead_s     ,      
      MemWrite       => MemWrite_s    ,      
      MentoReg       => MentoReg_s    ,      
      IRWrite        => IRWrite_s     ,      
      RegDst         => RegDst_s      ,      
      RegWrite       => RegWrite_s    ,      
      ALUSrcA        => ALUSrcA_s     ,      
      ALUSrcB        => ALUSrcB_s     ,      
      ALUop          => ALUop_s       ,     
      decoded_inst   => decoded_inst_s,      
      zero           => zero_s        ,                    
      neg            => neg_s               

    );

data_path_i : data_path
  port map 
  (
    clk                 => clk,
    rst_n               => rst_n,
    address              => adress_pc_s,
    ------------------------------------------
    -- Nao alterar os sinais de cima ---------
    ------------------------------------------
    PCWrite         => PCWrite_s         ,               
    IorD            => IorD_s            ,       
    PCsource        => PCsource_s        ,      
    MemRead         => MemRead_s         ,      
    MemWrite        => MemWrite_s        ,      
    MentoReg        => MentoReg_s        ,      
    IRWrite         => IRWrite_s         ,      
    RegDst          => RegDst_s          ,      
    RegWrite        => RegWrite_s        ,      
    ALUSrcA         => ALUSrcA_s         ,      
    ALUSrcB         => ALUSrcB_s         ,      
    ALUop           => ALUop_s           ,     
    decoded_inst    => decoded_inst_s    ,      
    zero            => zero_s            ,
    saida_memoria   => saida_memoria_s   ,
    entrada_memoria => entrada_memoria_s ,                   
    neg             => neg_s                                      
  );
  
memory_i : memory
  port map(
    clk                 => clk,
    rst_n               => rst_n,   
    escrita             => write_mem_en_s,
    endereco_memoria    => adress_pc_s,
    saida_memoria       => saida_memoria_s,
    entrada_memoria     => entrada_memoria_s
  );
 
end rtl;
