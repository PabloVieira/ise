-------------------------------------------------------------------------
--
-- I M P L E M E N T A � � O   P A R C I A L  D O  M I P S   (nov/2010)
--
--  Professores     Fernando Moraes / Ney Calazans
--
--  ==> The top-level processor entity is MRstd
--  21/06/2010 (Ney) - Bug corrigido no mux que gera op1 - agora recebe
--		npc e n�o pc.
--  17/11/2010 (Ney) - Bugs corrigidos:
--		1 - Decodifica��o das instru��es BGEZ e BLEZ estava 
--		incompleta
--		2 - Defini��o de que linhas escolhem o registrador a
--		ser escrito nas instru��es de deslocamento 
--		(SSLL, SLLV, SSRA, SRAV, SSRL e SRLV)
--  05/06/2012 (Ney) - Mudan�as menores em nomenclatura
--  19/11/2015 (Ney) - Mudan�a para MIPS-MC Single Clock Edge
--			Al�m das mudan�as �bvias de sensibilidade de elementos de 
--			mem�ria para somente borda de subida, tamb�m mudou-se o
--			ponto de onde as entradas de dados do multiplicador e do
--			divisor prov�m, agora direto do banco de registradores e n�o
--			dos registradores RA e RB. Ainda, mudou-se a estrutura dos 
--			blocos de dados e controle. O Bloco de Controle agora
--			cont�m o PC, o NPC e o IR e naturalmente a interface com
--			a mem�ria de instru��es. Foi eliminado o estado Sidle, 
--			por n�o ser mais necess�rio.
--  04/07/2016 (Ney) - Diversas revis�es em nomes de sinais para 
--			aumentar a intuitividade da descri��o, mudan�a do
--			nome do processador para MIPS_S (ver documenta��o, vers�o 2.0
--			ou superior).
--  05/08/2016 (Ney) - Correcao e adaptacao dos nomes de sinais e
--			blocos para facilitar aprendizado. Processador agora se chama
--			MIPS_MCS (MIPS Multi-Ciclo Single Edge)
-------------------------------------------------------------------------

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- package com os tipos b�sicos auxiliares para descrever o processador
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.Std_Logic_1164.all;

package p_MIPS_MCS is  
    
    -- inst_type define as instru��es decodific�veis pelo bloco de controle
    type inst_type is  
            ( ADDU, NOP, SUBU, AAND, OOR, XXOR, NNOR, SSLL, SLLV, SSRA, SRAV,
				SSRL, SRLV,ADDIU, ANDI, ORI, XORI, LUI, LBU, LW, SB, SW, SLT,
				SLTU, SLTI,	SLTIU, BEQ, BGEZ, BLEZ, BNE, J, JAL, JALR, JR, 
				MULTU, DIVU, MFHI, MFLO, invalid_instruction);
 
    type microinstruction is record
            CY1:   std_logic;       -- command of the first stage
            CY2:   std_logic;       --    "    of the second stage
            walu:  std_logic;       --    "    of the third stage
            wmdr:  std_logic;       --    "    of the fourth stage
            wpc:   std_logic;       -- PC write enable
            wreg:  std_logic;       -- register bank write enable
            whilo: std_logic;       -- habilita��o de escrita nos registradores HI e LO
            ce:    std_logic;       -- Chip enable and R_W controls
            rw:    std_logic;
            bw:    std_logic;       -- Byte-word control (mem write only)
            i:     inst_type;       -- operation specification
            rst_md:std_logic;       -- mult and div initialization
    end record;
         
end p_MIPS_MCS;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Registrador de uso geral - sens�vel � borda de subida do rel�gio (ck), 
--		com reset ass�ncrono (rst) e habilita��o de escrita (ce)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;

