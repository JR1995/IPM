%�Ż����ڣ��������������
%delta_u�ļ�����ڡ��鼮����Model Predictive Control System Design and Implementation
%Using MATLAB��P13, 1.25
function [delta_u] = youhua(AA,BB,r_k,x_k)
delta_U = AA * r_k - BB * x_k;
delta_u = delta_U(1,1);
