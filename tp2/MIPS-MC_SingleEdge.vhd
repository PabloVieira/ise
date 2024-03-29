-------------------------------------------------------------------------
--
-- I M P L E M E N T A   O   P A R C I A L  D O  M I P S   (nov/2010)
--
--  Professores     Fernando Moraes / Ney Calazans
--
--  ==> The top-level processor entity is MRstd
--  21/06/2010 (Ney) - Bug corrigido no mux que gera op1 - agora recebe
--		npc e no pc.
--  17/11/2010 (Ney) - Bugs corrigidos:
--		1 - Decodificao das instrues BGEZ e BLEZ estava 
--		incompleta
--		2 - Definio de que linhas escolhem o registrador a
--		ser escrito nas instrues de deslocamento 
--		(SSLL, SLLV, SSRA, SRAV, SSRL e SRLV)
--  05/06/2012 (Ney) - Mudanas menores em nomenclatura
--  19/11/2015 (Ney) - Mudana para MIPS-MC Single Clock Edge
--			Alm das mudanas bvias de sensibilidade de elementos de 
--			memria para somente borda de subida, tambm mudou-se o
--			ponto de onde as entradas de dados do multiplicador e do
--			divisor provm, agora direto do banco de registradores e no
--			dos registradores RA e RB. Ainda, mudou-se a estrutura dos 
--			blocos de dados e controle. O Bloco de Controle agora
--			contm o PC, o NPC e o IR e naturalmente a interface com
--			a memria de instrues. Foi eliminado o estado Sidle, 
--			por no ser mais necessrio.
--  04/07/2016 (Ney) - Diversas revises em nomes de sinais para 
--			aumentar a intuitividade da descrio, mudana do
--			nome do processador para MIPS_S (ver documentao, verso 2.0
--			ou superior).
--  05/08/2016 (Ney) - Correcao e adaptacao dos nomes de sinais e
--			blocos para facilitar aprendizado. Processador agora se chama
--			MIPS_MCS (MIPS Multi-Ciclo Single Edge)
-------------------------------------------------------------------------

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- package com os tipos bsicos auxiliares para descrever o processador
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.Std_Logic_1164.all;

package p_MIPS_MCS is  
    
    -- inst_type define as instrues decodificveis pelo bloco de controle
    type inst_type is  
            ( ADDU, NOP, SUBU, AAND, OOR, XXOR, NNOR, SSLL, SLLV, SSRA, SRAV,
				SSRL, SRLV,ADDIU, ANDI, ORI, XORI, LUI, LBU, LW, SB, SW, SLT,
				SLTU, SLTI,	SLTIU, BEQ, BGEZ, BLEZ, BNE, J, JAL, JALR, JR, 
				invalid_instruction);
 
    type microinstruction is record
            CY1:   std_logic;       -- command of the first stage
            CY2:   std_logic;       --    "    of the second stage
            walu:  std_logic;       --    "    of the third stage
            wmdr:  std_logic;       --    "    of the fourth stage
            wpc:   std_logic;       -- PC write enable
            wreg:  std_logic;       -- register bank write enable
            whilo: std_logic;       -- habilitao de escrita nos registradores HI e LO
            ce:    std_logic;       -- Chip enable and R_W controls
            rw:    std_logic;
            bw:    std_logic;       -- Byte-word control (mem write only)
            i:     inst_type;       -- operation specification
            rst_md:std_logic;       -- mult and div initialization
    end record;
         
