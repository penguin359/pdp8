---------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;
use work.control.ALL;
---------------------------------------------------------------------
entity cpu is
    --      mem_valid : in STD_LOGIC;
    Port(
        clk : in  STD_LOGIC;
        nrst : in  STD_LOGIC;

        -- UI Bus
        --   Panel to external interfaces
        --ld : out STD_LOGIC_VECTOR(7 downto 0);
        --anodes : out STD_LOGIC_VECTOR(3 downto 0);
        --cathodes : out STD_LOGIC_VECTOR(7 downto 0);

        -- Panel Bus
        --   Panel to CPU
        swreg : in STD_LOGIC_VECTOR(11 downto 0);
        dispsel : in STD_LOGIC_VECTOR(1 downto 0);
        run : in STD_LOGIC;
        loadpc : in STD_LOGIC;
        step : in STD_LOGIC;
        deposit : in STD_LOGIC;

        --   CPU to Panel
        dispout : out STD_LOGIC_VECTOR(11 downto 0);
        linkout : out STD_LOGIC;
        halt : out STD_LOGIC;

        -- IO Bus
        --   CPU to IOT Distributor
        bit1_cp2 : out STD_LOGIC;
        bit2_cp3 : out STD_LOGIC;
        io_address : out STD_LOGIC_VECTOR(2 downto 0);
        dataout : out STD_LOGIC_VECTOR(7 downto 0);

        --   IOT Distributor to CPU
        skip_flag : in STD_LOGIC;
        clearacc : in STD_LOGIC;
        datain : in STD_LOGIC_VECTOR(7 downto 0);

        -- UART Bus
        --   IOT Distributor to UART
        --clear_3 : STD_LOGIC;
        --load_3 : STD_LOGIC;
        --dataout_3 : STD_LOGIC_VECTOR(7 downto 0);

        --    UART to IOT Distributor
        --ready_3 : STD_LOGIC;
        --clearacc_3 : STD_LOGIC;
        --datain_3 : STD_LOGIC_VECTOR(7 downto 0);

        -- Memory Bus
        --   CPU to RAM
        address : out STD_LOGIC_VECTOR(11 downto 0);
        write_data : out STD_LOGIC_VECTOR(11 downto 0);
        write_enable : out STD_LOGIC;
        mem_load : out STD_LOGIC;

        --   RAM to CPU
        read_data : in STD_LOGIC_VECTOR(11 downto 0);
        mem_ready : in STD_LOGIC
    );
end cpu;
---------------------------------------------------------------------
architecture behavioral of cpu is
component state
    Port( clk : in  STD_LOGIC;
    	  run : in  STD_LOGIC;
    	  opcode : in  STD_LOGIC_VECTOR(2 downto 0);
    	  indirect : in  STD_LOGIC;
	  sel_ac : out sel_ac;
	  sel_pc : out sel_pc;
	  sel_skip : out sel_skip;
	  sel_addr : out sel_addr;
	  sel_data : out sel_data;
	  sel_iot : out sel_iot;
	  sel_ir : out sel_ir;
	  sel_ma : out sel_ma;
	  sel_md : out sel_md;
	  mem_read  : out STD_LOGIC;
	  mem_write  : out STD_LOGIC;
	  mem_valid  : in  STD_LOGIC;
    	  halted : out STD_LOGIC
    );
end component;

--type word is std_logic_vector(11 downto 0);
--signal ac : word := (others => '0');
--signal ir : word := (others => '0');
--signal ea : word := (others => '0');
--signal ac : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
--signal link : STD_LOGIC := '0';
signal link_ac : STD_LOGIC_VECTOR(12 downto 0) := (others => '0');
signal ac : STD_LOGIC_VECTOR(11 downto 0);
signal link : STD_LOGIC;
signal ir : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal ma : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal md : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
--signal ea : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal ea : STD_LOGIC_VECTOR(11 downto 0);
signal pc : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
signal skip : STD_LOGIC;

constant z_bit : INTEGER := 7;
constant i_bit : INTEGER := 8;

-- OPR (111) uC bits
constant uc_group1_bit : INTEGER := 8;
constant uc_group2_bit : INTEGER := 0;

type uc_group_t is (group1, group2, group3);
signal uc_group : uc_group_t;

-- uC Group 1 bits
constant cla_bit : INTEGER := 7;
constant cll_bit : INTEGER := 6;
constant cma_bit : INTEGER := 5;
constant cml_bit : INTEGER := 4;
constant rar_bit : INTEGER := 3;
constant ral_bit : INTEGER := 2;
constant bsw_bit : INTEGER := 1;
constant iac_bit : INTEGER := 0;

-- uC Group 2 bits
--constant cla_bit : INTEGER := 7;
constant sma_bit : INTEGER := 6;
constant sza_bit : INTEGER := 5;
constant snl_bit : INTEGER := 4;
constant and_bit : INTEGER := 3;
constant osr_bit : INTEGER := 2;
constant hlt_bit : INTEGER := 1;

