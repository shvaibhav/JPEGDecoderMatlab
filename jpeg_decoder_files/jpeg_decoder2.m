%This is the main file for the jpeg_decoder implementation for 'zero.jpg'
%declaration of markers
SOF0=[255; 192];
DHT=[255;196];
RST1=[255;208];
RST2=[255;209];
RST3=[255;210];
RST4=[255;211];
RST5=[255;212];
RST6=[255;213];
RST7=[255;214];
RST8=[255;215];
SOI=[255;216];
EOI=[255;217];
SOS=[255;218];
DQT=[255;219];
DNL=[255;220];
DRI=[255;221];
APP1=[255;224];
APP2=[255;225];
APP3=[255;226];
APP4=[255;227];
APP5=[255;228];
APP6=[255;229];
APP7=[255;230];
APP8=[255;231];
APP9=[255;232];
APP10=[255;233];
APP11=[255;234];
APP12=[255;235];
APP13=[255;236];
APP14=[255;237];
APP15=[255;238];
APP16=[255;239];
TC_TH_DC1=[0];
TC_TH_DC2=[1];

TC_TH_AC1=[16];
TC_TH_AC2=[17];

fid=fopen('lena64.jpg','r');
%fid=fopen('second16x16.jpg','r');
%fid=fopen('second32x32.jpg','r');
soi=fread(fid,2);
if soi(1,1)~=SOI(1,1) || soi(2,1)~=SOI(2,1)       %checking for valid start of image marker 
    disp('Incorrect SOI marker: ')
    disp(soi)
    exit;
end
restart_interval=0;                               %reset restart interval
temp=fread(fid,2);

dc_huff_table=0;
dc_mat=0;

ac_huff_table=0;
ac_mat=0;

while temp(1,1)~=SOF0(1,1) || temp(2,1)~=SOF0(2,1)               %check whether the sof marker has been detected or it is the interpret marker.
    if temp(1,1)==APP1(1,1) && temp(2,1)==APP1(2,1)
        define_application_marker(fid);                          %application marker
        temp=fread(fid,2);
    elseif temp(1,1)==DQT(1,1) && temp(2,1)==DQT(2,1) 
        quant_table=define_quantization_table(fid);              %create quantization table
        temp=fread(fid,2);
    elseif temp(1,1)==DHT(1,1) && temp(2,1)==DHT(2,1)
        length=bin2dec(strcat(dec2bin(fread(fid,1)),dec2bin(fread(fid,1))));
        tc_th=fread(fid,1);
        if (tc_th==TC_TH_DC1) || (tc_th==TC_TH_DC2)
            [dc_huff_table dc_mat]=define_dc_huffman_table(fid);        %create huffman table for dc coeeficients
        elseif (tc_th==TC_TH_AC1) || (tc_th==TC_TH_AC2)
            [ac_huff_table ac_mat]=define_ac_huffman_table(fid);        %create huffman table for ac coeeficients
        end
        temp=fread(fid,2);
    elseif temp(1,1)==DRI(1,1) && temp(2,1)==DRI(2,1)
        rst_int=define_restart_interval(fid);                           %restart interval marker
        temp=fread(fid,2);
    end
end

%now temp is equal to [FF;C0] OR [255;192].Thus SOF has been detected.
%evaluate frame header

frame_length_count=2;
length_frame=bin2dec(strcat(dec2bin(fread(fid,1)),dec2bin(fread(fid,1))));
prec_frame=fread(fid,1);frame_length_count=frame_length_count+1;
y_frame=fread(fid,2);frame_length_count=frame_length_count+2;
x_frame=fread(fid,2);frame_length_count=frame_length_count+2;
components_frame=fread(fid,1);frame_length_count=frame_length_count+1;

for i=1:components_frame
    component_id(1,i)=fread(fid,1);frame_length_count=frame_length_count+1;
    h_v_sampling(1,i)=fread(fid,1);frame_length_count=frame_length_count+1;
    quant_dest_select(1,i)=fread(fid,1);frame_length_count=frame_length_count+1;
end

if frame_length_count < length_frame
    fread(fid,1);
    frame_length_count=frame_length_count+1;
end

