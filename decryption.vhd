library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity decryption is
    port(
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        proceed : in STD_LOGIC;
        s : inout STD_LOGIC_VECTOR (127 downto 0); 
        mlen, startp, lenp : in INTEGER;  
        m : inout STD_LOGIC_VECTOR (127 downto 0); 
        c : in STD_LOGIC_VECTOR (127 downto 0)
    );
end decryption;

architecture behavioral of decryption is
    type state is (init, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12);
    signal nState, cState : state;
    signal index : integer;
    signal key : std_logic_vector(127 downto 0);
    signal framebits: std_logic_vector(2 downto 0) := "101";
    signal lenp_div_8 : std_logic_vector(1 downto 0);
    signal feedback: std_logic;  
    signal i: integer;

begin
    state_update: entity work.state_update(behavior) 
    port map (
        clk  => clk,
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
        variable lenp, startp, mlen: integer;
        begin
        case cState is
    
        when init => 
        if (proceed = '0') then
            nState <= init;
        else
            nState <= s0;
        end if;
    
       when s0 =>
            if mlen mod 32 > 0 then 
                nState <= s5;
            else
                nState <= s1;
            end if;
        
        when s1 =>
			for i in 0 to mlen/32 loop
                s(38 downto 36) <= s(38 downto 36) xor framebits(2 downto 0);
				nState <= s2;
            end loop;
            nState <= s0;
        
        when s2 =>
            s <= s;
            key <= key;
            index <= 1024;
            nState <= s3;
        
        when s3 =>
            m((32*i + 31) downto 32*i) <= s(95 downto 64) xor c((32*i + 31) downto 32*i);
            nState <= s4;
        
        when s4 =>
            s(127 downto 96) <= s(127 downto 96) xor m((32*i + 31) downto 32*i);
            i <= i+1;
            nState <= s1;

        when s5 =>
            s(38 downto 36) <= s(38 downto 36) xor framebits(2 downto 0);
            nState <= s6;
        
        when s6 =>
            s <= s;
            key <= key;
            index <= 1024;
            nState <= s7;
        
        when s7 =>
            lenp := mlen mod 32; 
            nState <= s8;
        
        when s8 =>
            startp := mlen - lenp; 
            nState <= s9;
        
        when s9 =>
            m(startp downto mlen-1) <= s((64 + lenp - 1) downto 64) xor c((mlen - 1) downto startp);
            nState <= s10;
        
        when s10 =>
            s((96+lenp-1) downto 96) <= s((96+lenp-1) downto 96) xor m((mlen-1) downto startp);
            nState <= s11;
            
        when s11 =>
        lenp_div_8 <= std_logic_vector(to_unsigned(lenp, 2));
            s(33 downto 32) <= s(33 downto 32) xor (lenp_div_8);
            nState <= s12;
            
        when s12 =>
        end case;
        end process;
end behavioral;
