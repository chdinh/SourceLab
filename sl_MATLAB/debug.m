clc;
clear all;
close all;

sl_include_core


% ########################################################################
% Inverse Solution
t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');

%
t_InverseSolution = sl_CInverseSolution(t_ForwardSolution);

%
% s = [1 2 3 4 5 6; 7 8 9 10 11 12];
% t_InverseSolution.addActivation([1 2], s);

%
f = 9;
t = 0:0.1:200-0.1;
s1 = sin(2*pi*t*f);

t_InverseSolution.addActivation([121 600], s1, 'activation', [0.8, 0.9]);

%
f = 16;
t = 0:0.1:200-0.1;
s2 = sin(2*pi*t*f);

t_InverseSolution.addActivation([234 881], s2, 'activation', [1]);
%
%t_InverseSolution.resetActivatedSourceSelection();

t_ForwardSolution.selectSources([10 14]);

t_InverseSolution.UseForwardSolutionSelection = false;



%%
plot(t_InverseSolution)











%% ########################################################################
%  # Simulator
clc;
clear all;
close all;

%
t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
t_SamplingFrequency = 1000;
t_Simulator = sl_CSimulator(t_ForwardSolution, t_SamplingFrequency);

%
%t_ForwardSolution.selectSources([600 881]);

T = 1/t_SamplingFrequency;
duration = 2;

f1 = 9;
t1 = 0:T:duration-T;
s1 = sin(2*pi*t1*f1);

f2 = 16;
t2 = 0:T:duration-T;
s2 = sin(2*pi*t2*f2);

%
t_Simulator.SourceActivation.addActivation([121 600], s1);
t_Simulator.SourceActivation.addActivation([234 881], s2);%, [1 0 0; 0 1 0]);

%
t_Simulator.simulate('mode',2,'snr',-5);

plot(t_Simulator);

%% ######################### End Inverse Solution #########################

