----------------------------------------
-- Hardware divider, based on shift registers
-- On reset loads the dividend, and on reset falling edge
-- loads the divisor. Runs N clock cycles, and then activates the done
-- signal.
-- Intended use is to activate reset, input dividend and divisor, then drop reset
-- and read the output after done signal.
----------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY  Divide IS
	GENERIC (N : INTEGER := 32;
			 K : INTEGER := 5 );-- log2(N)
	PORT(	clk, sysrst, divrst, ena	: IN STD_LOGIC;
			done			: OUT STD_LOGIC;
			Dividend, Divisor : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			Residue, Quotient : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
			);
END Divide;

ARCHITECTURE behavior OF Divide IS

SIGNAL dividend_left_shift_reg		: STD_LOGIC_VECTOR(2*N-1 DOWNTO 0);
SIGNAL divisor_reg, quotient_reg	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
SIGNAL sub_res						: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
SIGNAL not_neg						: STD_LOGIC;
SIGNAL count						: STD_LOGIC_VECTOR(K DOWNTO 0);	
SIGNAL run,rst						: STD_LOGIC;

BEGIN
	------ CONTROL LOGIC ------
	rst <= sysrst or divrst;
	done <= not run;		-- This bit is 1 after N cycles of the algorithm
	run <= (not count(K)) and ena; -- Keep running while the module is enabled, and we haven't finished
	
	----- SUBTRACTOR LOGIC -----
	-- Subtractor and negative result checker for the module
	sub_res <= dividend_left_shift_reg(2*N-2 DOWNTO N-1) - divisor_reg; -- sub the part that is going to be shifted
	not_neg <= not sub_res(N-1);
	
	------ REGISTER LOGIC ------
	-- Dividend reg logic. If reset, then load lower half with input, load upper half with zeros.
	-- On each clock cycle if enabled, then check if subtractor result is negative. If it is, then
	-- shift left the register without changing anything else. If it is non-negative, then load the
	-- result to the uppper half, and then shift left everything left.
	dividendReg: PROCESS (clk, rst) 
	VARIABLE load_data : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	BEGIN
		IF (rst='1') then
			dividend_left_shift_reg(N-1 DOWNTO 0) <= Dividend;
			dividend_left_shift_reg(2*N-1 DOWNTO N) <= (others => '0');
		ELSIF (rising_edge(clk) and run='1') THEN		
			IF (not_neg='1') THEN
				load_data := sub_res; -- change data to sub result
			ELSE
				load_data := dividend_left_shift_reg(2*N-2 DOWNTO N-1); -- keep data
			END IF;
			dividend_left_shift_reg <= load_data & dividend_left_shift_reg(N-2 DOWNTO 0) & '0'; -- shift left
		END IF;
	END PROCESS;
	
	-- Divisor reg logic. On reset drop load new divisor.
	divisorReg: PROCESS (rst) 
	BEGIN
		IF (rst='1') then
			divisor_reg <= Divisor;
		END IF;
	END PROCESS;
	
	-- Quotient reg logic. On reset set to all zeros. Afterwards check if subtract result is negative,
	-- and shift left chaining a 1 if it is non-negative, and 0 otherwise.
	quotientReg: PROCESS (clk, rst) 
	BEGIN
		IF (rst='1') then
			quotient_reg <= (others => '0');
		ELSIF (rising_edge(clk) and run='1') THEN
			quotient_reg <= quotient_reg(N-2 DOWNTO 0) & not_neg;
		END IF;
	END PROCESS;
	
	Quotient <= quotient_reg;
	Residue  <= dividend_left_shift_reg(2*N-1 DOWNTO N);
	-- Keep count for the algorithm, after N cycles we are done.
	counter: PROCESS (clk, rst) 
	BEGIN
		IF (rst='1') then
			count(K-1 DOWNTO 0) <= (others => '0');
			count(K) <= sysrst;
		ELSIF (rising_edge(clk) and run='1') THEN
				count <= count + 1;
		END IF;
	END PROCESS;
	
	
END behavior;

