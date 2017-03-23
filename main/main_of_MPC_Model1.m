%��дԭ��MPC�����Ż��ṹ���������ʹ�����ֲ
%2014.3.8
%������Ϊ���Գ����������в������趨�ͳ�ʼ�����������������MPC���㷨
%��ʱ����SISO�����Գɹ�������һ��2x2�Ķ���������д�Ͳ��ԡ�
%2014.4.15 ��һ��2x2��MIMOģ�������� Test Successful!
%2014.4.26 �����ס�Auto-Code Generation for Fast Embedded Model Predictive
%Controllers���е�Model1�����ԣ��Ƚ�Ч��

clc;clear;
%����ά��ȷ��
%��ʱ��ȱ����Ϊ����ϵͳΪSISO

%% Add the father path into the working directroy
currentDepth = 1; % get the supper path of the current path
currPath = fileparts(mfilename('fullpath')); % get current path
pos_v = strfind(currPath,filesep);
father_p = currPath(1:pos_v(length(pos_v)-currentDepth+1)-1);
% -1: delete the last character '/' or '\'
addpath(father_p);

%����һЩȫ�ֱ����������
global Ac Bc Cc A_e B_e C_e nu ny n_in;
global P M L;
global Phi F Q xm G GL QQ;
global u_k_1 u_k_2;
global QPTimeQUAD QPTimeDSPASM QPTimeDSPWGS TimeIter;
global delta_U_p delta_U_n U_p U_n Y_p Y_n OMEGA_L TotalIter serialPort;
global dspTransed

global global_res;

dspTransed = 0;

s=serial('COM4');           %�������ڶ���s�����ڶ˺�COM
set(s,'BaudRate',115200);   %�趨����s�Ĳ�����
set(s,'Timeout',10);        %�趨����sʧЧʱ��
fopen(s);                   %�򿪴���s
serialPort = s;

N_sim  = 100;                    %����ʱ���趨

%ʱ���¼
QPTimeQUAD = zeros(N_sim,1);
QPTimeDSPASM = zeros(N_sim,1);
QPTimeDSPWGS = zeros(N_sim,1);
TotalIter = zeros(N_sim,1);
TimeIter = 1;

%��������ģ�ͣ�ȫ����
nu = 1;ny = 1;nx = 2;          %���������������,����nxΪȫ��ģ��
% Ac = [1.1052,0.0110;0,1.0942];
% Bc = [0;0.0082];
% Cc = [1,0];
% Dc = 0;

Ac = [1,0.1;0,0.9];
Bc = [0;0.0787];
Cc = [1,0];
Dc = 0;

%Ԥ����Ʋ�������
P = 20;
M = 3;
R = 0.1;
Q = 1;
%�����Lר��Ϊ���ֶ�������޸�
%L1 = ones(nx,ny);
L1 = zeros(nx,ny);
L2 = eye(ny,ny);
L=[L1;L2];  

%augment���Զ����ȫ������ת�������̵ĺ���������ԭ����ĵ�
[A_e,B_e,C_e] = augment(Ac,Bc,Cc,Dc);
[F,Phi] = fphi_v2(A_e,B_e,C_e,P,M);


%fphi���Զ���ļ������F�ͦյĺ���

%Լ����������
II = eye(nu*M,nu*M);
B = eye(nu*M,nu*M);
for i = 1:nu*M
    for j = 1:nu*M
        for k = 1:M
            if(i==(j+(k-1)*nu))
                B(i,j)=1;
            end
        end
    end
end
%�����ر�����Լ��
%OMEGA_L = [II;-II;B;-B;Phi;-Phi];   
%�������ر�����Լ��
OMEGA_L = [II;-II;B;-B];   
delta_U_p_ = 1;delta_U_n_ = -1;     %MIMOʱ����������Ϊ����
U_p_ = 2; U_n_ = -2;                %MIMOʱ����������Ϊ����
Y_p_ = [2;2]; Y_n_ = [-2;-2];       %MIMOʱ����������Ϊ����
%��Լ����չ��M��P����ʱ��
delta_U_p=[];delta_U_n=[];U_p=[];U_n=[];Y_p=[];Y_n=[];
for k = 1:M
    delta_U_p = [delta_U_p;delta_U_p_];
    delta_U_n = [delta_U_n;delta_U_n_];
    U_p = [U_p;U_p_];
    U_n = [U_n;U_n_];
