function [ data_matrix12] = undo_the_zigzag( data_matrix1 )
%UNDO_THE_ZIGZAG Summary of this function goes here
%   Detailed explanation goes here

u=1;
for w=1:8
    for v=1:8
        data_oned(u)=data_matrix1(w,v);
        u=u+1;
    end
end

n=8;
flag=0;
counter=0;
i=1;
data_elem=64;

while i < (2*n-1)
    if mod(i,2) ~= 0
        ss = n-i;
        h = n-1;
    else
        h = n-i;
        ss = n-1;
    end
               
    if flag==1
        ss=ss-counter; h=h-counter;
    end	
               
    for j = 1:i
%        Y(data_elem)=X(h+1,ss+1);
        Y(h+1,ss+1)=data_oned(data_elem);
%        strcat(int2str(ss+1),int2str(h+1))
        data_elem=data_elem-1;
        if mod(i,2) ~= 0
            ss=ss+1; h=h-1;
        else
            ss=ss-1;
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

u=1;
for w=1:8
    for v=1:8
        data_matrix12(w,v)=Y(u);
        u=u+1;
    end
end

end

