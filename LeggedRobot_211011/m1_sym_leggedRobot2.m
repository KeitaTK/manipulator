clear;
tic;

% Pos  = sym( 'Pos%d', [3,1], 'real');
Eta = sym( 'Eta%d', [3,1], 'real');
Pos = sym('Pos%d', [3,1], 'real');
dPos = sym('dPos%d', [3,1], 'real');

PosIF = functionR_IB(Eta)*Pos;
mat = jacobian(PosIF, Eta);
matlabFunction(mat,  'Vars', {Eta, Pos}, 'File', 'funcdPosMatrix');

toc;

function [ output_args ] = functionR_IB( Eta )
%UNTITLED3 この関数の概要をここに記述
%   詳細説明をここに記述
% fnR_IB = @(eta) [cos(eta(3))*cos(eta(2)),     sin(eta(1))*sin(eta(2))*cos(eta(3))-cos(eta(1))*sin(eta(3)),    cos(eta(1))*cos(eta(3))*sin(eta(2))+sin(eta(1))*sin(eta(3));
%        sin(eta(3))*cos(eta(2)),     sin(eta(1))*sin(eta(2))*sin(eta(3))+cos(eta(1))*cos(eta(3)),    cos(eta(1))*sin(eta(3))*sin(eta(2))-sin(eta(1))*cos(eta(3));
%                   -sin(eta(2)),                                         sin(eta(1))*cos(eta(2)),                                        cos(eta(1))*cos(eta(2))];
output_args = [cos(Eta(3))*cos(Eta(2)),     sin(Eta(1))*sin(Eta(2))*cos(Eta(3))-cos(Eta(1))*sin(Eta(3)),    cos(Eta(1))*cos(Eta(3))*sin(Eta(2))+sin(Eta(1))*sin(Eta(3));
       sin(Eta(3))*cos(Eta(2)),     sin(Eta(1))*sin(Eta(2))*sin(Eta(3))+cos(Eta(1))*cos(Eta(3)),    cos(Eta(1))*sin(Eta(3))*sin(Eta(2))-sin(Eta(1))*cos(Eta(3));
                  -sin(Eta(2)),                                         sin(Eta(1))*cos(Eta(2)),                                        cos(Eta(1))*cos(Eta(2))];


end
