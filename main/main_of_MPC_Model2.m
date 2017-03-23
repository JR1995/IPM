%��дԭ��MPC�����Ż��ṹ���������ʹ�����ֲ
%2014.3.8
%������Ϊ���Գ����������в������趨�ͳ�ʼ�����������������MPC���㷨
%��ʱ����SISO�����Գɹ�������һ��2x2�Ķ���������д�Ͳ��ԡ�
%2014.4.15 ��һ��2x2��MIMOģ�������� Test Successful!
%2014.4.26 �����ס�Auto-Code Generation for Fast Embedded Model Predictive
%Controllers���е�Model1�����ԣ��Ƚ�Ч��
%2014.8.6 �����ס�Auto-Code Generation for Fast Embedded Model Predictive
%Controllers���е�Model2�����ԣ��Ƚ�Ч��

clc;clear;
%����ά��ȷ��
%��ʱ��ȱ����Ϊ����ϵͳΪSISO

%����һЩȫ�ֱ����������
global Ac Bc Cc A_e B_e C_e nu ny n_in ndec mc nx;
global P M L;
global Phi F Q QQ xm xm2 G GL xr xm_old;
global u_k_1 u_k_2;
global QPTime TimeIter;
global delta_U_p delta_U_n U_p U_n Y_p Y_n OMEGA_L TotalIter;
global sim_k yp;

global K x_est Sigma;
global R1 R2 P0;

global global_res;


N_sim  = 300;                    %����ʱ���趨

%ʱ���¼
QPTime = zeros(N_sim,1);
TotalIter = zeros(N_sim,1);
TimeIter = 1;

%��������ģ�ͣ�ȫ����
nu = 1;ny = 2;nx = 4;          %���������������,����nxΪȫ��ģ��
% Ac = [1.1052,0.0110;0,1.0942];
% Bc = [0;0.0082];
% Cc = [1,0];
% Dc = 0;

% Wrong Model2
% Ac = [1 0.5  -1.3895   -0.1681;
%       0 1    -10.1654  -1.3895;
%       0 0    15.426    2.2452;
%       0 0    105.5426  15.426];
% Bc = [0.401;2.3101;-2.2113;-16.1785];
% Cc = [1 0 0 0;
%       0 0 1 0];
% Dc = 0;

% Model2
Ac = [1 0.05  -0.0057  -0.000094883;
      0 1     -0.2308  -0.0057;
      0 0     1.0593   0.0510;
      0 0     2.3968   1.0593];
Bc = [0.0028;0.1106;-0.0091;-0.3674];
Cc = [1 0 0 0;
      0 0 1 0];
Dc = 0;


%Ԥ����Ʋ�������
P = 25;
M = 5;
R = 2;
Q = [1.5;0];          %�����޸ģ���MIMOʱ��R��Q��Ӧ��������
%�����Lר��Ϊ���ֶ�������޸�
% L1 = eye(nx,ny);
% L1 = ones(nx,ny);
L1 = zeros(nx,ny);
L2 = eye(ny,ny);
L=[L1;L2];  

%���߱�������Լ������
ndec = nu*M;
%mc = 4*nu*M;        %���������������Լ��
mc = 2*nu*M+2*ny*P; %�������������Լ��

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
% %�����ر�����Լ��
% OMEGA_L = [II;-II;B;-B;Phi;-Phi];   
%�����ر�����������������
OMEGA_L = [B;-B;Phi;-Phi]; 
%�������ر�����Լ��
%OMEGA_L = [II;-II;B;-B];   
delta_U_p_ = 5;delta_U_n_ = -5;     %MIMOʱ����������Ϊ����
U_p_ = 5; U_n_ = -5;                %MIMOʱ����������Ϊ����
Y_p_ = [2;0.79]; Y_n_ = [-2;-0.79];       %MIMOʱ����������Ϊ����
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
xm2 = xm;
x_k = zeros(n,1);               %����״̬��ʼ��
r = ones(N_sim*ny,1);           %Ŀ�����߳�ʼ��
u_k = zeros(nu,1);                        %���Ʊ�����ʼ��
y_k = zeros(ny,1);                        %���ر�����ʼ��
delta_u = 0.1*ones(nu,1);             %���Ը��Ż����̵�x����һ���ڵĳ�ֵ��
u_k_1 = zeros(nu,1);                  %k-1ʱ�̿��Ʊ�����ʼ��
u_k_2 = zeros(nu,1);                  %k-2ʱ�̿��Ʊ�����ʼ��
delta_u2 = zeros(nu,1);
delta_u_M_in = 0.1*ones(nu*M,1);
delta_u_ini = 0.1*ones(nu*M,1);
y_ini = 0.5*ones(mc,1);
lambda_ini = 0.5*ones(mc,1);
xr = zeros(nx+ny,1);