end p_MIPS_MCS;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Registrador de uso geral - sensvel  borda de subida do relgio (ck), 
--		com reset assncrono (rst) e habilitao de escrita (ce)
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

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Banco de Registradores  (R0..R31) - 31 registradores de 32 bits
-- 	Trata-se de uma memria com trs portas de acesso, no confundir
--		com a memria principal do processador. 
--		So duas portas de leitura (sinais AdRP1+DataRP1 e AdRP2+DataRP2) e
--		uma porta de escrita (dedfinida pelo conjunto de sinais 
--    ck, rst, ce, AdWP e DataWP).
--		Os endereos de cada porta (AdRP1, AdRP2 e AdWP) so obviamente de
--		5 bits (pois 2^5=32), enquanto que os barramentos de dados de 
--		sada (DataRP1, DataRP2) e de entrada (DataWP) so de 32 bits.
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
-- ALU - Uma unidade lgico-aritmtica puramente combinacional, cuja 
--		sada depende dos valores nas suas entradas de dados op1 e op2, cada
--		uma de 32 bits e da instruo sendo executada pelo processador
--		que  informada via o sinal de controle op_alu.
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
-- Descrio Estrutural do Bloco de Dados 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_signed.all; -- needed for comparison instructions SLTx
use IEEE.Std_Logic_arith.all; -- needed for comparison instructions SLTxU
use work.p_MIPS_MCS.all;
   
entity datapath is
      port(  ck, rst :     in std_logic;
             d_address, i_address :   out std_logic_vector(31 downto 0);
             instruction: in std_logic_vector(31 downto 0);
				 data :        inout std_logic_vector(31 downto 0); 
             uins :        out microinstruction
          );
end datapath;

architecture datapath of  datapath is
    signal result, R1, R2, RS, RT, RIN, sign_extend, cte_im, IMED, op1, op2, 
           outalu, RALU, MDR, mdr_int : std_logic_vector(31 downto 0) := (others=> '0');
    signal adD, adS : std_logic_vector(4 downto 0) := (others=> '0');    
    signal inst_branch, inst_R_sub, inst_I_sub: std_logic;   
    signal salta : std_logic := '0';
	 signal IR, NPC: std_logic_vector(31 downto 0);
	 signal uinsDI, uinsEX, uinsMEM, uinsER: microinstruction;
	 