entity regnbits is
           generic( INIT_VALUE : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0') );
           port(  ck, rst, ce : in std_logic;
                  D : in  STD_LOGIC_VECTOR (31 downto 0);
                  Q : out STD_LOGIC_VECTOR (31 downto 0)
               );
end regnbits;

architecture regnbits of regnbits is 
begin

  process(ck, rst)
  begin
       if rst = '1' then
              Q <= INIT_VALUE(31 downto 0);
       elsif ck'event and ck = '1' then
           if ce = '1' then
              Q <= D; 
           end if;
       end if;
  end process;
        
end regnbits;

library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MIPS_MCS.all;

entity barreira is
           port(  ck, rst, ce : in std_logic;
                  D : in  microinstruction;
                  Q : out microinstruction
               );
end barreira;

architecture barreira of barreira is 
begin

  process(ck, rst)
  begin
       if ck'event and ck = '1' then
           if ce = '1' then
              Q <= D; 
           end if;
       end if;
  end process;
        
end barreira;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Banco de Registradores  (R0..R31) - 31 registradores de 32 bits
-- 	Trata-se de uma mem�ria com tr�s portas de acesso, n�o confundir
--		com a mem�ria principal do processador. 
--		S�o duas portas de leitura (sinais AdRP1+DataRP1 e AdRP2+DataRP2) e
--		uma porta de escrita (dedfinida pelo conjunto de sinais 
--    ck, rst, ce, AdWP e DataWP).
--		Os endere�os de cada porta (AdRP1, AdRP2 e AdWP) s�o obviamente de
--		5 bits (pois 2^5=32), enquanto que os barramentos de dados de 
--		sa�da (DataRP1, DataRP2) e de entrada (DataWP) s�o de 32 bits.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.Std_Logic_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;   
use work.p_MIPS_MCS.all;

entity reg_bank is
       port( ck, rst, ce :    in std_logic;
             AdRP1, AdRP2, AdWP : in std_logic_vector( 4 downto 0);
             DataWP : in std_logic_vector(31 downto 0);
             DataRP1, DataRP2: out std_logic_vector(31 downto 0) 
           );
end reg_bank;

architecture reg_bank of reg_bank is
   type wirebank is array(0 to 31) of std_logic_vector(31 downto 0);
   signal reg : wirebank ;                            
   signal wen : std_logic_vector(31 downto 0) ;
begin            

    g1: for i in 0 to 31 generate        

        -- Remember register $0 is the constant 0, not a register.
        -- This is implemented by never enabling writes to register $0
        wen(i) <= '1' when i/=0 and AdWP=i and ce='1' else '0';
         
        -- Remember register $29, the stack pointer, points to some place
        -- near the bottom of the data memory, not the usual place 
		-- assigned by the MIPS simulator!!
        g2: if i=29 generate -- SP ---  x10010000 + x800 -- top of stack
           r29: entity work.regnbits generic map(INIT_VALUE=>x"10010800")    
                port map(ck=>ck, rst=>rst, ce=>wen(i), D=>DataWP, Q=>reg(i));
        end generate;  
                
        g3: if i/=29 generate 
           rx: entity work.regnbits 
					port map(ck=>ck, rst=>rst, ce=>wen(i), D=>DataWP, Q=>reg(i));                    
        end generate;
                   
   end generate g1;   
    

    DataRP1 <= reg(CONV_INTEGER(AdRP1));    -- source1 selection 

    DataRP2 <= reg(CONV_INTEGER(AdRP2));    -- source2 selection 
   
end reg_bank;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ALU - Uma unidade l�gico-aritm�tica puramente combinacional, cuja 
--		sa�da depende dos valores nas suas entradas de dados op1 e op2, cada
--		uma de 32 bits e da instru��o sendo executada pelo processador
--		que � informada via o sinal de controle op_alu.
--
-- 22/11/2004 (Ney Calazans) - subtle error correction was done for J!
-- Part of the work for J has been done before, by shifting IR(15 downto 0)
-- left by two bits before writing data to the IMED register.
--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.p_MIPS_MCS.all;

entity alu is
       port( op1, op2 : in std_logic_vector(31 downto 0);
             outalu :   out std_logic_vector(31 downto 0);   
             op_alu : in inst_type   
           );
end alu;

architecture alu of alu is 
   signal menorU, menorS : std_logic ;
begin
  
    menorU <=  '1' when op1 < op2 else '0';
    menorS <=  '1' when ieee.Std_Logic_signed."<"(op1,  op2) else '0' ; -- signed
    
    outalu <=  
        op1 - op2                            when  op_alu=SUBU                     else
        op1 and op2                          when  op_alu=AAND  or op_alu=ANDI     else 
        op1 or  op2                          when  op_alu=OOR   or op_alu=ORI      else 
        op1 xor op2                          when  op_alu=XXOR  or op_alu=XORI     else 
        op1 nor op2                          when  op_alu=NNOR                     else 
        op2(15 downto 0) & x"0000"           when  op_alu=LUI                      else
        (0=>menorU, others=>'0')             when  op_alu=SLTU  or op_alu=SLTIU    else
        (0=>menorS, others=>'0')             when  op_alu=SLT   or op_alu=SLTI     else
        op1(31 downto 28) & op2(27 downto 0) when  op_alu=J     or op_alu=JAL      else 
        op1                                  when  op_alu=JR    or op_alu=JALR     else 
        to_StdLogicVector(to_bitvector(op1) sll  CONV_INTEGER(op2(10 downto 6)))   when
													op_alu=SSLL   else 
        to_StdLogicVector(to_bitvector(op2) sll  CONV_INTEGER(op1(5 downto 0)))    when
													op_alu=SLLV   else 
        to_StdLogicVector(to_bitvector(op1) sra  CONV_INTEGER(op2(10 downto 6)))   when  
													op_alu=SSRA   else 
        to_StdLogicVector(to_bitvector(op2) sra  CONV_INTEGER(op1(5 downto 0)))    when  
													op_alu=SRAV   else 
        to_StdLogicVector(to_bitvector(op1) srl  CONV_INTEGER(op2(10 downto 6)))   when  
													op_alu=SSRL   else 
        to_StdLogicVector(to_bitvector(op2) srl  CONV_INTEGER(op1(5 downto 0)))    when
													op_alu=SRLV   else 
        op1 + op2;    -- default for ADDU, NOP,ADDIU,LBU,LW,SW,SB,BEQ,BGEZ,BLEZ,BNE    

end alu;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Descri��o Estrutural do Bloco de Dados 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_signed.all; -- needed for comparison instructions SLTx
use IEEE.Std_Logic_arith.all; -- needed for comparison instructions SLTxU
use work.p_MIPS_MCS.all;
   
entity datapath is
      port(  ck, rst :     in std_logic;
             d_address :   out std_logic_vector(31 downto 0);
             data :        inout std_logic_vector(31 downto 0); 
				 inst_branch_out, salta_out : out std_logic;
             end_mul :	   out std_logic;
             end_div :	   out std_logic;
             RESULT_OUT :  out std_logic_vector(31 downto 0);
             uins :        in microinstruction;
             IR_IN :  		in std_logic_vector(31 downto 0);
				 NPC_IN : 		in std_logic_vector(31 downto 0)
          );
end datapath;

architecture datapath of  datapath is
    signal result, R1, R2, RS, RT, RIN, sign_extend, cte_im, IMED, op1, op2, 
           outalu, RALU, MDR, mdr_int, HI, LO,
			  quociente, resto, D_Hi, D_Lo : std_logic_vector(31 downto 0) := (others=> '0');
    signal adD, adS : std_logic_vector(4 downto 0) := (others=> '0');    
    signal inst_branchEX, inst_branchMEM, inst_branchER, inst_R_subEX, inst_R_subMEM,
				inst_R_subER, inst_I_subEX, inst_I_subMEM, inst_I_subER: std_logic;   
    signal salta : std_logic := '0';
    signal produto : std_logic_vector(63 downto 0);
    signal npc: std_logic_vector(31 downto 0);
    signal uinsEX, uinsMEM, uinsER: microinstruction;
begin

   -- auxiliary signals 
   inst_branchEX  <= '1' when uinsEX.i=BEQ or uinsEX.i=BGEZ or uinsEX.i=BLEZ or uinsEX.i=BNE else 
                  '0';
	inst_branch_out <= inst_branchEX;   
	-- inst_R_sub is a subset of R-type instructions
   inst_R_subEX  <= '1' when uinsEX.i=ADDU or uinsEX.i=NOP or uinsEX.i=SUBU or uinsEX.i=AAND
                         or uinsEX.i=OOR or uinsEX.i=XXOR or uinsEX.i=NNOR else
                   '0';
	-- inst_I is a subset of I-type instructions
   inst_I_subEX  <= '1' when uinsEX.i=ADDIU or uinsEX.i=ANDI or uinsEX.i=ORI or uinsEX.i=XORI else
                   '0';
						 
	inst_branchMEM  <= '1' when uinsMEM.i=BEQ or uinsMEM.i=BGEZ or uinsMEM.i=BLEZ or uinsMEM.i=BNE else 
                  '0';   
	-- inst_R_sub is a subset of R-type instructions
   inst_R_subMEM  <= '1' when uinsMEM.i=ADDU or uinsMEM.i=NOP or uinsMEM.i=SUBU or uinsMEM.i=AAND
                         or uinsMEM.i=OOR or uinsMEM.i=XXOR or uinsMEM.i=NNOR else
                   '0';
	-- inst_I is a subset of I-type instructions
   inst_I_subMEM  <= '1' when uinsMEM.i=ADDIU or uinsMEM.i=ANDI or uinsMEM.i=ORI or uinsMEM.i=XORI else
                   '0';
						 
	inst_branchER  <= '1' when uinsER.i=BEQ or uinsER.i=BGEZ or uinsER.i=BLEZ or uinsER.i=BNE else 
                  '0';
   
	-- inst_R_sub is a subset of R-type instructions
   inst_R_subER  <= '1' when uinsER.i=ADDU or uinsER.i=NOP or uinsER.i=SUBU or uinsER.i=AAND
                         or uinsER.i=OOR or uinsER.i=XXOR or uinsER.i=NNOR else
                   '0';
	-- inst_I is a subset of I-type instructions
   inst_I_subER  <= '1' when uinsER.i=ADDIU or uinsER.i=ANDI or uinsER.i=ORI or uinsER.i=XORI else
                   '0';

   --==============================================================================
   -- second stage
   --==============================================================================
                
   -- The then clause is only used for logic shifts with a shamt field       
   M3: adS <= IR_IN(20 downto 16) when uins.i=SSLL or uins.i=SSRA or uins.i=SSRL else 
          IR_IN(25 downto 21);
          
   REGS: entity work.reg_bank(reg_bank) port map
        (AdRP1=>adS, DataRP1=>R1, AdRP2=>IR_IN(20 downto 16), DataRP2=>R2,
		   ck=>ck, rst=>rst, ce=>uins.wreg, AdWP=>adD, DataWP=>RIN);
    
   -- sign extension 
   sign_extend <=  x"FFFF" & IR_IN(15 downto 0) when IR_IN(15)='1' else
             x"0000" & IR_IN(15 downto 0);
    
   -- Immediate constant
   M5: cte_im <= sign_extend(29 downto 0)  & "00"     when inst_branchEX='1'			else
                -- branch address adjustment for word frontier
             "0000" & IR_IN(25 downto 0) & "00" when uinsEX.i=J or uinsEX.i=JAL 		else
                -- J/JAL are word addressed. MSB four bits are defined at the ALU, not here!
             x"0000" & IR_IN(15 downto 0) when uinsEX.i=ANDI or uinsEX.i=ORI  or uinsEX.i=XORI 	else
                -- logic instructions with immediate operand are zero extended
             sign_extend;
                -- The default case is used by addiu, lbu, lw, sbu and sw instructions
             
   -- second stage registers
	RNPCdiex: entity work.regnbits port map(ck=>ck, rst=>rst, ce=>uins.CY2, 
															D=>NPC_IN, Q=>npc); 
			
   RSreg:  entity work.regnbits port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>R1, Q=>RS);

   RTreg:  entity work.regnbits port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>R2, Q=>RT);
  
   RIM: entity work.regnbits port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>cte_im, Q=>IMED);
	
	DIEX: entity work.barreira port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>uins, Q=>uinsEX);
 
 
  --==============================================================================
   -- third stage
   --==============================================================================
                      
   -- select the first ALU operand                           
   M6: op1 <= NPC_IN  when inst_branchEX='1' else 
          RS; 
     
   -- select the second ALU operand
   M7: op2 <= RT when inst_R_subEX='1' or uinsEX.i=SLTU or uinsEX.i=SLT or uinsEX.i=JR 
                  or uinsEX.i=SLLV or uinsEX.i=SRAV or uinsEX.i=SRLV else 
          IMED; 
                 
   -- ALU instantiation
   DALU: entity work.alu port map (op1=>op1, op2=>op2, outalu=>outalu, op_alu=>uins.i);
   
   -- ALU register
   Reg_ALU: entity work.regnbits  port map(ck=>ck, rst=>rst, ce=>uins.walu, 
				D=>outalu, Q=>RALU);               
 
   -- evaluation of conditions to take the branch instructions
   salta <=  '1' when ( (RS=RT  and uins.i=BEQ)  or (RS>=0  and uins.i=BGEZ) or
                        (RS<=0  and uins.i=BLEZ) or (RS/=RT and uins.i=BNE) )  else
             '0';
   salta_out <= salta;

   D_Hi <= produto(63 downto 32) when uins.i=MULTU else 
          resto; 
   D_Lo <= produto(31 downto 0) when uins.i=MULTU else 
          quociente; 

      -- HI and LO registers
   REG_HI: entity work.regnbits  port map(ck=>ck, rst=>rst, ce=>uins.whilo, 
			D=>D_Hi, Q=>HI);               
   REG_LO: entity work.regnbits  port map(ck=>ck, rst=>rst, ce=>uins.whilo, 
			D=>D_Lo, Q=>LO);               

   --==============================================================================
   -- fourth stage
   --==============================================================================
     
   d_address <= RALU;
    
   -- tristate to control memory write    
   data <= RT when (uins.ce='1' and uins.rw='0') else (others=>'Z');  

   -- single byte reading from memory  -- assuming the processor is little endian
   M8: mdr_int <= data when uins.i=LW  else
              x"000000" & data(7 downto 0);
       
   RMDR: entity work.regnbits  port map(ck=>ck, rst=>rst, ce=>uins.wmdr,
			D=>mdr_int, Q=>MDR);                 
  
   M9: result <=    MDR when uins.i=LW  or uins.i=LBU else
	   	HI when uins.i=MFHI else
	   	LO when uins.i=MFLO else
                RALU;
					 
	EXMEM: entity work.barreira port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>uinsEX, Q=>uinsMEM);

   --==============================================================================
   -- fifth stage
   --==============================================================================

   -- signal to be written into the register bank
   M2: RIN <= NPC_IN when (uinsER.i=JALR or uinsER.i=JAL) else result;
   
   -- register bank write address selection
   M4: adD <= "11111"           when uinsER.i=JAL else -- JAL writes in register $31
         IR_IN(15 downto 11)    when (inst_R_subER='1' 
								or uinsER.i=SLTU or uinsER.i=SLT
								or uinsER.i=JALR
								or uinsER.i=MFHI or uinsER.i=MFLO
								or uinsER.i=SSLL or uinsER.i=SLLV
								or uinsER.i=SSRA or uinsER.i=SRAV
								or uinsER.i=SSRL or uinsER.i=SRLV) else
         IR_IN(20 downto 16) -- inst_I_sub='1' or uins.i=SLTIU or uins.i=SLTI 
        ;                 -- or uins.i=LW or  uins.i=LBU  or uins.i=LUI, or default
    
  RESULT_OUT <= result;
  
  	MEMER: entity work.barreira port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>uinsMEM, Q=>uinsER);

	 
