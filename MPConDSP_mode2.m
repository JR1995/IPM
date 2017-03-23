%�������������Matlab������Model2�ķ����Ե�ģ�ͣ���ʵ��PIL
%��ص�ģ������jMPC Toolbox�е�nl_pend
%���������Matlab_RS_V2��ÿ��д����������

function [y,xm2] = MPConDSP_mode2(u,xm2)

global Cc
global u_model2
x = xm2;

%Inputs
% u1 = Force applied to the cart [N]

%States
% x1 = Position of the cart [m]
% x2 = Velocity of the cart [m/s]
% x3 = Angle of the pendulum from vertical [rad]
% x4 = Angular velocity of the pendulum [rad/s]

%Assign Parameters
%[M,m,l,g] = param{:};


u_model2 = u;

%u = 0.1;

[T,x] = ode15s('model2ode',[0 0.05],x);

[row,col] = size(x);

xm2 = x(row,:)';

y = Cc*xm2;         