begin

   -- auxiliary signals 
   inst_branch  <= '1' when uinsDI.i=BEQ or uinsDI.i=BGEZ or uinsDI.i=BLEZ or uinsDI.i=BNE else 
                  '0';
   
	-- inst_R_sub is a subset of R-type instructions
   inst_R_sub  <= '1' when uinsDI.i=ADDU or uinsDI.i=NOP or uinsDI.i=SUBU or uinsDI.i=AAND
                         or uinsDI.i=OOR or uinsDI.i=XXOR or uinsDI.i=NNOR else
                   '0';

	-- inst_I is a subset of I-type instructions
   inst_I_sub  <= '1' when uinsDI.i=ADDIU or uinsDI.i=ANDI or uinsDI.i=ORI or uinsDI.i=XORI else
                   '0';

   --==============================================================================
   -- second stage
   --==============================================================================
	
	ct: entity work.control_unit port map( ck=>clock, rst=>reset, 
				i_address=>i_address, instruction=>instruction,
				inst_branch_in=>inst_branchDI, salta_in=>salta, 
				RESULT_IN=>result,
				uins=>uins, IR_OUT=>IR, NPC_OUT=>NPC
			);
                
   -- The then clause is only used for logic shifts with a shamt field       
   M3: adS <= IR(20 downto 16) when uinsDI.i=SSLL or uinsDI.i=SSRA or uinsDI.i=SSRL else 
          IR(25 downto 21);
          
   REGS: entity work.reg_bank(reg_bank) port map
        (AdRP1=>adS, DataRP1=>R1, AdRP2=>IR(20 downto 16), DataRP2=>R2,
		   ck=>ck, rst=>rst, ce=>uinsDI.wreg, AdWP=>adD, DataWP=>RIN);
    
   -- sign extension 
   sign_extend <=  x"FFFF" & IR(15 downto 0) when IR(15)='1' else
             x"0000" & IR(15 downto 0);
    
   -- Immediate constant
   M5: cte_im <= sign_extend(29 downto 0)  & "00"     when inst_branchDI='1'			else
                -- branch address adjustment for word frontier
             "0000" & IR(25 downto 0) & "00" when uinsDI.i=J or uinsDI.i=JAL 		else
                -- J/JAL are word addressed. MSB four bits are defined at the ALU, not here!
             x"0000" & IR(15 downto 0) when uinsDI.i=ANDI or uinsDI.i=ORI  or uinsDI.i=XORI 	else
                -- logic instructions with immediate operand are zero extended
             sign_extend;
                -- The default case is used by addiu, lbu, lw, sbu and sw instructions
             
   -- second stage registers
   RSreg:  entity work.regnbits port map(ck=>ck, rst=>rst, ce=>uinsDI.CY2, D=>R1, Q=>RS);

   RTreg:  entity work.regnbits port map(ck=>ck, rst=>rst, ce=>uinsDI.CY2, D=>R2, Q=>RT);
  
   RIM: entity work.regnbits port map(ck=>ck, rst=>rst, ce=>uinsDI.CY2, D=>cte_im, Q=>IMED);
 
 
  --==============================================================================
   -- third stage
   --==============================================================================
                      
   -- select the first ALU operand                           
   M6: op1 <= NPC  when inst_branch='1' else 
          RS; 
     
   -- select the second ALU operand
   M7: op2 <= RT when inst_R_sub='1' or uinsEX.i=SLTU or uinsEX.i=SLT or uinsEX.i=JR 
                  or uinsEX.i=SLLV or uinsEX.i=SRAV or uinsEX.i=SRLV else 
          IMED; 
                 
   -- ALU instantiation
   DALU: entity work.alu port map (op1=>op1, op2=>op2, outalu=>outalu, op_alu=>uinsEX.i);
   
   -- ALU register
   Reg_ALU: entity work.regnbits  port map(ck=>ck, rst=>rst, ce=>uinsEX.walu, 
				D=>outalu, Q=>RALU);               
 
   -- evaluation of conditions to take the branch instructions
   salta <=  '1' when ( (RS=RT  and uinsEX.i=BEQ)  or (RS>=0  and uinsEX.i=BGEZ) or
                        (RS<=0  and uinsEX.i=BLEZ) or (RS/=RT and uinsEX.i=BNE) )  else
             '0';        

   --==============================================================================
   -- fourth stage
   --==============================================================================
     
   d_address <= RALU;
    
   -- tristate to control memory write    
   data <= RT when (uinsER.ce='1' and uinsER.rw='0') else (others=>'Z');  

   -- single byte reading from memory  -- assuming the processor is little endian
   M8: mdr_int <= data when uinsER.i=LW  else
              x"000000" & data(7 downto 0);
       
   RMDR: entity work.regnbits  port map(ck=>ck, rst=>rst, ce=>uinsMEM.wmdr,
			D=>mdr_int, Q=>MDR);                 
  
   M9: result <=    MDR when uinsMEM.i=LW  or uinsMEM.i=LBU else
                RALU;

   --==============================================================================
   -- fifth stage
   --==============================================================================

   -- signal to be written into the register bank
   M2: RIN <= NPC when (uinsER.i=JALR or uinsER.i=JAL) else result;
   
   -- register bank write address selection
   M4: adD <= "11111"           when uinsEX.i=JAL else -- JAL writes in register $31
         IR(15 downto 11)    when (inst_R_sub='1' 
								or uinsEX.i=SLTU or uinsEX.i=SLT
								or uinsEX.i=JALR
								or uinsEX.i=SSLL or uinsEX.i=SLLV
								or uinsEX.i=SSRA or uinsEX.i=SRAV
								or uins.i=SSRL or uins.i=SRLV) else
         IR(20 downto 16) -- inst_I_sub='1' or uins.i=SLTIU or uins.i=SLTI 
        ;                 -- or uins.i=LW or  uins.i=LBU  or uins.i=LUI, or default
	 
