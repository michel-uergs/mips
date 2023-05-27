----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: michel fritsch & robert perquim
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;



package mito_pkg is
--NOVAS
type decoded_instruction_type is 
(	
	I_LOAD,
	I_STORE,
	I_ADD,
	I_SUB,
	I_AND,
	I_OR,
	I_JUMP,
	I_BQE,
	I_LOAD
);
  
  component data_path
	Port (
		clk                 : in  std_logic;
    	rst_n               : in  std_logic;
    	Address             : out std_logic_vector (8 downto 0);
    	saida_memoria       : in  std_logic_vector (31 downto 0);       
    	entrada_memoria     : out std_logic_vector (31 downto 0);     

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
  end component;

  component control_unit
    Port
	( 
        clk                 : in  std_logic;
        rst_n               : in  std_logic;
        write_mem_en        : out std_logic;

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
  end component;
  
  component memory is
	port(        
        clk                 : in  std_logic;
        saida_memoria       : out std_logic_vector (31 downto 0);
        entrada_memoria     : in  std_logic_vector (31 downto 0);
        escrita             : in  std_logic;
        endereco_memoria    : in  std_logic_vector (8  downto 0);
        rst_n               : in  std_logic
	);
          
  end component;

  component mito
  	port(
  		rst_n        			: in  std_logic;
  		clk          			: in  std_logic;
  		adress       			: in  std_logic_vector (8  downto 0);
  		saida_memoria 			: in  std_logic_vector (31 downto 0);  
  		entrada_memoria 		: out std_logic_vector (31 downto 0); 
  		write_enable 			: out std_logic
  	);
  end component;
  
 component testbench is
  port
  (
       signal clk 				: in  std_logic;
       signal reset 			: in  std_logic;
       signal saida_memoria 	: in  std_logic_vector (31 downto 0);
       signal entrada_memoriao 	: out std_logic_vector (31 downto 0)
  ); 
  
  end component;   

end mito_pkg;

package body mito_pkg is
end mito_pkg;