end datapath;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--  Descri��o do Bloco de Controle (mista, estrutural-comportamental)
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_unsigned.all;
use work.p_MIPS_MCS.all;

entity control_unit is
        port(	ck, rst : in std_logic;
					inst_branch_in, salta_in : in std_logic;
					i_address : out std_logic_vector(31 downto 0);
					instruction : in std_logic_vector(31 downto 0);
					RESULT_IN : in std_logic_vector(31 downto 0);
					uins : out microinstruction;
					IR_OUT : out std_logic_vector(31 downto 0);
					NPC_OUT : out std_logic_vector(31 downto 0)
             );
end control_unit;
                   
architecture control_unit of control_unit is
   signal i : inst_type;
	signal uins_int : microinstruction;
	signal dtpc, npc, pc, incpc, IR  : std_logic_vector(31 downto 0);
begin
      
   --==============================================================================
   -- Instruction fetch and PC increment
   --==============================================================================
  
   M1: dtpc <=	RESULT_IN when (inst_branch_in='1' and salta_in='1') or uins_int.i=J
   			or uins_int.i=JAL or uins_int.i=JALR or uins_int.i=JR	else
   		npc;
   
	NPC_OUT <= npc;
   -- Code memory starting address: beware of the OFFSET! 
   -- The one below (x"00400000") serves for code generated 
   -- by the MARS simulator
   RPC: entity work.regnbits generic map(INIT_VALUE=>x"00400000")   
                            port map(ck=>ck, rst=>rst, ce=>uins_int.wpc, D=>dtpc, Q=>pc);

   incpc <= pc + 4;
  
   RNPCbidi: entity work.regnbits port map(ck=>ck, rst=>rst, ce=>uins_int.CY1, 
			D=>incpc, Q=>npc);     
           
   RIR: 	entity work.regnbits  port map(ck=>ck, rst=>rst, ce=>uins_int.CY1,
			D=>instruction, Q=>IR);

   IR_OUT <= IR ;    -- IR is the Instruction Register
             
   i_address <= pc;  -- connects PC output to the instruction memory address bus
   
   
    ----------------------------------------------------------------------------------------
    -- BLOCK (1/3) - INSTRUCTION DECODING and ALU operation definition.
    -- This block generates one signal (i) of the Control Unit Output Function
    ----------------------------------------------------------------------------------------
    i <=   ADDU   when IR(31 downto 26)="000000" and IR(10 downto 0)="00000100001" else
			  NOP    when IR(31 downto 26)="000000" and IR(10 downto 0)="00000100001" else
           SUBU   when IR(31 downto 26)="000000" and IR(10 downto 0)="00000100011" else
           AAND   when IR(31 downto 26)="000000" and IR(10 downto 0)="00000100100" else
           OOR    when IR(31 downto 26)="000000" and IR(10 downto 0)="00000100101" else
           XXOR   when IR(31 downto 26)="000000" and IR(10 downto 0)="00000100110" else
           NNOR   when IR(31 downto 26)="000000" and IR(10 downto 0)="00000100111" else
           SSLL   when IR(31 downto 21)="00000000000" and IR(5 downto 0)="000000" else
           SLLV   when IR(31 downto 26)="000000" and IR(10 downto 0)="00000000100" else
           SSRA   when IR(31 downto 21)="00000000000" and IR(5 downto 0)="000011" else
           SRAV   when IR(31 downto 26)="000000" and IR(10 downto 0)="00000000111" else
           SSRL   when IR(31 downto 21)="00000000000" and IR(5 downto 0)="000010" else
           SRLV   when IR(31 downto 26)="000000" and IR(10 downto 0)="00000000110" else
           ADDIU  when IR(31 downto 26)="001001" else
           ANDI   when IR(31 downto 26)="001100" else
           ORI    when IR(31 downto 26)="001101" else
           XORI   when IR(31 downto 26)="001110" else
           LUI    when IR(31 downto 26)="001111" else
           LW     when IR(31 downto 26)="100011" else
           LBU    when IR(31 downto 26)="100100" else
           SW     when IR(31 downto 26)="101011" else
           SB     when IR(31 downto 26)="101000" else
           SLTU   when IR(31 downto 26)="000000" and IR(5 downto 0)="101011" else
           SLT    when IR(31 downto 26)="000000" and IR(5 downto 0)="101010" else
           SLTIU  when IR(31 downto 26)="001011"                             else
           SLTI   when IR(31 downto 26)="001010"                             else
           BEQ    when IR(31 downto 26)="000100" else
           BGEZ   when IR(31 downto 26)="000001" and IR(20 downto 16)="00001" else
           BLEZ   when IR(31 downto 26)="000110" and IR(20 downto 16)="00000" else
           BNE    when IR(31 downto 26)="000101" else
           J      when IR(31 downto 26)="000010" else
           JAL    when IR(31 downto 26)="000011" else
           JALR   when IR(31 downto 26)="000000"  and IR(20 downto 16)="00000"
                                           and IR(10 downto 0) = "00000001001" else
           JR     when IR(31 downto 26)="000000" and IR(20 downto 0)="000000000000000001000" else

           invalid_instruction ; -- IMPORTANT: default condition is invalid instruction;
        
    assert i /= invalid_instruction
          report "******************* INVALID INSTRUCTION *************"
          severity error;
                   
    uins_int.i <= i;    -- this instructs the alu to execute its expected operation, if any

    ----------------------------------------------------------------------------------------
    -- BLOCK (2/3) - DATAPATH REGISTERS load control signals generation.
    -- This block generates all other signals of the Control Unit Output Function
    ----------------------------------------------------------------------------------------
    uins_int.CY1   <= '1';
            
    uins_int.CY2   <= '1';
  
    uins_int.walu  <= '1';
                
    uins_int.wmdr  <= '1';
  
    uins_int.wreg   <= '0' when  i=SW or
                                 i=SB or
                                 i=SLT or
                                 i=SLTU or
                                 i=SLTI or
                                 i=SLTIU or
                                 i=BEQ or
                                 i=BGEZ or
                                 i=BLEZ or
                                 i=BNE or
                                 i=J or
                                 i=JAL or
                                 i=JALR or
                                 i=JR       else '1';
   
    uins_int.rw    <= '1' when i=LUI or
                               i=LBU or
                               i=LW    else '0';
                  
    uins_int.ce   <= '1' when i=LUI or
                              i=LBU or
                              i=LW or
                              i=SB or
                              i=SW     else '0';
    
    uins_int.bw    <= '0' when i=SB   else '1';
      
    uins_int.wpc   <= '1';

	 uins <= uins_int;
    
