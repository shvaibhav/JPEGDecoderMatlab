function define_application_marker(fid)
%DEFINE_APPLICATION_MARKER reads the information specific to
%applications.This marker decides whether the image corresponds to the
%specifications laid down by JPEG and whether it can be decoded using the
%given decoder.

length=bin2dec(strcat(dec2bin(fread(fid,1)),dec2bin(fread(fid,1))));
len_counter=2;

JFIF_spec=fread(fid,5);
len_counter=len_counter+5;

version=fread(fid,2);
len_counter=len_counter+2;

units=fread(fid,1);
len_counter=len_counter+1;

xdensity=fread(fid,2);
len_counter=len_counter+2;

ydensity=fread(fid,2);
len_counter=len_counter+2;

xthumbnail=fread(fid,1);
len_counter=len_counter+1;

ythumbnail=fread(fid,1);
len_counter=len_counter+1;

while (len_counter~=length)
    fread(fid,1);
    len_counter=len_counter+1;
end

end
