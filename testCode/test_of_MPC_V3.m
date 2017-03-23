%��дԭ��MPC�����Ż��ṹ���������ʹ�����ֲ
%2014.3.8
%������Ϊ���Գ����������в������趨�ͳ�ʼ�����������������MPC���㷨
%��ʱ����SISO�����Գɹ�������һ��2x2�Ķ���������д�Ͳ��ԡ�
%2014.4.15 ��һ��2x2��MIMOģ�������� Test Successful!

clc;clear;
%����ά��ȷ��
%��ʱ��ȱ����Ϊ����ϵͳΪSISO

%����һЩȫ�ֱ����������
global Ac Bc Cc A_e B_e C_e nu ny n_in;
global P M L;
global Phi F Q xm G GL;
global u_k_1 u_k_2;

global delta_U_p delta_U_n U_p U_n Y_p Y_n OMEGA_L;

global warm_y warm_lambda;

N_sim  = 50;                    %����ʱ���趨

%��������ģ�ͣ�ȫ����
nu = 2;ny = 2;nx = 3;          %���������������,����nxΪȫ��ģ��
Ac = [1,1,1;0,0,1;0,1,0];
Bc = [0,0;0,-1;1,0];
Cc = [0,0,1;0,0,1];
Dc = 0;

%Ԥ����Ʋ�������
P = 5;
M = 2;
R = 1;
Q = 1;
L1 = zeros(nx,ny);
L2 = eye(ny,ny);
L=[L1;L2];  

%augment���Զ����ȫ������ת�������̵ĺ���������ԭ����ĵ�
[A_e,B_e,C_e] = augment(Ac,Bc,Cc,Dc);

%fphi���Զ���ļ������F�ͦյĺ���
[F,Phi] = fphi_v2(A_e,B_e,C_e,P,M);

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
delta_U_p_ = [1;1];delta_U_n_ = [-1;-1];     %MIMOʱ����������Ϊ����
U_p_ = [0.4;0.4]; U_n_ = [-2;-2];            %MIMOʱ����������Ϊ����
Y_p_ = [2;2]; Y_n_ = [-2;-2];                %MIMOʱ����������Ϊ����
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
rr = ones(ny*P,N_sim);

%GΪ���ι滮����еĲ�����min 0.5*x'*G*x + c'*x   subject to:  A*x <= b
G = Phi'*(Q*eye(ny*P,ny*P))*Phi + R*eye(nu*M,nu*M);
GL = cf(G);

%��¼����������ÿ�����ڵ�ֵ���л�ͼ����
delta_u_draw = zeros(N_sim,nu);
delta_u_uc_draw = zeros(N_sim,nu);
y_draw = zeros(N_sim+1,ny);
x_draw = zeros(n,N_sim);
u_draw = zeros(N_sim+1,nu);
Iter_rec = [];

%�����Ż�
tic
for kk = 1:N_sim;
    r_k = rr(:,kk);        %��kʱ�̵Ĳο��켣���и���
    [delta_u,delta_u_M_in,u_k,y_k,x_k,delta_u_ini,y_ini,lambda_ini] = mpc_v3(delta_u,delta_u_ini,u_k,y_k,x_k,r_k,delta_u_ini,y_ini,lambda_ini);%����MPC�����㷨���м���
    %�����������ڻ�ͼ
    delta_u_draw(kk,:) = delta_u';
    u_draw(kk+1,:) = u_k';
    y_draw(kk+1,:) = y_k';          
    x_draw(1,kk) = x_k(1,1);x_draw(2,kk) = x_k(2,1);x_draw(3,kk) = x_k(3,1);x_draw(4,kk) = x_k(4,1);x_draw(5,kk) = x_k(5,1);  %����Ĭ�ϵ�����3��������״̬
    %Iter_rec(kk) = Iter;     %��¼ÿ�����Ż��㷨�ĵ�������
end
toc
%��ͼ
figure;
subplot(2,2,1); plot(y_draw(:,1),'LineWidth',2,'Color','r'); title('y1(k)');%axis([0 15 0 1.5]);
subplot(2,2,2); plot(y_draw(:,2),'LineWidth',2,'Color','r'); title('y2(k)');%axis([0 15 0 1.5]);
subplot(2,2,3); stairs(u_draw(:,1),'LineWidth',2);           title('u1(k)');%axis([0 15 0 0.5]);
subplot(2,2,4); stairs(u_draw(:,2),'LineWidth',2);           title('u2(k)');%axis([0 15 0 0.5]);