%frame header has been interpreted.Move ahead to evaluate start of scan

dc_huff_table=0;
dc_mat=0;

ac_huff_table=0;
ac_mat=0;

temp=fread(fid,2);
while temp(1,1)~=SOS(1,1) || temp(2,1)~=SOS(2,1)                %check whether the sof marker has been detected or it is the interpret marker.
    if temp(1,1)==APP1(1,1) && temp(2,1)==APP1(2,1)
        define_application_marker(fid);                         %application marker
        temp=fread(fid,2);
    elseif temp(1,1)==DQT(1,1) && temp(2,1)==DQT(2,1)
        quant_table=define_quantization_table(fid);             %create quantization table
        temp=fread(fid,2);
    elseif temp(1,1)==DHT(1,1) && temp(2,1)==DHT(2,1)
        length=bin2dec(strcat(dec2bin(fread(fid,1)),dec2bin(fread(fid,1))));
        tc_th=fread(fid,1);
        if (tc_th==TC_TH_DC1) || (tc_th==TC_TH_DC2)
            [dc_huff_table dc_mat]=define_dc_huffman_table(fid,length); %create huffman table for dc coeeficients
        elseif (tc_th==TC_TH_AC1) || (tc_th==TC_TH_AC2)
            [ac_huff_table ac_mat]=define_ac_huffman_table(fid,length); %create huffman table for ac coeeficients
        end
        temp=fread(fid,2);
    elseif temp(1,1)==DRI(1,1) && temp(2,1)==DRI(2,1)                   %restart interval marker
        define_restart_interval(fid);
        temp=fread(fid,2);
    end
end
%now temp is equal to [FF;DA] OR [255;218]
%we begin interpreting the scan header

scan_length_counter=2;
scan_header_length=bin2dec(strcat(dec2bin(fread(fid,1)),dec2bin(fread(fid,1))));
image_components=fread(fid,1);

for i=1:image_components
    scan_component_select(1,i)=fread(fid,1);
    dc_ac_dest_select(1,i)=fread(fid,1);
end

start_spectral=fread(fid,1);
end_spectral=fread(fid,1);
ah_al=fread(fid,1);

%scan header interpretation complete
%start decoding restart interval

%we start decoding each component. We decode till EOI is detected.
s='';s_len=0;num_eof=1;
temp=fread(fid,1);temp1=fread(fid,1);fseek(fid,-1,'cof');
while temp~=EOI(1,1) || temp1~=EOI(2,1)
    if temp==255 && temp1==0
        fread(fid,1);
    end
    temp_bin=dec2bin(temp,8);
    s=strcat(s,temp_bin);s_len=s_len+8;
    temp=fread(fid,1);temp1=fread(fid,1);fseek(fid,-1,'cof');
end
JJ=2;KK=1;
%for xx=1:image_components
no_eof=1;

%check_temp=[];check_temp_var=1;
data_matrix_final1=[];
for xx=1:(x_frame(2,1)/8)
data_matrix_final=[];
for xx1=1:(y_frame(2,1)/8)

%decoding the dc coefficient
j=JJ;
k=KK;
flag=0;

str_test='';
for i=1:s_len-k+1
    str_test(i)='1';
end

if ~strcmp(s(k:s_len),str_test) %&& ~(j==s_len)         is there any need to compare j with s_len
    
    data_matrix1=[];
    tab_data=[];
    while flag==0
        s_data=s(k:j);s_data_len=j-k+1;
        [res category]=check_dc(s_data,s_data_len,dc_huff_table,dc_mat);
        if res==[1]
            flag=1;
            if ~strcmp(s_data,'00')
                data_extract=s(j+1:j+category);
                if data_extract(1)=='1'
                    data_extract_dec=bin2dec(data_extract);
                else
                    data_extract_dec=bin2dec(data_extract);
                    data_extract_dec=bitcmp(data_extract_dec,category);
                    data_extract_dec=-data_extract_dec;
                end    
                k=j+category+1;
                j=k+1;
            else
                data_extract_dec=0;
                k=j+1;j=k+1;
            end
        else
            j=j+1;
        end
    end

    data_elem=1;
    tab_data(data_elem)=data_extract_dec;
    data_elem=data_elem+1;
     
