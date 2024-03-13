function [k0, Eo_ext_insitu] = calc_k0_ext(Vext, TC, sal, pH_insitu, UseDefaultk2)

% [Eo_ext_insitu, Eo_ext_25C] = calc_Eo_ext(Vext, TC, sal, pH_insitu)
%
% Calculate Eo (calibration coefficients) for Durafet using the external
% reference electrode at in situ and 25C. 
% 
%  Calibration code taken from Bresnahan et al. 2014, Methods in
%  Oceanography.
%


% Univ gas constant, Faraday constant
R = 8.3145; F = 96487; 
% Temperature dependence of standard potentials, Martz et al. 2010
if(strcmp(UseDefaultk2, 'UseDefaultk2'))
    k2 = -0.001048;
else
    k2 = UseDefaultk2;
end

% See Martz et al. 2010 for greater detail
TK = TC + 273.15; % Convert temp from C to K
S_T = (R.*TK)./F.*log(10); % Nernst temp dependence

Z = 19.924.*sal ./ (1000 - 1.005 .* sal); % Ionic strength, Dickson et al. 2007
SO4_tot = (0.14 ./ 96.062) .* (sal ./ 1.80655);  % Total conservative sulfate
cCl = 0.99889 ./ 35.453 .*sal ./ 1.80655; % Conservative chloride
mCl = cCl .* 1000 ./ (1000 - sal.*35.165 ./ 35); % mol/kg-H2O
K_HSO4 = exp(-4276.1 ./ TK + 141.328 - 23.093 .* log(TK)...
          +(-13856 ./ TK + 324.57 - 47.986 .* log(TK)) .* Z.^0.5...
          +(35474./TK - 771.54 + 114.723.*log(TK)).*Z - 2698./TK.*Z.^1.5...
          +1776./TK.*Z.^2 + log(1-0.001005.*sal)); % Bisulfate equilibrium const., Dickson et al. 2007
pHint_free = pH_insitu + log10(1 + SO4_tot./K_HSO4);
cHfree = 10.^(-pHint_free); % mol/kg-sw
pHint_free_molal = pHint_free + log10((1000 - sal.*35.165./35)./1000); % mol/kg-H2O
mHfree = 10.^(-pHint_free_molal); % mol/kg-H2O
DHconst = 0.00000343.*TC.^2 + 0.00067524.*TC + 0.49172143; % Debye-Huckel, Khoo et al. 1977
log10gamma_HCl = 2.*(-DHconst.*sqrt(Z)./(1 + 1.394.*sqrt(Z)) + (0.08885-0.000111.*TC).*Z);
aHfree_aCl = mHfree.*mCl.*10.^(log10gamma_HCl); 
Eo_ext_insitu = Vext + S_T.*log10(aHfree_aCl);
k0 = Eo_ext_insitu - k2.*TC;
 
return
