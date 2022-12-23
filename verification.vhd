LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

entity verification is 
    port(
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        proceed : in STD_LOGIC;
        s : inout STD_LOGIC_VECTOR (127 downto 0); 
        t : out STD_LOGIC_VECTOR (63 downto 0); 
        t_aks : inout STD_LOGIC_VECTOR (63 downto 0)
    );
end verification;

architecture behavioral of verification is
    type state is (init, s0, s1, s2, s3, s4, s5, s6);
    signal nState, cState : state;
    signal index : integer;
    signal framebits: std_logic_vector(2 downto 0) := "111";
    signal key : STD_LOGIC_VECTOR(127 downto 0);
    signal feedback: std_logic; 


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
    
    process( reset, clk ) 
        begin 
        if( reset = '1' ) then 
            cState <= init; 
        elsif( clk'event and clk = '1' ) then 
            cState <= nState; 
        end if; 
        end process; 
        
        process(proceed, cState)
        variable mlen, lenp, startp: integer; 
        
        begin
        case cState is
        when init => 
        if (proceed = '0') then
            nState <= init;
        else
            nState <= s0;
        end if;
    
        when s0 =>
            s(38 downto 36) <= s(38 downto 36) XOR frameBits(2 downto 0);
            nState <= s1;
        
        when s1 =>
            s <= s;
            key <= key;
            index <= 1024;
            nState <= s2;
        
        when s2 =>
            t_aks(31 downto 0) <= s(95 downto 64);
            nState <= s3;
            
        when s3 =>
            s(38 downto 36) <= s(38 downto 36) xor framebits(2 downto 0);
            nState <= s4;
            
        when s4 =>
            s <= s;
            key <= key;
            index <= 384;
            nState <= s5;
            
        when s5 =>
            t_aks(63 downto 32) <= s(95 downto 64);
            nState <= s6;
            
        when s6 => 
            t_aks <= t_aks(63 downto 32);
            
        end case;
        end process;
end behavioral;
