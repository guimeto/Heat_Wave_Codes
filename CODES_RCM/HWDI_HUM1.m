% Name: Sum of days in sequences > 3 days where Tmax > 30°C - Tmin > 20°C and Humidex > 40°C  (HWDI3d_HUMI_1) (days)   
% Autor: Guillaume Dueymes 
% Version: v1
% Date:  05/03/2015
%
% Last update: NA
%
% Code History: NA
%
% Let Tx_ij be the daily maximum temperature at day i of period j
% Let Tn_ij be the daily minimum temperature at day i of period j
% Let H_ij be the daily humidex temperature at day i of period j
% Tx_ij > 30
% Tn_ij > 20
% H_ij  > 40
% Sub-functions/codes: NA
%
% Output: - Number of sequences per year/season more than 3 
%           consecutive days respecting the definition of each indice
%
% Global variable: None
%
% Execution time: Short
% 
% Contact: christian.saad@mail.mcgill.ca

%% Code
function HWDI_HUM1 = HWDI_HUM1(tasmin,tasmax,humidex)

% N is defined as the maximum size of the input matrix
%
% N est defini comme la taille maximal de la matrice entrante
N=max(size(tasmin));
% In_wout_missval is defined as the input signal without missing values
%
% In_wout_missval est defini comme la matrice entrante mais sans les valeurs manquantes
In_wout_missval=tasmin(tasmin>-900);
% N2 is defined as the maximum size of the input matrix without missing values
%
% N2 est defini comme la taille maximal de la matrice entrante sans les valeurs manquantes
N2=max(size(In_wout_missval));
clear In_wout_missval;
% The following if statement calculates the indice
% of the input signal if it contains atleast 80% of non-missing data. In
% the case where there is more than 20 of missing data, the indice is not
% calculated and the Out variable is given an NaN value.
%
% Le bloque suivant calcule l'index de la serie temporelle entree si
% il y au moins 80% des donnees entrantes qui correspondent a des valeurs 
% valides (non-manquantes). Dans les cas ou il y a plus de 20 % de valeurs 
% manquantes, l'indice n'est pas calcule et la variable R3days est definie 
% par NaN.
if((N2/N)<0.8);
    HWDI_HUM1=NaN;
else
    
    % initialisation of variables
    %
    % initialisation de temp et HWDI
    temp=0;
    HWDI_HUM1=0;
    NbrSeq=[0 0 0 0 0];
    i=1;
    extradays=0;
    % loop that treats all values of the input time series "In"
    %
    % boucle qui traite toute les valeurs de la serie temporelle entrante (In)
    while i<=N-1
        %i
    	% si 3 jours consecutifs contiennent que des valeurs valides, temp 
        % est calcule en enregistrant la nombre d'evenement ou HWDI est
        % valide
       while(i+1<=N && tasmax(i)>-999 && tasmax(i+1)>-999 && tasmax(i)>=33 && tasmax(i+1)>=33 && tasmin(i)>=20 && tasmin(i+1)>=20 && humidex(i)>=40 && humidex(i+1)>=40);
%         while(i+1<=N && tasmax(i)>-999 && tasmax(i+1)>-999 && tasmax(i)>=31 && tasmax(i+1)>=31 && tasmin(i)>=16 && tasmin(i+1)>=16 && humidex(i)>=33 && humidex(i+1)>=33);
%        while(i+1<=N && tasmax(i)>-999 && tasmax(i+1)>-999 && tasmax(i)>=31 && tasmax(i+1)>=31 && tasmin(i)>=18 && tasmin(i+1)>=18 && humidex(i)>=33 && humidex(i+1)>=33);
%         while(i+1<=N && tasmax(i)>-999 && tasmax(i+1)>-999 && tasmax(i)>=33 && tasmax(i+1)>=33 && tasmin(i)>=20 && tasmin(i+1)>=20 && humidex(i)>=33 && humidex(i+1)>=33);    
            
                % Checking if the other consecutive days respect the
                % indice definition. If so, that day is accounted
                % for in this sequence
                
                    i=i+1;
                    if temp==0;
                        temp=temp+2;
                    else
                        temp=temp+1;
                    end
                    
                
        end
        
        % counting the number of 8+, 7, 6, 5 and 4 consecutive day
        % sequences
        if temp==0 ;
            i=i+1;
            temp=0;
        elseif  temp==1 || temp==2 %|| temp==3
            temp=0;
        elseif temp>=3
           NbrSeq(1,5)=NbrSeq(1,5)+1;
           extradays=extradays+(temp+3);
           temp=0;
%         elseif temp==7
%             NbrSeq(1,4)=NbrSeq(1,4)+1;
%             temp=0;
%         elseif temp==6
%             NbrSeq(1,3)=NbrSeq(1,3)+1;
%             temp=0;
%         elseif temp==5
%             NbrSeq(1,2)=NbrSeq(1,2)+1;
%             temp=0;
%         elseif temp==4
%             NbrSeq(1,1)=NbrSeq(1,1)+1;
%             temp=0;
        end
        
        
        
    end
    
    % Calculating the total number of days respecting these conditions
    TotNbrDays=(NbrSeq(1,1)*4)+(NbrSeq(1,2)*5)+(NbrSeq(1,3)*6)+(NbrSeq(1,4)*7)+(NbrSeq(1,5)*8)+extradays;
    
%     HWDI3days=cat(2,TotNbrDays,NbrSeq); % This variable combines the total number 
                                  % of days for all of the heat or cold wave
                                  % events of that period and in respective
                                  % order, the number of sequences with 4, 5, 
                                  % 6, 7 or 8 consecutive days of HWDI or
                                  % CWDI events.
                                  
       HWDI_HUM1=NbrSeq(5)             ;                   
end

return