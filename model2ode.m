%�ó��������������Model2��΢�ַ����飬����ĵ���9��4�տ���С��
%2014.9.4
%yi
%���Ƿ�����ĺ����ļ�

function dx = model2ode(t,x)

global u_model2

M = 0.455;
m = 0.21;
l = 0.305;
g = 9.81;

u = u_model2;

dx = zeros(4,1);
dx(1) = x(2);
dx(2) = (u/m + l*x(3)^2*sin(x(3)) - g*sin(x(3))*cos(x(3)))/(M/m + sin(x(3))^2);
dx(3) = x(4);
dx(4) = (-u/m*cos(x(3))+ (M+m)/m*g*sin(x(3))-l*x(3)^2*sin(x(3))*cos(x(3)))/(l*(M/m + sin(x(3))^2));