%% ########################################################################
% Copy Constructor
% t_SourceSpace = sl_CSourceSpace('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif');
% t_SourceSpace2 = t_SourceSpace;
% 
% t_SourceSpace_copy = sl_CSourceSpace(t_SourceSpace);
% 
% %%
% t_ROISpace = sl_CROISpace('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
% t_ROISpace.selectHemispheres([1]);
% 
% t_ROISpace_copy = sl_CROISpace(t_ROISpace);
% t_ROISpace_copy.selectHemispheres( [1 2]);
% 
% %% 
% t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif')%,'./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
% 
% %t_ForwardSolution.data();
% t_ForwardSolution_copy = sl_CForwardSolution(t_ForwardSolution);

%% ########################################################################
clc;
clear all;
close all;

sl_include_core
sl_include_roi

%% SourceSpace Debug
t_SourceSpace = sl_CSourceSpace('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif');
t_SourceSpace.selectHemispheres([1 2]);
figure;
plot(t_SourceSpace);

%% SourceSpace Debug
t_ROISpace = sl_CROISpace('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif', './Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
%figure, plot(t_ROISpace);

names_in = t_ROISpace.ROIAtlas(1,1).struct_names(3:2:7);
labels = t_ROISpace.atlasName2Label(names_in);
names_out = t_ROISpace.label2AtlasName(labels(1,1).label);


% %% Select ROIs
t_ROISpace.selectROIs('lh',labels(1,1).label,'rh',[])
t_ROISpace.selectHemispheres([1]);
plot(t_ROISpace)

%% SourceSpace Debug
t_ROISpace = sl_CROISpace('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif');
plot(t_ROISpace);
%%
t_ROISpace.loadROISpace('./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');
plot(t_ROISpace);

% %% ForwardSolution
% t_debugForwardSolution = sl_CForwardSolution([],[],[],'debugLF', './Data/MEG/ernie/debug/leadfield.txt', 'debugGrid', './Data/MEG/ernie/debug/grid.txt');

%% ########################################################################
% ForwardSolution
%
clc;
clear all;
close all;

t_ForwardSolution = sl_CForwardSolution('./Data/MEG/ernie/sef-oct-6p-src-fwd.fif','./Data/subjects/ernie/label/lh.aparc.a2009s.annot','./Data/subjects/ernie/label/rh.aparc.a2009s.annot');

%
names_in = t_ForwardSolution.ROIAtlas(1,1).struct_names(3);
labels = t_ForwardSolution.atlasName2Label(names_in);
names_out = t_ForwardSolution.label2AtlasName(labels(1,1).label);


%% Select ROIs
%t_ForwardSolution.selectROIs('lh',labels(1,1).label);
t_ForwardSolution.selectHemispheres([1]);

%%
selection = t_ForwardSolution.getRadialSources(20);

t_ForwardSolution.selectSources(selection);


%%
t_ForwardSolution.selectChannels([1 3]);

%t_ForwardSolution.selectSources('lh',[1 147 193],'rh',[4087 4088 4092]);


%%
plot(t_ForwardSolution);

%% ########################################################################
% 3D Vector Test
clc;
clear all;
close all;


vector1 = sl_C3DVector([0 1 2],600);

randPoint = randn(4,3);
vector2 = sl_C3DVector(randPoint, 600);

vector3 = sl_C3DVector(randPoint', 600);

vector4 = sl_C3DVector([999 999 999],600);

vector2.get()

A = rand(3);
vector2.insert(A,2);
vector2.get()

vector2.push(A);
vector2.get()

vector2.set(A,5);
vector2.get()

vector2.set(A,55);
vector2.get()

vector2.insert(vector4,5);
vector2.get()

vector2.push(vector4);
vector2.get()

% figure;
% plot(vector2);
%
% figure;
% plot3(vector2);
% 
% sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);


%% Point test
point1 = sl_C3DPoint([0 1 2],600)

randPoint = randn(4,3);
point2 = sl_C3DPoint(randPoint, 600)

point3 = sl_C3DPoint(randPoint')

point4 = sl_C3DPoint([999 999 999],600)

A = ones(3);
point2.insert(A,2);
point2.get()

point2.insert(point1,2);
point2.get()

% plot(point2);
% 
% figure;
% plot(point3)
% 
% figure;
% plot3(point2);
% 
% sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);

%% pair test
close all;
% create pair with references -> handle class
pointPair = sl_CPair(point1, point2);

% plot(pointPair);
% 
% sl_CUtility.ArrFig('Region', 'fullscreen', 'figmat', [], 'distance', 20, 'monitor', 1);

%% List test
close all;
clear List;

List = sl_CList();

List.append(point1);

List.append(point2);

List.insert(2, point3);

[b, idx1] = List.contains(point3);

idx2 = List.indexOf(point2);

List.append(List);

subList = List.mid(2,3);

List.removeAll(point1);

List.removeAt(2);

res1 = List.at(1);
res1_equiv = List(1);

res2 = List.at([1 2]);
res2_equiv = List([1 2]);

List([1 2]) = point4;
List(1) = point1;

%% Map
clc;
clear Map;
Map = sl_CMap();

Map.insert({'first'}, point1);
Map.insert({'first'}, point3);
Map.insert({'second'}, point2);

Map.insert({'third'}, point2);


res_map1 = Map.value({'second'});
res_map2 = Map.key(point2);

Map2 = sl_CMap();

Map2.insert(1, point1);
Map2.insert(1, point3);
Map2.insert(2, point2);

Map2.insert(3, point2);


res_map3 = Map2.value(2);
res_map4 = Map2.key(point2);

%%
orientation1 = sl_C3DOrientation([2 10 0])
orientation2 = sl_C3DOrientation([200, 0 ,22])

orientation_ref = sl_C3DOrientation(orientation1)

orientation_ref.set([4 100 99])


%% Dipole
dipole = sl_CDipole([200 0 22; 40 0 33])

dipole2 = sl_CDipole(dipole)

dipole3 = sl_CDipole([1 2 3])

dipole4 = sl_CDipole([1 2 3;4 5 6])


%% DipoleMap

dipoleMap = sl_CDipoleMap();

dipoleMap.addDipole(22, dipole)

dipoleMap.addDipole(76, dipole2)

dipRes = dipoleMap.Dipole(22)
dipRes2 = dipoleMap.Dipole(76)


%% Correlated Dipole Map
corrDipoleMap = sl_CCorrelatedDipoleMap();
corrDipoleMap.insert(22, dipole, 76, dipole3);
corrDipoleMap.insert(24, dipole2, 88, dipole4);