end
for k = 1:P
    Y_p = [Y_p;Y_p_];
    Y_n = [Y_n;Y_n_];
end

%�����Ż���ʼ��
[n,n_in] = size(B_e);           %ȷ��״̬ά��
xm = zeros(nx,1);                     %ȫ��״̬��ʼ��
x_k = zeros(n,1);               %����״̬��ʼ��
r = ones(N_sim*ny,1);           %Ŀ�����߳�ʼ��
u_k = zeros(nu,1);                        %���Ʊ�����ʼ��
y_k = zeros(ny,1);                        %���ر�����ʼ��
delta_u = 0.1*ones(nu,1);             %���Ը��Ż����̵�x����һ���ڵĳ�ֵ��
u_k_1 = zeros(nu,1);                  %k-1ʱ�̿��Ʊ�����ʼ��
u_k_2 = zeros(nu,1);                  %k-2ʱ�̿��Ʊ�����ʼ��
delta_u2 = zeros(nu,1);
delta_u_M_in = zeros(nu*M,1);
delta_u_ini = 0.5*ones(nu*M,1);
y_ini = 0.5*ones(4*nu*M,1);
lambda_ini = 0.5*ones(4*nu*M,1);

%ȷ���ο��켣
rr1 = 3*ones(ny*P,N_sim/2);
rr2 = ones(ny*P,N_sim/2);
rr = [rr1,rr2];

%GΪ���ι滮����еĲ�����min 0.5*x'*G*x + c'*x   subject to:  A*x <= b
QQ = [];
for k=1:P
    QQ = [QQ;Q];
    k=k+1;
end
QQ = diag(QQ);
G = Phi'*QQ*Phi + R*eye(nu*M,nu*M);
GL = cf(G);

%��¼����������ÿ�����ڵ�ֵ���л�ͼ����
delta_u_draw = zeros(N_sim,nu);
delta_u_uc_draw = zeros(N_sim,nu);
y_draw = zeros(N_sim+1,ny);
x_draw = zeros(n,N_sim);
u_draw = zeros(N_sim+1,nu);
Iter_rec = [];

%�����Ż�
for kk = 1:N_sim;
    r_k = rr(:,kk);        %��kʱ�̵Ĳο��켣���и���
    %tic
    [delta_u,delta_u_M_in,u_k,y_k,x_k,delta_u_ini,y_ini,lambda_ini] = mpc_v3(delta_u,delta_u_ini,u_k,y_k,x_k,r_k,delta_u_ini,y_ini,lambda_ini);%����MPC�����㷨���м���
    %QPTime(TimeIter,1) = toc;
    %TimeIter = TimeIter + 1;
    %�����������ڻ�ͼ
    delta_u_draw(kk,:) = delta_u';
    %delta_u_uc_draw(kk,:) = delta_u_uc';
    u_draw(kk+1,:) = u_k';
    y_draw(kk+1,:) = y_k';          
    x_draw(1,kk) = x_k(1,1);x_draw(2,kk) = x_k(2,1);x_draw(3,kk) = x_k(3,1);%x_draw(4,kk) = x_k(4,1);x_draw(5,kk) = x_k(5,1);  %����Ĭ�ϵ�����3��������״̬
    %Iter_rec(kk) = Iter;     %��¼ÿ�����Ż��㷨�ĵ�������
end

fclose(s);                   %�򿪴���s

%��ͼ
figure;
subplot(4,1,1);plot(rr(1,:),'-.');hold on;plot(y_draw(:,1),'LineWidth',2,'Color','r');  title('Plant Output: yp(k)'); axis([0 200 0 4]);
subplot(4,1,2);stairs(u_draw(:,1),'LineWidth',2);                                      title('Control Input:u(k)');  axis([0 200 -2.2 2.2]);
hold on; plot(2*ones(N_sim,1),'--');hold on; plot(-2*ones(N_sim,1),'--');
subplot(4,1,3); stairs(1000*QPTimeQUAD,'LineWidth',2);                                     title('QP Time /ms');%axis([0 15 0 0.5]);
subplot(4,1,4); stairs(TotalIter,'LineWidth',2);                                       title('QP Iterations');%axis([0 15 0 0.5]);

% figure;
% subplot(2,1,1);plot(delta_u_draw,'LineWidth',2);title('QP solved solution');
% subplot(2,1,2);plot(delta_u_uc_draw,'LineWidth',2);title('Uncontrained solution');
