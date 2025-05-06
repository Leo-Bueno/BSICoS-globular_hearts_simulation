% This script computes pseudoECG using the heart mesh H.
% H is a structure containing H.tri (elements tetrahedras Nx4), H.xyz (nodes
% coordinates Nx3), H.face (triangular elements ID Nx3)
% H.xyzV contains the voltage at each node for a time instant.
%% place where code will run 

clear; close all;
addpath Tools/
filepath = fileparts(mfilename('fullpath'));

name = 'Control';
H=fopen([filepath,'\Mesh\',name,'.inp'],'r');
H1 = textscan(H,'%s','Delimiter','\n'); %% get data from H
H1 = H1{1} ;    
fclose(H);

%% Node and element data organization
node_row_f = strfind(H1, 'Node'); 
node_row = find(not(cellfun('isempty', node_row_f))); % node section line

element_row_f = strfind(H1, 'Element'); 
element_row = find(not(cellfun('isempty', element_row_f)));% element section line

node = H1 (node_row+1:element_row-1);
node_m = cell2mat(cellfun(@str2num,node, 'UniformOutput',false)) ; % node matrix

nset_row_f = strfind(H1, 'Nset'); 
nset_row = find(not(cellfun('isempty', nset_row_f))); %%get line number of Nsets

element = H1(element_row+1: nset_row(1)-1);
element_m = cell2mat(cellfun(@str2num,element, 'UniformOutput',false)) ; % element matrix

%% Adjust new mesh
H.xyz = node_m(:,2:end)/10; % to save node coordinates in cm
H.tri = element_m

test = 'C_remesh'; % name of the simulation
modelo = 'control'; % control or globular

%% Load files - mesh and voltage data
ap_data = voltage_org(modelo,pathsd,test) ; % voltage_o and voltage_g will save as ap_data

H.celltype = 10; % Tetrahedra

% Position of each electrode [cm]
eLA = [ 26.31299, 21.497723, 7.420229 ];
eRA = [ 18.14213, 7.501999, 34.070068 ];
eLL = [ -5.31373, -1.789089, -15.429269 ];
eRL = [ -12.167669, -16.31675, 9.517775 ];
eV1 = [ 10.906326, -1.15405, 11.845679 ];
eV2 = [ 12.095185, 0.145529, 7.290848 ];
eV3 = [ 12.538002, -0.624515, 2.997591 ];
eV4 = [ 13.385409, 0.370621, -1.533757];
eV5 = [ 13.98705, 7.981137, -9.384242] ;
eV6 = [ 8.927311, 16.816456, -7.379554] ;
        
E = [ eLA ; eRA ; eLL ; eRL ; eV1 ; eV2 ; eV3 ; eV4 ; eV5 ; eV6 ];

% Center of the tetrahedra
H.triCENTER = meshFacesCenter( H );

% Volume of the tetrahedra
H.triVOL    = meshVolume( H , 'volume' );

% Precomputation of the linear operator to calculate the voltage gradient at each time.
H.Gop       = meshGradient( H );

%time_step = size(ap_data,2);
pECG=[];

for i=15:-1:1 % 15 because 3 beats

    for t = 200*i:-1:200*(i-1)+1
        H.triG(:,:,t-200*(i-1)) = reshape( H.Gop * ap_data(1:end,t)   ,[],3);
    end

% Computation of pseudoECG.
pECG = [computePECG( H , E ); pECG];
i
end

%% Save data
if modelo == 'n'
    ext_file = sprintf('pECG_%s.mat',test);
    dir_pECG = [dir,'/',ext_file];
    save(dir_pECG , 'pECG');
%    save('pECG_o.mat' , 'pECG2');
else
    ext_file = sprintf('pECG_%s.mat',test);
    dir_pECG = [pathsd,'/Pseudo/',ext_file];
    save(dir_pECG , 'pECG');
%    save('pECG_g.mat' , 'pECG2'); %globular
end
