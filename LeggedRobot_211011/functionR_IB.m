function [ output_args ] = functionR_IB( Eta )
%UNTITLED3 ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
% fnR_IB = @(eta) [cos(eta(3))*cos(eta(2)),     sin(eta(1))*sin(eta(2))*cos(eta(3))-cos(eta(1))*sin(eta(3)),    cos(eta(1))*cos(eta(3))*sin(eta(2))+sin(eta(1))*sin(eta(3));
%        sin(eta(3))*cos(eta(2)),     sin(eta(1))*sin(eta(2))*sin(eta(3))+cos(eta(1))*cos(eta(3)),    cos(eta(1))*sin(eta(3))*sin(eta(2))-sin(eta(1))*cos(eta(3));
%                   -sin(eta(2)),                                         sin(eta(1))*cos(eta(2)),                                        cos(eta(1))*cos(eta(2))];
output_args = [cos(Eta(3))*cos(Eta(2)),     sin(Eta(1))*sin(Eta(2))*cos(Eta(3))-cos(Eta(1))*sin(Eta(3)),    cos(Eta(1))*cos(Eta(3))*sin(Eta(2))+sin(Eta(1))*sin(Eta(3));
       sin(Eta(3))*cos(Eta(2)),     sin(Eta(1))*sin(Eta(2))*sin(Eta(3))+cos(Eta(1))*cos(Eta(3)),    cos(Eta(1))*sin(Eta(3))*sin(Eta(2))-sin(Eta(1))*cos(Eta(3));
                  -sin(Eta(2)),                                         sin(Eta(1))*cos(Eta(2)),                                        cos(Eta(1))*cos(Eta(2))];


end