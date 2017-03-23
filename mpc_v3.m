
function [delta_u,delta_u_M_out,u_k,y_k,x_k,delta_u_ini,y_ini,lambda_ini] = mpc_v3(delta_u,delta_u_M_in,u_k,y_k,x_k,r_k,delta_u_ini,y_ini,lambda_ini)

global Ac Bc Cc nu ny P M sim_k;
global Phi Phi1 Phi2 F F1 F2 Q QQ QQ2 xm G GL;
global u_k_1 u_k_2;
global delta_U_p delta_U_n U_p U_n Y_p Y_n OMEGA_L;
global QPTimeQUAD QPTimeDSPASM QPTimeDSPWGS TimeIter TotalIter serialPort dspTransed;

global warm_y warm_lambda;

x_k = fankui_v2(x_k,y_k,u_k_1,u_k_2);
aug_u_k_1 = [];
for k = 1:M
    aug_u_k_1 = [aug_u_k_1;u_k_1];
end
% %�����ر�����Լ��
% omega_r = [delta_U_p;-delta_U_n;U_p-aug_u_k_1;-U_n+aug_u_k_1;Y_p-F*x_k;-Y_n+F*x_k];
%�����ر�����������������Լ��
% omega_r = [U_p-aug_u_k_1;-U_n+aug_u_k_1;Y_p-F*x_k;-Y_n+F*x_k];
%�������ر�����Լ��
omega_r = [delta_U_p;-delta_U_n;U_p-aug_u_k_1;-U_n+aug_u_k_1];
c = (F*x_k-r_k)'*QQ*Phi;
c = c';
%c = c*10^-35;

%ȷ����ֵ��DY�ķ���
[delta_u_ini,y_ini,lambda_ini] = SP_DY(delta_u_M_in,omega_r,OMEGA_L,0.01,delta_u_ini,y_ini,lambda_ini);

%ȷ����ֵ��AUT�ķ���
%[delta_u_ini,y_ini,lambda_ini] = SP_AUT(G,c,-OMEGA_L,-omega_r,0.5);
% 
% %ȷ����ֵ��LOQO�ķ����������⣬��ʱ���ã�
%[delta_u_ini,y_ini,lambda_ini] = SP_LOQO(G,c,-OMEGA_L,-omega_r);
% 
% %ȷ����ֵ��Wright������ʽ��������Ҫ�û��ṩһ����ʼ�㣩
% [delta_u_ini,y_ini,lambda_ini] = SP_wright(delta_u_ini,y_ini,lambda_ini,G,c,-OMEGA_L,-omega_r);



%tic
%�ڵ㷨����Ż�����
%[delta_u_M_out,~,~,Iter] = priduip_v2(G,c,-OMEGA_L,-omega_r,delta_u_ini,y_ini,lambda_ini);
%[delta_u_M_out,~,~,Iter] = priduip_v4(G,GL,c,-OMEGA_L,-omega_r,delta_u_ini,y_ini,lambda_ini);
%[delta_u_M_out,~,~,Iter] = IPM_v2(G,GL,c,-OMEGA_L,-omega_r,delta_u_ini,y_ini,lambda_ini);
%[delta_u,~,Iter,~,~] = quad_wright(G,c,OMEGA_L,omega_r,60,0.00001,0,delta_u_ini,lambda_ini,y_ini);
tic 
delta_u_M_out = quadprog(G,c,OMEGA_L,omega_r);
QPTimeQUAD(TimeIter,1) = toc;

if dspTransed == 0
    [delta_u_M_out_ASM,QPTimeDSPASM(TimeIter,1),TotalIter(TimeIter,1)] = ...
        dspSolver(G,c,-OMEGA_L,-omega_r,delta_u_ini,[],1,1,serialPort);
    [delta_u_M_out_WGS,QPTimeDSPWGS(TimeIter,1),TotalIter(TimeIter,1)] = ...
        dspSolver(G,c,-OMEGA_L,-omega_r,delta_u_ini,[],2,1,serialPort);
    dspTransed = 1;
else
    [delta_u_M_out_ASM,QPTimeDSPASM(TimeIter,1),TotalIter(TimeIter,1)] = ...
        dspSolver(G,c,-OMEGA_L,-omega_r,delta_u_ini,[],1,0,serialPort);
    [delta_u_M_out_WGS,QPTimeDSPWGS(TimeIter,1),TotalIter(TimeIter,1)] = ...
        dspSolver(G,c,-OMEGA_L,-omega_r,delta_u_ini,[],2,0,serialPort);
end

if norm(delta_u_M_out - delta_u_M_out_ASM) > 0.0001 || ...
        norm(delta_u_M_out - delta_u_M_out_WGS) > 0.0001
    error('DSP get wrong answer!');
end

%QPTime(TimeIter,1) = toc;
%TotalIter(TimeIter,1) = Iter;
TimeIter = TimeIter + 1;
%�����ڵ㷨
%[delta_u,~,~,Iter,y,lambda] = ipm(G,c,-OMEGA_L,-omega_r,delta_u_ini,y_ini,lambda_ini);
%�����������ڵ㷨


delta_u = delta_u_M_out(1:nu,1);
u_k = u_k + delta_u;
xm = Ac*xm + Bc*u_k;  %ȫ��״̬����
y_k = Cc*xm;            %�������
u_k_2 = u_k_1;
u_k_1 = u_k;
end