%decoding the ac coefficients until EOB is detected

    for i=k:s_len
        s_data=s(k:j);s_data_len=j-k+1;
        [res r_val cat_val]=check_ac(s_data,s_data_len,ac_huff_table,ac_mat);
        if res==1
            if strcmp(s_data,'1010')
                k=j+1;j=k+1;num_eof=num_eof+1;
                break;
            end
            if ~strcmp(s_data,'11111111001')
                data_extract=s(j+1:j+cat_val);
                if data_extract(1)=='1'
                    data_extract_dec=bin2dec(data_extract);
                else
                    data_extract_dec=bin2dec(data_extract);
                    data_extract_dec=bitcmp(data_extract_dec,cat_val);
                    data_extract_dec=-data_extract_dec;
                end
            else
                data_extract_dec=0;
            end
            for z=1:r_val
                tab_data(data_elem)=0;
                data_elem=data_elem+1;
            end
            tab_data(data_elem)=data_extract_dec;
            data_elem=data_elem+1;
            k=j+cat_val+1;
            j=k+1;
            if data_elem==65
                break;
            end
        else
            j=j+1;
        end
    end
    KK=k;JJ=j;
%all ac coefficients after EOB are assigned value = 0

    for i=data_elem:64
        tab_data(i)=0;
    end

    u=1;
    for w=1:8
        for v=1:8
            data_matrix1(w,v)=tab_data(u);
            u=u+1;
        end
    end
    
data_matrix12=undo_the_zigzag(data_matrix1);    

end

data_matrix_final=[data_matrix_final data_matrix12];
%data_matrix_final=horzcat(data_matrix_final,data_matrix1);

end

data_matrix_final1=vertcat(data_matrix_final1,data_matrix_final);

end

fhandle2=@(x) x.*quant_table;
new_image2=blkproc(data_matrix_final1,[8 8],fhandle2);

PRED=0;
for i=1:x_frame(2,1)
    for j=1:y_frame(2,1)
    	if (i==1 && j==1) || (i==1 && j==9) || (i==1 && j==17) || (i==1 && j==25) || (i==1 && j==33) || (i==1 && j==41) || (i==1 && j==49) || (i==1 && j==57) || (i==9 && j==1) || (i==9 && j==9) || (i==9 && j==17) || (i==9 && j==25) || (i==9 && j==33) || (i==9 && j==41) || (i==9 && j==49) || (i==9 && j==57) || (i==17 && j==1) || (i==17 && j==9) || (i==17 && j==17) || (i==17 && j==25) || (i==17 && j==33) || (i==17 && j==41) || (i==17 && j==49) || (i==17 && j==57) || (i==25 && j==1) || (i==25 && j==9) || (i==25 && j==17) || (i==25 && j==25) || (i==25 && j==33) || (i==25 && j==41) || (i==25 && j==49) || (i==25 && j==57) || (i==33 && j==1) || (i==33 && j==9) || (i==33 && j==17) || (i==33 && j==25) || (i==33 && j==33) || (i==33 && j==41) || (i==33 && j==49) || (i==33 && j==57) || (i==41 && j==1) || (i==41 && j==9) || (i==41 && j==17) || (i==41 && j==25) || (i==41 && j==33) || (i==41 && j==41) || (i==41 && j==49) || (i==41 && j==57) || (i==49 && j==1) || (i==49 && j==9) || (i==49 && j==17) || (i==49 && j==25) || (i==49 && j==33) || (i==49 && j==41) || (i==49 && j==49) || (i==49 && j==57) || (i==57 && j==1) || (i==57 && j==9) || (i==57 && j==17) || (i==57 && j==25) || (i==57 && j==33) || (i==57 && j==41) || (i==57 && j==49) || (i==57 && j==57)
            new_image2(i,j)=new_image2(i,j)+PRED;
            PRED=new_image2(i,j);
    	end
    end
end

fhandle3=@idct2;
new_image3=round(blkproc(new_image2,[8 8],fhandle3));

new_image3=new_image3 + 128;

imshow(new_image3,[0 255])
status=fclose(fid);                                 %close the file


