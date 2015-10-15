function [res category]=check_dc(s_data,s_data_len,dc_huff_table,dc_mat)
%CHECK_DC retrns the res(binary 1 or 0) and the category value for the
%input string.This function takes a string of binary numbers as input.It then searches
%for that input string in the huffman table for the dc coefficients.If such
%string is not present as codeword in the table, res becomes 0 otherwise 1.
%This function is optimized in the sense that we search the codeword only in
%those table entries that have codewords of same length.For this purpose,start_loop 
%and end_loop values are used(just like check_ac.m).  

start_loop=dc_mat(s_data_len-1,1);
loop_counter=dc_mat(s_data_len-1,2);
end_loop=start_loop+loop_counter-1;

category=0;
res=0;
for i=start_loop:end_loop
    
    if dc_huff_table(i).code == s_data
        res=1;
        category=dc_huff_table(i).category;
        break;
    end
    
end

end