end datapath;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--  Descrio do Bloco de Controle (mista, estrutural-comportamental)
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
   type type_state is (Sfetch, Sreg, Salu, Swbk, Sld, Sst, Ssalta); -- Sidle, 
   signal PS, NS : type_state;
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
  
   RNPC: entity work.regnbits port map(ck=>ck, rst=>rst, ce=>uins_int.CY1, 
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
			  NOP    when IR(31 downto 26)="000000" and IR(10 downto 0)="00000000000" else
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
           MULTU  when IR(31 downto 26)="000000" and IR(15 downto 0)="0000000000011001" else
           DIVU   when IR(31 downto 26)="000000" and IR(15 downto 0)="0000000000011011" else
           MFHI   when IR(31 downto 16)=x"0000" and IR(10 downto 0)="00000010000" else
           MFLO   when IR(31 downto 16)=x"0000" and IR(10 downto 0)="00000010010" else
           invalid_instruction ; -- IMPORTANT: default condition is invalid instruction;
        
    assert i /= invalid_instruction
          report "******************* INVALID INSTRUCTION *************"
          severity error;
                   
    uins_int.i <= i;    -- this instructs the alu to execute its expected operation, if any

    ----------------------------------------------------------------------------------------
    -- BLOCK (2/3) - DATAPATH REGISTERS load control signals generation.
    -- This block generates all other signals of the Control Unit Output Function
    ----------------------------------------------------------------------------------------
    uins_int.CY1   <= '1' when PS=Sfetch         else '0';
            
    uins_int.CY2   <= '1' when PS=Sreg           else '0';
  
    uins_int.walu  <= '1' when PS=Salu           else '0';
                
    uins_int.wmdr  <= '1' when PS=Sld            else '0';
  
    uins_int.wreg   <= '1' when PS=Swbk or (PS=Ssalta and (i=JAL or i=JALR)) else   '0';
   
    uins_int.rw    <= '0' when PS=Sst            else  '1';
                  
    uins_int.ce    <= '1' when PS=Sld or PS=Sst  else '0';
    
    uins_int.bw    <= '0' when PS=Sst and i=SB   else '1';
      
    uins_int.wpc   <= '1' when PS=Swbk or PS=Sst or PS=Ssalta 
	 		or (PS=Salu and ((i=MULTU and end_mul='1')
			or (i=DIVU and end_div='1'))) else  '0';

    uins_int.whilo   <= '1' when (PS=Salu and end_mul='1' and i=MULTU)
			  or (PS=Salu and end_div='1' and i=DIVU) 
			else  '0';

    uins_int.rst_md   <= '1' when PS=Sreg and (i=MULTU or i=DIVU) else  '0';

	 uins <= uins_int;
    ---------------------------------------------------------------------------------------------
    -- BLOCK (3/3) - Sequential part of the control unit - two processes implementing the
    -- Control Unit state register and the (combinational) next-state function
    --------------------------------------------------------------------------------------------- 
    process(rst, ck)
    begin
       if rst='1' then
            PS <= Sfetch;      
				-- Sfetch is the state the machine stays while processor is being reset
       elsif ck'event and ck='1' then
				PS <= NS;
       end if;
    end process;
     
     
    process(PS, i, end_mul, end_div)
    begin
       case PS is         
            -- first stage:  read the instruction pointed to by the PC
            --
            when Sfetch=>NS <= Sreg;  
     
            -- second stage: read the register bank and produce immediate data,
            -- if needed
            when Sreg=>NS <= Salu;  
             
            -- third stage: alu operation 
            --
            when Salu =>if (i=LBU or i=LW) then 
										NS <= Sld;  
								elsif (i=SB or i=SW) then 
										NS <= Sst;
								elsif (i=J or i=JAL or i=JALR or i=JR or i=BEQ
                               or i=BGEZ or i=BLEZ  or i=BNE) then 
										NS <= Ssalta;
								elsif ((i=MULTU and end_mul='0') or (i=DIVU and end_div='0')) then
										NS <= Salu;
								elsif ((i=MULTU and end_mul='1') or (i=DIVU and end_div='1')) then
										NS <= Sfetch;
								else 
										NS <= Swbk; 
								end if;
                         
            -- fourth stage: data memory operation  
            --
            when Sld=>  NS <= Swbk; 
            
            -- forth or fifth cycle: last for most instructions  - GO BACK TO FETCH
            -- 
            when Sst | Ssalta | Swbk=> 
								NS <= Sfetch;
  
       end case;

    end process;
    
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
      signal uins: microinstruction;  
 begin

     dp: entity work.datapath   
         port map(ck=>clock, rst=>reset, d_address=>d_address, data=>data,
				uins=>uins
			);
         
     ce <= uins.ce;
     rw <= uins.rw; 
     bw <= uins.bw;
     
end MIPS_MCS;