%ȷ���ο��켣
rr1_1 = ones(1,125);rr1_2 = -1*ones(1,125);rr1_3 = ones(1,50);
rr1 = [rr1_1,rr1_2,rr1_3];
%rr1 = 1*ones(1,N_sim);
rr2 = zeros(1,N_sim);
rr = []; 
for i=1:P
    rr = [rr;rr1;rr2];
end

%GΪ���ι滮����еĲ�����min 0.5*x'*G*x + c'*x   subject to:  A*x <= b
QQ = [];
for k=1:P
    QQ = [QQ;Q];
    k=k+1;
end
QQ = diag(QQ);
G = Phi'*QQ*Phi + R*eye(nu*M,nu*M);
%G = G*10^-35;

GL = cf(G);

%��¼����������ÿ�����ڵ�ֵ���л�ͼ����
delta_u_draw = zeros(N_sim,nu);
delta_u_uc_draw = zeros(N_sim,nu);
y_draw = zeros(N_sim+1,ny);
x_draw = zeros(nx+ny,N_sim);
u_draw = zeros(N_sim+1,nu);
yp_draw = zeros(N_sim+1,P*ny);
xm_draw = zeros(nx,N_sim+1);

Iter_rec = [];

R1 = eye(nx+ny,nx+ny);
R2 = eye(ny,ny);
P0 = eye(nx+ny,nx+ny);

% Kalman filter initialization
K = (A_e*P0*C_e')*inv(C_e*P0*C_e'+R2);
x_est = B_e*zeros(nu,1)+K*zeros(ny,1);
Sigma = (A_e-K*C_e)*P0*(A_e-K*C_e)'+R1+K*R2*K';

%�����Ż�
for kk = 1:N_sim;
    r_k = rr(:,kk);        %��kʱ�̵Ĳο��켣���и���
    tic
    [delta_u,delta_u_M_in,u_k,y_k,x_k,delta_u_ini,y_ini,lambda_ini] = mpc_v3_model2(delta_u,delta_u_ini,u_k,y_k,x_k,r_k,delta_u_ini,y_ini,lambda_ini);%����MPC�����㷨���м���
    %QPTime(TimeIter,1) = toc;
    %TimeIter = TimeIter + 1;
    %�����������ڻ�ͼ
    delta_u_draw(kk,:) = delta_u';
    %delta_u_uc_draw(kk,:) = delta_u_uc';
    u_draw(kk+1,:) = u_k';
    y_draw(kk+1,:) = y_k';          
    x_draw(1,kk) = x_k(1,1);x_draw(2,kk) = x_k(2,1);x_draw(3,kk) = x_k(3,1);x_draw(4,kk) = x_k(4,1);x_draw(5,kk) = x_k(5,1);x_draw(6,kk) = x_k(6,1);  %����Ĭ�ϵ�����3��������״̬
    yp_draw(kk+1,:) = yp'; 
    xm_draw(:,kk+1) = xm; 
    %Iter_rec(kk) = Iter;     %��¼ÿ�����Ż��㷨�ĵ�������
    sim_k = kk;
end



%��ͼ
figure;
subplot(4,1,1);plot(rr(1,:),'-.');hold on;plot(y_draw(:,1),'LineWidth',2,'Color','r');  title('Plant Output: yp(k)'); %axis([0 N_sim -2 2]);
hold on;plot(y_draw(:,2),'LineWidth',2,'Color','r');
subplot(4,1,2);stairs(u_draw(:,1),'LineWidth',2);                                      title('Control Input:u(k)');  %axis([0 N_sim -5 5]);
hold on; plot(5*ones(N_sim,1),'--');hold on; plot(-5*ones(N_sim,1),'--');
subplot(4,1,3); stairs(1000*QPTime,'LineWidth',2);                                     title('QP Time /ms');%axis([0 15 0 0.5]);
subplot(4,1,4); stairs(TotalIter,'LineWidth',2);                                       title('QP Iterations');%axis([0 15 0 0.5]);

% figure;
% subplot(2,1,1);plot(delta_u_draw,'LineWidth',2);title('QP solved solution');
% subplot(2,1,2);plot(delta_u_uc_draw,'LineWidth',2);title('Uncontrained solution');
