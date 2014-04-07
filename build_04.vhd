--library declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity build04 is
port(
RS, RW, E, BL, PWR					:	out std_logic;
PBA, PBB, PBC, PBD, clk50			:	in std_logic;
DB											:	out std_logic_vector(7 downto 0);
OP1, OP2									:	out std_logic_vector(7 downto 0);
data										:	in std_logic_vector (7 downto 0);
OO, OO1									:	out std_logic;
data2										:	in std_logic_vector (7 downto 0)
);
end entity build04;

architecture behavior of build04 is
type character_string is array (0 to 31) of std_logic_vector (7 downto 0);
type state_type is 	(initialize, return_home, RIP, curstate,
							line2, print_disp, hold, homescreens, e_drop,
							infoscreens, startscreens, ingame, testing2,
							endgame, processing, testing, newstate);
signal next_char															:	std_logic_vector(7 downto 0);
signal page, localstate, print_localstate, state_localstate	:	integer :=0;
signal reset_e																:	integer :=0;
signal init																	:	std_logic :='0';
signal memstate															:	unsigned(15 downto 0);
signal clkcount, wrkcnt													:	unsigned(23 downto 0);
signal resetcnt															:	unsigned(23 downto 0);
signal enable, clk10k													:	std_logic :='0';
signal char_count															:	unsigned(4 downto 0);
signal state, next_state, nowstate, prev_state					:	state_type;
signal SPBA, SPBB, SPBC, SPBD											:	std_logic;
signal aggdata, aggOP													:	std_logic_vector(15 downto 0);

--memory signals
signal curmemory	:character_string;
signal memoryx		:character_string;
signal memory1		:character_string;
signal memory2		:character_string;
signal memory3		:character_string;
signal memory4		:character_string;
signal memory5		:character_string;
signal memory6		:character_string;
signal memory7		:character_string;
signal memory8		:character_string;
signal memory9		:character_string;
signal memory10	:character_string;
signal memory11	:character_string;
signal memory12	:character_string;
signal memory13	:character_string;

