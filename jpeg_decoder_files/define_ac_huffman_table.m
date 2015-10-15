function [ac ac_mat]=define_ac_huffman_table(fid,length)
%DEFINE_AC_HUFFMAN_TABLE returns a huffman table for ac coefficients.
%The table has three fields - 1)run_size 2)length of the code 3)code word
%First, we enter the length field values in the table,then, we enter the
%run_size value in the order of increasing length and lastly we create the 
%code word for each of the previous entry.The first two fields are generated
%by reading data from the image file while the code word for the corresponding
%entries in the first two fields is actually calculated.

len_counter=3;

j=1;temp_var1=0;
for x=1:16
   value=fread(fid,1);len_counter=len_counter+1;
   temp_var1=temp_var1+value;
   ac_mat(x,1)=temp_var1+1;
   if x~=16
       ac_mat(x,2)=fread(fid,1);fseek(fid,-1,'cof');
   else
       ac_mat(x,2)=0;
   end
   for i=1:value
      ac(j).length=x;j=j+1;
   end
end


for i=1:162
   ac(i).run_size=fread(fid,1);len_counter=len_counter+1;
end

ac(1).code='00';
for i=2:162
    if ac(i).length~=15
        if (ac(i).length) > (ac(i-1).length)
            prec=ac(i-1).length;
            prec=prec+1;
            temp1=bin2dec(ac(i-1).code);
            temp1=temp1+1;
            temp1=temp1*2;
            temp2=dec2bin(temp1,prec);
        else
            prec=ac(i-1).length;
            temp1=bin2dec(ac(i-1).code);
            temp1=temp1+1;
            temp2=dec2bin(temp1,prec);
        end
    else
        temp2='111111111000000';
    end    
    ac(i).code=temp2;
end

if len_counter~=length
    fread(fid,1);
    len_counter=len_counter+1;
end    

end