end control_unit;

--------------------------------------------------------------------------
-- Processador MIPS_S completo, onde se instanciam BD e BC
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.p_MIPS_MCS.all;

entity MIPS_MCS is
    port( clock, reset: in std_logic;
          ce, rw, bw: out std_logic;
          i_address, d_address: out std_logic_vector(31 downto 0);
          instruction: in std_logic_vector(31 downto 0);
          data: inout std_logic_vector(31 downto 0));
end MIPS_MCS;

architecture MIPS_MCS of MIPS_MCS is
      signal IR, NPC, RESULT: std_logic_vector(31 downto 0);
      signal uins: microinstruction;  
	  signal inst_branch, salta, end_mul, end_div: std_logic;
 begin

     dp: entity work.datapath   
         port map(ck=>clock, rst=>reset, d_address=>d_address, data=>data,
		  inst_branch_out=>inst_branch, salta_out=>salta,
		  end_mul=>end_mul, end_div=>end_div, RESULT_OUT=>RESULT,
		  uins=>uins, IR_IN=>IR, NPC_IN=>NPC);

     ct: entity work.control_unit port map( ck=>clock, rst=>reset, 
		i_address=>i_address, instruction=>instruction,
		inst_branch_in=>inst_branch, salta_in=>salta, RESULT_IN=>RESULT,
		uins=>uins, IR_OUT=>IR, NPC_OUT=>NPC);
         
     ce <= uins.ce;
     rw <= uins.rw; 
     bw <= uins.bw;
     
end MIPS_MCS;