begin
--all spaces (blank screen)
memoryx <= ( X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF", X"20", X"FF", X"FF", X"FF", X"FF", X"FF", X"FF");
--Lunar Lander!   To begin push B0
memory1 <= ( X"4c", X"75", X"6e", X"61", X"72", X"20", X"4c", X"61", X"6e", X"64", X"65", X"72", X"21", X"20", X"20", X"20", X"54", X"6f", X"20", X"62", X"65", X"67", X"69", X"6e", X"20", X"70", X"75", X"73", X"68", X"20", X"42", X"30");
--For info push B3 to start push B0
memory2 <= ( X"46", X"6f", X"72", X"20", X"69", X"6e", X"66", X"6f", X"20", X"70", X"75", X"73", X"68", X"20", X"42", X"33", X"74", X"6f", X"20", X"73", X"74", X"61", X"72", X"74", X"20", X"70", X"75", X"73", X"68", X"20", X"42", X"30");

----------------------------
--beginning of infoscreens--
----------------------------
--to advance info press KEY0
memory3 <= ( X"74", X"6f", X"20", X"61", X"64", X"76", X"61", X"6e", X"63", X"65", X"20", X"69", X"6e", X"66", X"6f", X"20", X"70", X"72", X"65", X"73", X"73", X"20", X"4b", X"45", X"59", X"30", X"20", X"20", X"20", X"20", X"20", X"20");
--KEY3 - Select KEY0 - Enter
memory4 <= ( X"4b", X"45", X"59", X"33", X"20", X"2d", X"20", X"53", X"65", X"6c", X"65", X"63", X"74", X"20", X"20", X"20", X"4b", X"45", X"59", X"30", X"20", X"2d", X"20", X"45", X"6e", X"74", X"65", X"72", X"20", X"20", X"20", X"20");
--the purpose of this game is to
memory5 <= ( X"74", X"68", X"65", X"20", X"70", X"75", X"72", X"70", X"6f", X"73", X"65", X"20", X"6f", X"66", X"20", X"20", X"74", X"68", X"65", X"20", X"67", X"61", X"6d", X"65", X"20", X"69", X"73", X"20", X"74", X"6f", X"20", X"20");
--land on the moon with a lander
memory6 <= ( X"6c", X"61", X"6e", X"64", X"20", X"6f", X"6e", X"20", X"74", X"68", X"65", X"20", X"6d", X"6f", X"6f", X"6e", X"77", X"69", X"74", X"68", X"20", X"61", X"20", X"6c", X"61", X"6e", X"64", X"65", X"72", X"20", X"20", X"20");
--SW17-14 control time engine fire
memory7 <= ( X"53", X"57", X"31", X"37", X"2d", X"31", X"34", X"20", X"63", X"6f", X"6e", X"74", X"72", X"6f", X"6c", X"20", X"74", X"69", X"6d", X"65", X"20", X"65", X"6e", X"67", X"69", X"6e", X"65", X"20", X"66", X"69", X"72", X"65");
--SW11-5 control percent thrust
memory8 <= ( X"53", X"57", X"31", X"31", X"2d", X"35", X"20", X"63", X"6f", X"6e", X"74", X"72", X"6f", X"6c", X"20", X"20", X"70", X"65", X"72", X"63", X"65", X"6e", X"74", X"20", X"74", X"68", X"72", X"75", X"73", X"74", X"20", X"20");
--you must land slow to survive
memory9 <= ( X"79", X"6f", X"75", X"20", X"6d", X"75", X"73", X"74", X"20", X"6c", X"61", X"6e", X"64", X"20", X"20", X"20", X"73", X"6c", X"6f", X"77", X"20", X"74", X"6f", X"20", X"73", X"75", X"72", X"76", X"69", X"76", X"65", X"20");
--Good luck! hit ENT to begin
memory10<= ( X"47", X"6f", X"6f", X"64", X"20", X"6c", X"75", X"63", X"6b", X"21", X"20", X"20", X"20", X"20", X"20", X"20", X"68", X"69", X"74", X"20", X"45", X"4e", X"54", X"20", X"74", X"6f", X"20", X"62", X"65", X"67", X"69", X"6e");
--you start 5km   above the surf. 
memory11<= ( X"79", x"6f", x"75", x"20", x"73", x"74", x"61", x"72", x"74", x"20", x"35", x"6b", x"6d", x"20", x"20", x"20", x"61", x"62", x"6f", x"76", x"65", x"20", x"74", x"68", x"65", x"20", x"73", x"75", x"72", x"66", x"2e", x"20");
--alt:5000m       spd:10 fuel:100%
memory12<= ( X"61", x"6c", x"74", x"3a", x"35", x"30", x"30", x"30", x"6d", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"73", x"70", x"64", x"3a", x"31", x"30", x"20", x"66", x"75", x"65", x"6c", x"3a", x"31", x"30", x"30", x"25");


----------------------
--end of infoscreens--
----------------------

------------------------------------------------
--end memory for start and information screens--
------------------------------------------------

with memstate select
	curmemory <=	memory1	when X"0001",	--homescreen1
						memory2	when X"0002",	--homescreen2
						memory3	when X"0003",	--infoscreen1
						memory4	when X"0004",	--infoscreen2
						memory5	when X"0005",	--infoscreen3
						memory6	when X"0006",	--infoscreen4
						memory7	when X"0007",	--infoscreen5
						memory8	when X"0008",	--infoscreen6
						memory9	when X"0009",	--infoscreen7
						memory10	when X"000A",	--infoscreen8
						memory11 when X"000B",	--startscreen0
						memory12 when X"000C",	--startscreen1
						memoryx	when others;	--all x's (is error state)

--get next character in memory
next_char <= curmemory(to_integer(unsigned(char_count)));

--aggdata is all inputs in one long string
aggdata <= data & data2;

--leave power, backlight on
PWR <= '1';
BL <= '1';
--leave RW in write mode since read mode is never used
RW <= '0';
--OP1 <= "11111111";

--single push input pins, cause them to only work once each push
btnpush : process (all)
begin
if falling_edge(PBA) then
	SPBA <= '0';
end if;
if (PBA = '0') and (wrkcnt = x"64") then
	SPBA <= '1';
end if;

if falling_edge(PBB) then
	SPBB <= '0';
end if;
if (PBB = '0') and (wrkcnt = x"64") then
	SPBB <= '1';
end if;
if falling_edge(PBC) then
	SPBC <= '0';
end if;
if (PBC = '0') and (wrkcnt = x"64") then
	SPBC <= '1';
end if;
if falling_edge(PBD) then
	SPBD <= '0';
end if;
if (PBD = '0') and (wrkcnt = x"64") then
	SPBD <= '1';
end if;
end process btnpush;


--generate 10khz clock using 50Mhz input
clk10khz : process (clk50)
begin
if rising_edge(clk50) then
	if clkcount = X"1f4" then
		clkcount <= (others => '0');
		clk10k <= not clk10k;
	else
		clkcount <= clkcount + 1;
	end if;
end if;

end process clk10khz;
--10khz clock output as clk10k

--use 10khz clock to drive computations
process(all)
begin

if (rising_edge(clk10k)) then
--	first time through initialization routine
	if init = '0' and state /= initialize then
		state				<= initialize;
		next_state		<= curstate;
		nowstate			<=	initialize;
		prev_state		<= curstate;
	end if;
--	reset function forces hard reset of game. pretty much have it working now
	if ((aggdata = "1100110011001100") and (pbc = '0') and (pbd = '0')) then
		resetcnt <= resetcnt + 1;
		if (resetcnt = X"493E0") and (reset_e=0) then
			reset_e <= 1;
			OO1 <= '0';--debugline
		elsif (reset_e = 1) then
			state <= RIP;
			OO  <= '1';--debugline
			OO1 <= '0';--debugline
			resetcnt <= (others => '0');
			reset_e <= 0;
		end if;
	else
		resetcnt <= (others => '0');
		reset_e <= 0;
		OO1 <= '0';--debugline
	end if;

--	progresses wrkcnt each clock cycle no matter the state.
	wrkcnt <= wrkcnt +1;
	
	case state is

--	reset state which forces hard reset
	when RIP =>
		OO1					<= '1';--debugline
		localstate			<= 0;
		print_localstate	<= 0;
		state_localstate	<= 0;
		OO						<= '0';--debugline
		wrkcnt				<= (others => '0');
		aggOP					<= (others => '0');--debugline
		OP1					<= aggOP (15 downto 8);--debugline
		OP2					<= aggOP (7 downto 0);--debugline
		init					<= '0';
		
--	ensures data holds long enough after e falls
	when hold =>
		case next_state is
		when curstate =>
			OO					<= '0';--debugline
			wrkcnt			<= (others => '0');
			state				<= (nowstate);
		when others =>
			OO					<= '0';--debugline
			wrkcnt			<= (others => '0');
			state				<= next_state;
			next_state		<= curstate;
			localstate		<= 0;
		end case;
	
		
--	drops E -this state is the state in which 
	when e_drop =>
		E		<= '0';
		state <= hold;
	
--	initialization routine
	when initialize =>
		nowstate				<= initialize;
		RS						<='0';
		
		if (localstate = 0 and wrkcnt = X"50") then
			next_state			<= curstate;
			DB						<= "00110000"; --function set (interface 8-bits)
			OP1					<= "00110000"; --debugline
			localstate			<= localstate+1;
			E						<='1';
			OO						<= '0';--debugline
			state					<= e_drop;
			
		elsif (localstate = 1 and wrkcnt = X"50") then
			DB						<= "00110000"; --function set (interface 8-bits)
			OP1					<= "00110000";--debugline
			localstate			<= localstate+1;
			E						<='1';
			OO						<= '1';--debugline
			state					<= e_drop;
			
		elsif (localstate = 2 and wrkcnt = X"50") then
			DB						<= "00110000"; --function set (interface 8-bits)
			OP1					<= "00110000";--debugline
			localstate			<= localstate+1;
			E						<='1';
			OO						<= '1';--debugline
			state					<= e_drop;
			
		elsif (localstate = 3 and wrkcnt = X"50") then
			DB						<= "00111100"; --function set (set number of display lines=2 and character font=5x11)
			OP1					<= "00111100";--debugline
			localstate			<= localstate+1;
			E						<='1';
			OO						<= '0';--debugline
			state					<= e_drop;
			
		elsif (localstate = 4 and wrkcnt = X"50") then
			DB						<= "00001000"; --display off
			OP1					<= "00001000";--debugline
			localstate			<= localstate+1;
			E						<='1';
			OO						<= '0';--debugline
			state					<= e_drop;
			
		elsif (localstate = 5 and wrkcnt = X"640") then
			DB						<= "00000001"; -- display clear
			OP1					<= "00000001";--debugline
			localstate			<= localstate+1;
			E						<='1';
			OO						<= '0';--debugline
			state					<= e_drop;
			
		elsif (localstate = 6 and wrkcnt = X"50") then
			DB						<= "00000110"; --entry mode set (cursor moving direction=1 shift entire display=no )
			OP1					<= "00000110";--debugline
			localstate			<= localstate+1;
			E						<='1';
			OO						<= '0';--debugline
			state					<= e_drop;
			
		elsif (localstate = 7 and wrkcnt = X"50") then
			DB						<= "00001100"; -- display control (display on, cursor off, blinking cursor off)
			OP1					<= "00001100";--debugline
			localstate			<= 0;
			next_state			<= homescreens;
			E						<='1';
			OO						<= '1';--debugline
			init					<= '1';
			state					<= e_drop;
		end if;
--		end of initialization routine

--	routine to print to display.
	when print_disp =>
		nowstate <= print_disp;
		case print_localstate is

		when 0 =>
--			clear display: upon entering print state sets cursor to first address and clears all data from the screen.
			if wrkcnt = x"640" then
				DB <= X"01";
				E <= '1';
				RS <= '0';
				oo <= '1';--debugline
				print_localstate <= 3;
				state <= e_drop;
			end if;
			
		when 1 =>
--			line2: moves cursor to beginning of second line to continue printing.
			if wrkcnt = x"64" then
				db <= X"C0";
				rs <= '0';
				e	<= '1';
				oo	<= '1';--debugline
				state <= e_drop;
				print_localstate <= 3;
			end if;
			
		when 2 =>
--			return home: returns cursor to home position, yet leaves current data on screen. also exits the homescreen state and returns to the previous state
			if wrkcnt = x"1388" then
				db <= X"80";
				OP1 <= X"FF";
				rs <= '0';
				e	<= '1';
				oo	<= '1';--debugline
				print_localstate <=0;
				state <= e_drop;
				next_state <= prev_state;
			end if;
			
		when 3 =>
--			outputs character information to the lcd
			if wrkcnt = x"64" then
				DB <= next_char;
				OP1 <= "000" & std_logic_vector(char_count);
				RS<='1';
				E <='1';
				OO <='1';--debugline
				print_localstate <=3;
				state <= e_drop;

--				increases character count each loop
				if (char_count <31) and (next_char /= X"FE") then
					char_count <= char_count+1;
				end if;
		
--				when character count reaches 15(aka end of the first line) calls the line2 substate
--				when the character count reaches 31 (aka end of the second line) calls the return home state
				if char_count = 15 then 
					print_localstate <= 1;
				elsif (char_count = 31) or (next_char = X"FE") then
					print_localstate <= 2;
					char_count <= (others => '0');
				end if;
			end if;
		when others =>
		end case;
--	end print to display routine.

-----------------
---homescreens---
-----------------
--	calls and displays the homescreen data	
	when homescreens =>
		nowstate <= homescreens;
		prev_state <=	homescreens;
		case state_localstate is

		when 0 =>
--			print first page of homescreens
			memstate <= X"0001"; --"Lunar Lander!   To begin push B0"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;

		when 1 =>
--			holds after first page is printed until the button listed is pushed then progresses to the next state (which is the second homescreen)
			OP1 <= "00001111";--debugline
			OO <= '1';--debugline
			if SPBD = '0' then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;

		when 2 =>
--			print second page of homescreens
			memstate <= X"0002";--"For info push B3 to start push B0"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;

		when 3 =>
--			holds after second page is printed until the button listed is pushed then progresses to the next state (which is the beginning of info screens)
			OP1 <= "11110000";--debugline
			OO <= '1';--debugline
			if SPBA = '0' or wrkcnt = x"7A120" then
				state_localstate <= 0;
				next_state <= infoscreens;
				state <= e_drop;
			elsif SPBD = '0' then
				state_localstate <= 0;
				next_state <= startscreens;
				state <= e_drop;
			end if;

		when others =>
		end case;
		
	when infoscreens =>
		nowstate <= infoscreens;
		prev_state <=	infoscreens;
		case state_localstate is
		when 0 =>
--			print first page of infoscreens
			memstate <= X"0003";--"to advance info press KEY0"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 1 =>
--			holds after first page is printed until the button listed is pushed then progresses to the next state (which is the second infoscreen)
			OP1 <= "00001111";--debugline
			OO <= '1';--debugline
			if SPBD = '0' then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;
		when 2 =>
--			print second page of infoscreens
			memstate <= X"0004";--"KEY3 - Select KEY0 - Enter"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 3 =>
--			holds after second page is printed until the button listed is pushed then progresses to the next state (which is the third infoscreen)
			OP1 <= "11110000";--debugline
			OO <= '1';--debugline
			if SPBD = '0' or wrkcnt = X"7A120" then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;
		when 4 =>
--			print second page of infoscreens
			memstate <= X"0005";--"the purpose of this game is to"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 5 =>
--			holds after third page is printed until the button listed is pushed then progresses to the next state (which is the fourth infoscreen)
			OP1 <= "11110000";--debugline
			OO <= '1';--debugline
			if SPBD = '0' or wrkcnt = X"7A120" then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;
		when 6 =>
--			print second page of infoscreens
			memstate <= X"0006";--"land on the moon with a lander"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 7 =>
--			holds after fourth page is printed until the button listed is pushed then progresses to the next state (which is the fifth infoscreen)
			OP1 <= "11110000";--debugline
			OO <= '1';--debugline
			if SPBD = '0' or wrkcnt = X"7A120" then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;
		when 8 =>
--			print second page of infoscreens
			memstate <= X"0007";--"SW17-14 control time engine fire"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 9 =>
--			holds after fifth page is printed until the button listed is pushed then progresses to the next state (which is the sixth infoscreen)
			OP1 <= "11110000";--debugline
			OO <= '1';--debugline
			if SPBD = '0' or wrkcnt = X"7A120" then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;
		when 10 =>
--			print second page of infoscreens
			memstate <= X"0008";--"SW11-5 control percent thrust"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 11 =>
--			holds after sixth page is printed until the button listed is pushed then progresses to the next state (which is the seventh infoscreen)
			OP1 <= "11110000";--debugline
			OO <= '1';--debugline
			if SPBD = '0' or wrkcnt = X"7A120" then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;
		when 12 =>
--			print second page of infoscreens
			memstate <= X"0009";--"you must land slow to survive"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 13 =>
--			holds after seventh page is printed until the button listed is pushed then progresses to the next state (which is the eighth infoscreen)
			OP1 <= "11110000";--debugline
			OO <= '1';--debugline
			if SPBD = '0' or wrkcnt = X"7A120" then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;
		when 14 =>
--			print second page of infoscreens
			memstate <= X"000A";--"Good luck! hit ENT to begin"
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 15 =>
--			holds after eighth page is printed until the button listed is pushed then progresses to the next state (which is the ninth infoscreen)
			OP1 <= "11110000";--debugline
			OO <= '1';--debugline
			if SPBD = '0' then
				state_localstate <= state_localstate+1;
				next_state <= startscreens;
				state <= e_drop;
			end if;
		when others =>
		end case;

	when startscreens =>
		nowstate <= startscreens;
		prev_state <=	startscreens;
		case state_localstate is
		when 0 =>
--			print first page of startscreens
			memstate <= X"000B";--"you start 5km   above the surf. "
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 1 =>
--			holds after first page is printed until the button listed is pushed then progresses to the next state (which is the second startcreen)
			OP1 <= "00001111";--debugline
			OO <= '1';--debugline
			if SPBD = '0' then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;
		when 2 =>
--			print first page of startscreens
			memstate <= X"000C";--"you start 5km   above the surf. "
			OP1 <= "10101010";--debugline
			OO <= '1';--debugline
			state_localstate <= state_localstate+1;
			next_state <= print_disp;
			state <= e_drop;
		when 3 =>
--			holds after second page is printed until the button listed is pushed then progresses to the next state (which is the third startcreen)
			OP1 <= "00001111";--debugline
			OO <= '1';--debugline
			if SPBD = '0' then
				state_localstate <= state_localstate+1;
				next_state <= print_disp;
				state <= e_drop;
			end if;
		
		
		when others =>
		end case;
	
--------------------------------
--------------------------------
--		try to figure out how to keep local state for each specific state
--		when that state could be gone back to at a seperate point
--
--		either local states kept in memory for each state?
--		resetting on the way out of each state that needs it to be reset.
--------------------------------
--------------------------------

--	allows all choices to be covered in case one is missed.
	when others =>
	end case;

end if;
end process;
end behavior;