-- uC Group 3 bits
--constant cla_bit : INTEGER := 7;
constant mqa_bit : INTEGER := 6;
constant sca_bit : INTEGER := 5;
constant mql_bit : INTEGER := 4;
-- 3:1 Code bits

-- uC decoded signals
signal en_cla : STD_LOGIC;
signal en_cll : STD_LOGIC;
signal en_cma : STD_LOGIC;
signal en_cml : STD_LOGIC;
signal en_rar : STD_LOGIC;
signal en_ral : STD_LOGIC;
signal en_rtr : STD_LOGIC;
signal en_rtl : STD_LOGIC;
signal en_bsw : STD_LOGIC;
signal en_iac : STD_LOGIC;
signal en_sma : STD_LOGIC;
signal en_sza : STD_LOGIC;
signal en_snl : STD_LOGIC;
signal en_and : STD_LOGIC;

signal uc1_stage1 : STD_LOGIC_VECTOR(12 downto 0);
signal uc1_stage2 : STD_LOGIC_VECTOR(12 downto 0);
signal uc1_stage3 : STD_LOGIC_VECTOR(12 downto 0);
signal uc1_stage4 : STD_LOGIC_VECTOR(12 downto 0);

signal uc2_stage1 : STD_LOGIC_VECTOR(12 downto 0);
signal uc2_skip   : STD_LOGIC;

signal uc_link_ac : STD_LOGIC_VECTOR(12 downto 0);
signal uc_skip   : STD_LOGIC;

signal sel_ac : sel_ac;
signal sel_pc : sel_pc;
signal sel_skip: sel_skip;
signal sel_addr : sel_addr;
signal sel_data : sel_data;
signal sel_iot : sel_iot;
signal sel_ir : sel_ir;
signal sel_ma : sel_ma;
signal sel_md : sel_md;

signal md_clear : STD_LOGIC;
signal iot_skip2 : STD_LOGIC;

signal iot_bits : STD_LOGIC_VECTOR(2 downto 0);

signal mem_read, mem_write : STD_LOGIC;

