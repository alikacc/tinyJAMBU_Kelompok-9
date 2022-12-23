library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity process_ad is
port(
    ad : in std_logic_vector (63 downto 0); 
    clk : in STD_LOGIC;
    reset : in STD_LOGIC;
    proceed : in STD_LOGIC;
    s: inout std_logic_vector(127 downto 0)
    );
end process_ad;

architecture behavioral of process_ad is
    type state is (init, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10);
    signal nState, cState : state;
    signal lenp_div_8 : std_logic_vector(1 downto 0);
    signal framebits: std_logic_vector(2 downto 0) := "011";
	signal key : sTD_LOGIC_VECTOR(127 downto 0); 
	signal index: integer;
	signal feedback: std_logic;   
	signal i: integer;
	
begin
    state_update: entity work.state_update(behavior) 
    port map (
        clk  => clk ,
        reset => reset,
        proceed => proceed,
        key => key,
        index => index,
        s => s,
        feedback => feedback
    );
	
	process(reset,clk)
    begin
        if( reset = '1' ) then 
            cState <= init; 
        elsif( clk'event and clk = '1' ) then 
            cState <= nState; 
        end if; 
        end process; 
        
        process(proceed, cState)
        variable lenp, startp, adlen: integer;
        begin
        case cState is
    
        when init => 
        if (proceed = '0') then
            nState <= init;
        else
            nState <= s0;
        end if;
    
        when s0 =>
            if adlen mod 32 > 0 then 
                nState <= s4;
            else
                nState <= s1;
            end if;
        
        when s1 => 
			for i in 0 to adlen/32 loop
                    s(38 downto 36) <= s(38 downto 36) xor framebits(2 downto 0);
					nState <= s2;
            end loop ;
			nState <= s0;
            
        when s2 => 
            s <= s;
            key <= key;
            index <= 384;
            nState <= s2;
        
        when s3 => 
            s(127 downto 96) <= s(127 downto 96) xor ad(32*i+31 downto 32*i);
            i <= i + 1;
            nState <= s0;
        
        when s4 => 
            s(38 downto 36) <= s(38 downto 36) xor framebits(2 downto 0);
            nState <= s5;
        
        when s5 =>
            s <= s;
            key <= key;
            index <= 384;
            nState <= s6;
        
        when s6 =>
            lenp := adlen mod 32;
            nState <= s7;
        
        when s7 => 
            startp := adlen - lenp;
            nState <= s8;
        
        when s8 => 
            s((96+lenp-1) downto 96) <= s((96+lenp-1) downto 96) xor ad((adlen-1) downto startp);
            nState <= s9;
        
        when s9 =>
			lenp_div_8 <= std_logic_vector(to_unsigned(lenp, 2));
            s(33 downto 32) <= s(33 downto 32) xor (lenp_div_8); 
            nState <= s10;

        when s10 =>
        end case;
        end process;
end behavioral;
