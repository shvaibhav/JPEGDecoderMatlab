function [quant_table]=define_quantization_table(fid)
%DEFINE_QUANTIZATION_TABLE returns a 8x8 quantization table.
%The values for the quantization table are read from the image file and are
%stored in the 8x8 matrix in zig zag form. The function presents an 
%optimized method for this zig zag ordering of entries in the quantization table.

quant_table=zeros(8,8);

length=bin2dec(strcat(dec2bin(fread(fid,1)),dec2bin(fread(fid,1))));
len_counter=2;

pq_tq=dec2bin(fread(fid,1),8);len_counter=len_counter+1;
pq=bin2dec(pq_tq(1:4));
tq=bin2dec(pq_tq(5:8));

if(tq>3)
    disp('error as quantization table identifier should be from 0 to 3')
    disp(' and precision value is 0 for 8 bit Quantization table')
end

fseek(fid,63,'cof');
n=8;
flag=0;
counter=0;
i=1;

while i < (2*n-1)
    if mod(i,2) ~= 0
        s = n-i;
        h = n-1;
    else
        h = n-i;
        s = n-1;
    end
               
    if flag==1
        s=s-counter; h=h-counter;
    end	
               
    for j = 1:i
        quant_table(s+1,h+1)=fread(fid,1);
        len_counter=len_counter+1;
		fseek(fid,-2,'cof');
        
        if mod(i,2) ~= 0
            s=s+1; h=h-1;
        else
            s=s-1;
            h=h+1;
        end
       
    end
    
    if i==n
        flag=1;
    end
    
    if flag==1
        i=i-1;
        counter=counter+1;
        if counter==n
            break;
        end
    else
        i=i+1;
    end
           
end
fseek(fid,65,'cof'); 

while len_counter~=length
    fread(fid,1);
end

end