begin
	inst_state: state Port Map(
		clk => clk,
		run => '1',
		opcode => ir(11 downto 9),
		indirect => ir(i_bit),
		sel_ac => sel_ac,
		sel_pc => sel_pc,
		sel_skip => sel_skip,
		sel_addr => sel_addr,
		sel_data => sel_data,
		sel_iot => sel_iot,
		sel_ir => sel_ir,
		sel_ma => sel_ma,
		sel_md => sel_md,
		--mem_read => open,  -- TODO Should this be implemented?
		mem_read => mem_read,
		mem_write => mem_write,
		mem_valid => mem_ready,
		halted => open
	);

	with sel_addr select address <=
		ea when addr_ea,
		ma when addr_ma,
		pc when addr_pc,
		ea when others;

	with sel_data select write_data <=
		ac when data_ac,
		md when data_md,
		--pc when data_pc,
		pc+1 when data_pc1,
		ea when others;

	-- Address calculation
	--process(clk)
	--variable page : std_logic_vector(11 downto 7);
	--begin
	--	if rising_edge(clk) then
	--		if ir(z_bit) = '1' then
	--			page := pc(11 downto 7);
	--		else
	--			page := (others => '0');
	--		end if;
	--		ea <= page & ir(6 downto 0);
	--	end if;
	--end process;
	process(pc(11 downto 7), ir(z_bit), ir(6 downto 0))
	variable page : std_logic_vector(11 downto 7);
	begin
		if ir(z_bit) = '1' then
			page := pc(11 downto 7);
		else
			page := (others => '0');
		end if;
		ea <= page & ir(6 downto 0);
	end process;

	-- Program Counter
	process(clk)
	begin
		if rising_edge(clk) then
			if sel_pc = pc_data then
				pc <= read_data;
			elsif sel_pc = pc_ma then
				pc <= ma;
			elsif sel_pc = pc_ma1 then
				pc <= ma + 1;
			elsif sel_pc = pc_incr then
				if skip = '1' then
					pc <= pc + 2;
				else
					pc <= pc + 1;
				end if;
			end if;
		end if;
	end process;

	-- Accumulator and Link
	process(clk)
	begin
		if rising_edge(clk) then
			if sel_ac = ac_and_md then
				link_ac <= link_ac and ("1" & md);
			elsif sel_ac = ac_add_md then
				link_ac <= link_ac + ("0" & md);
			elsif sel_ac = ac_zero then
				link_ac <= link & "000000000000";
			elsif sel_ac = ac_uc then
				link_ac <= uc_link_ac;
			elsif sel_ac = ac_iot then
				if clearacc = '1' then
					link_ac <= link & "0000" & datain;
				else
					link_ac <= link & (ac OR "0000" & datain);
				end if;
			end if;
		end if;
	end process;

	-- Instruction Register
	process(clk)
	begin
		if rising_edge(clk) then
			if sel_ir = ir_data then
				ir <= read_data;
			end if;
		end if;
	end process;

	-- Memory Address
	process(clk)
	begin
		if rising_edge(clk) then
			if sel_ma = ma_data then
				ma <= read_data;
			elsif sel_ma = ma_ea then
				ma <= ea;
			end if;
		end if;
	end process;

	-- Memory Data
	process(clk)
	begin
		if rising_edge(clk) then
			if sel_md = md_data then
				md <= read_data;
			elsif sel_md = md_data1 then
				md <= read_data + 1;
			end if;
		end if;
	end process;
	md_clear <= '1' when md = "000000000000" else '0';

	iot_skip2 <= '1' when skip_flag = '1' and ir(0) = '1' else '0';
	with sel_skip select
	skip <= md_clear when skip_md_clear,
		uc_skip  when skip_uc,
		iot_skip2 when skip_iot,
		'0'      when others;

	-- Decoding OPR instructions
	uc_group <= group1 when ir(uc_group1_bit) = '0' else
		    group2 when ir(uc_group2_bit) = '0' else
		    group3;

	en_cla <= ir(cla_bit);
	en_cll <= ir(cll_bit);
	en_cma <= ir(cma_bit);
	en_cml <= ir(cml_bit);
	en_iac <= ir(iac_bit);
	en_sma <= ir(sma_bit);
	en_sza <= ir(sza_bit);
	en_snl <= ir(snl_bit);
	en_and <= ir(and_bit);

	process(ir(rar_bit downto bsw_bit))
	begin
		en_rar <= '0';
		en_rtr <= '0';
		en_ral <= '0';
		en_rtl <= '0';
		en_bsw <= '0';
		case ir(rar_bit downto bsw_bit) is
			when "100" => en_rar <= '1';
			when "101" => en_rtr <= '1';
			when "010" => en_ral <= '1';
			when "011" => en_rtl <= '1';
			when "001" => en_bsw <= '1';
			when others =>
		end case;
	end process;

	-- uC Group 1 processing
	uc1_stage1(11 downto 0) <= (others => '0')  when en_cla = '1' else ac;
	uc1_stage1(12)          <= '0'              when en_cll = '1' else link;
	uc1_stage2(11 downto 0) <= not uc1_stage1(11 downto 0) when en_cma = '1' else uc1_stage1(11 downto 0);
	uc1_stage2(12)          <= not uc1_stage1(12) when en_cml = '1' else uc1_stage1(12);
	uc1_stage3 <= uc1_stage2 + 1 when en_iac = '1' else uc1_stage2;
	uc1_stage4 <= uc1_stage3(11 downto 00) & uc1_stage3(12 downto 12) when en_ral = '1' else
		     uc1_stage3(10 downto 00) & uc1_stage3(12 downto 11) when en_rtl = '1' else
		     uc1_stage3(00 downto 00) & uc1_stage3(12 downto 01) when en_rar = '1' else
		     uc1_stage3(01 downto 00) & uc1_stage3(12 downto 02) when en_rtr = '1' else
		     uc1_stage3(12) & uc1_stage3(5 downto 0) & uc1_stage3(11 downto 6) when en_bsw = '1' else
		     uc1_stage3;

	-- uC Group 2 processing
	uc2_stage1(11 downto 0) <= (others => '0')  when en_cla = '1' else ac;
	uc2_stage1(12)          <= link;

	uc2_skip <= '1' when ((en_sma = '1' and ac(11) = '1') or
			      (en_sza = '1' and ac = "000000000000") or
			      (en_snl = '1' and link = '1')) xor
			     en_and = '1' else '0';

	process(uc_group, uc1_stage4, uc2_stage1, uc2_skip, link_ac)
	begin
		case uc_group is
			when group1 =>
				uc_link_ac <= uc1_stage4;
				uc_skip <= '0';
			when group2 =>
				uc_link_ac <= uc2_stage1;
				uc_skip <= uc2_skip;
			when group3 =>
				uc_link_ac <= link_ac;
				uc_skip <= '0';
		end case;
	end process;

	ac <= link_ac(11 downto 0);
	link <= link_ac(12);

        -- TODO Should all ac bits be supported?
	--dataout <= ac;
	dataout <= ac(7 downto 0);
        -- TODO Support all address bits
	--io_address <= ir(8 downto 3) when sel_iot = iot_en else "000000";
	io_address <= ir(8 downto 6) when sel_iot = iot_en else "000000";
	iot_bits <= ir(2 downto 0);

        bit1_cp2 <= iot_bits(1);
        bit2_cp3 <= iot_bits(2);

        mem_load <= mem_write OR mem_read;
        write_enable <= mem_write;
end behavioral;

--10 ... 02 01 00 12 11 RTL
--11 10 ... 02 01 00 12 RAL
--12 11 10 ... 02 01 00
--00 12 11 10 ... 02 01 RAR
--01 00 12 11 10 ... 02 RTR
