% Script to generate a cal file (xyz.cal) to upload onto the NanoFET 
% after it has gone through the k0 process. 
% The k0 process is when a nanoFET, mpHOx, etc, is run in the wetlab, test
% tank, or other in water area,
% and periodically discrete samples are taken for calibration. 
%
% INPUT:
% Coefficients from Johnson lab
%   Example file: DF383_Calibration_20230410.TXT
% In situ pH data
%   Example file: /Volumes/CarbonLab/Sensor_Calibrations/Spec_pH
% OUTPUT:
% A .csv file containing coefficients fro k2, f(P), k0 (estimated below),
% serial ID's
%   Example file: NanoFET_calfile_example.cal
%
% Can't exceed more that 6 digits in the valaue output to the .cal file

clear all; close all

DSDid = 'DF172';
sensor = 'mpHOx001';
calnum = '001';

%% Load output calibration example  
% bpath = '/Volumes/901805_Coastal_Biogeochemical_Sensing/nanoFET/Production/Cal_files/NanoFET_example/';
% load([bpath 'NanoFET_calfile_example.cal']) - not sure how to load .cal
% files?


%% Load Vrs sensor data
% May need to update path below to correct sensor folder
% mpHOX has 78 lines of headers (79 = variable names)
S = readtable(['/Volumes/CarbonLab/Sensor_Calibrations/Sensor data/' sensor '_' calnum '.txt'],...
    'NumHeaderLines',78);
S.sdn = datenum(strcat(string(S.MM_DD_YYYY)," ", string(S.HH_MM_SS)),'mm/dd/yyyyHH:MM:SS');


%% Load in situ pH data
% Find in situ data for this DSD calibration by finding overlapping
% datetimes in sensor data and in situ data
D = readtable('/Volumes/CarbonLab/Sensor_Calibrations/Spec_pH/wetlab_specpH');
tmp = cell2mat(D.Comments);
% This assumes the first 3 characters are obsolete (Joe uses TT, FT, MW, etc to
% describe deployments)
tmp = tmp(:,4:end);
D.sdn = datenum(tmp,'yyyymmdd_HHMM');
% Pre-size arrays
D.VRSE = NaN(size(D.sdn));
D.CTDtc = NaN(size(D.sdn));
D.CTDsal = NaN(size(D.sdn));
for i = 1:length(D.sdn)
    tmp = min(abs(D.sdn(i) - S.sdn));
    % Only save if collected within 10 minutes
    if tmp < 0.0069
        % Find nearest sensor data collected to this discrete sample
        Sidx = find(tmp == abs(D.sdn(i) - S.sdn));
        D.VRSE(i) = S.Vrse(Sidx);
        D.CTDtc(i) = S.TC_MCat(Sidx); % Fieldnames may vary...
        D.CTDsal(i) = S.pSal(Sidx);
    else
    end
end

%% Load calibration data from Johnson lab to get f(P) and K2 coefficients from
% jpath = '/Volumes/Chem/DuraFET/CALIBRATION/FinalMatlabCalibrations/DF_383_MSC1080/';
jpath = ['/Volumes/Chem/DuraFET/CALIBRATION/FinalMatlabCalibrations/DF_' DSDid(3:end) '_MSCXXXX/'];

fid=fopen([jpath DSDid '_Calibration_20230410.txt'],'r');
% Read the text file
textData = textscan(fid, '%s %s', 'Delimiter', ':', 'MultipleDelimsAsOne', true);
fclose(fid);

% Initialize variables to store the names and values
k2Names = {};
k2Values = [];
% Search for lines starting with "k2 f(P)"
for i = 1:numel(textData{1})
    name = textData{1}{i};
    value = textData{2}{i};

    if startsWith(name, 'k2 f(P)')
        k2Names = [k2Names, name(1:10)];
        k2Values = [k2Values, str2num(name(11:end))];
        k2 = [str2double('k2 f(P) c0	-1.0226e-03')];
    end
end

%% Calculate insitu pH from discrete measurements
% Find indeces of insitu samples for this calibration
idx = find(~isnan(D.VRSE));
% Change 2270 to spec.TA if it was measured
[trex] = CO2SYS(2270, D.pH_tot(idx), 1, 3, D.CTDsal(idx), D.Temp_used(idx), D.CTDtc(idx), 0, 0, 0, 0, 1, 10, 1);
% Spec pH input for next step
spec_pH_insitu = trex(:,18);

%% Calculate k0 for each in situ sample.. this should be int(???!)
for i = 1:length(D.VRSE(idx))
    [k0(i), ~] = calc_k0_ext(D.VRSE(idx), D.CTDtc(idx), D.CTDsal(idx), spec_pH_insitu(i), cal.k2);
end
% Use median of k0's for final calibration
k0 = median(k0);

%% Make .cal file, include f(P), k0, 
Sensor_SN,DSD1234
ISFET_SN,ISF1234
ISE_SN,ISE1234
PT_Cal_date,12/15/2022
k2_C0,-9.641540E-04
k2_C1,-1.610570E-09
k2_C2,-4.624490E-12
k2_C3,7.304790E-15
fP_0,-1.270040E+00
fP_1,-3.832110E-06
fP_2,1.960530E-08
fP_3,-3.195020E-11
fP_4,2.544840E-14
fP_5,-9.926440E-18
fP_6,1.500790E-21
k0_Cal_date,8/15/2023
k0_HCl,-1.270010E+00
k0_SW,-1.32E+00
k0std_SW,1.20E-04
service_date,11/30/2025


%% Routine I used to manually do the k0 for DSD403 and nanoFET001 that we sent to Scripps:
% estimate k0

% data from labview output:
T.Temp_used = [19.9312
19.9408
19.9348
19.9432];

T.CTDsal = [33.639
33.521
33.606
33.599];

T.pH_tot = [7.697483
7.709833
7.710306
7.68983];

% data from sensor:
VRSE = [-0.960643
-0.959968
-0.960031
-0.961133];

tc = [16.21
16.21
17.5
17.24];

sal = T.CTDsal;

k2 = -9.3648e-04;

dt = [datenum('10/4/23 16:22')
datenum('10/5/23 12:02')
datenum('10/5/23 17:34')
datenum('10/6/23 13:40')];

T.CTDtc = tc;

%% STEP 1:
% calculate insitu pH from discrete measurements
% Change 2270 to spec.TA if it was measured
[trex,H] = CO2SYS(2270, T.pH_tot, 1, 3, T.CTDsal, T.Temp_used, T.CTDtc, 0, 0, 0, 0, 1, 10, 1);
% Spec pH input for next step
spec_pH_insitu = trex(:,18);

% [k0, ~] = calc_k0_ext(VRSE, tc, sal, spec_pH_insitu, k2);
[k0, ~] = calc_k0_ext(VRSE, tc, sal, spec_pH_insitu, k2);

plot(dt,k0,'o','MarkerFaceColor','b');
datetick('x','mmm dd HH:MM')
ylabel('k0 estimated for DSD403')




