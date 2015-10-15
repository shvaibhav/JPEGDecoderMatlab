function [rst_int]=define_restart_interval(fid)
%DEFINE_RESTART_INTERVAL is not actually used in this image.
%This function returns the restart interval value which gives us the 
%number of MCU units in that restart interval.

length=fread(fid,2);
rst_int=bin2dec(strcat(dec2bin(fread(fid,1)),dec2bin(fread(fid,1))));

end

