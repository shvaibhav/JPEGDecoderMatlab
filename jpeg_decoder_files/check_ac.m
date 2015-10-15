function [res r_val cat_val] = check_ac(s_data,s_data_len,ac_huff_table,ac_mat)
%CHECK_AC retrns the variable res(binary 1 or 0),run_value and the category value
%This function takes a string of binary numbers as input.It then searches
%for that input string in the huffman table for the ac coefficients.If such
%string is not present as codeword in the table, res becomes 0 otherwise 1.
%This function is optimized in the sense that we search the codeword only in
%those table entries that have codewords of same length.For this purpose,start_loop 
%and end_loop values are used.  

start_loop=ac_mat(s_data_len-1,1);
loop_counter=ac_mat(s_data_len-1,2);
end_loop=start_loop+loop_counter-1;

res=0;
r_val=0;
cat_val=0;
for i=start_loop:end_loop
    
    if ac_huff_table(i).code == s_data
        res=1;
        rc_val=dec2bin(ac_huff_table(i).run_size,8);
        r_val=bin2dec(rc_val(1:4));
        cat_val=bin2dec(rc_val(5:8));
        return;
    end
    
end
        
end

