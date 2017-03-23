%��дԭ��MPC�����Ż��ṹ���������ʹ�����ֲ
%2014.3.8
%������Ϊ���Գ����������в������趨�ͳ�ʼ�����������������MPC���㷨
%��ʱ����SISO�����Գɹ�������һ��2x2�Ķ���������д�Ͳ��ԡ�
%2014.4.15 ��һ��2x2��MIMOģ�������� Test Successful!
%2014.4.26 �����ס�Auto-Code Generation for Fast Embedded Model Predictive
%Controllers���е�Model1�����ԣ��Ƚ�Ч��
%2014.8.6 �����ס�Auto-Code Generation for Fast Embedded Model Predictive
%Controllers���е�Model2�����ԣ��Ƚ�Ч��
%2014.8.10���ޠĵ�Model3������

clc;clear;
%����ά��ȷ��
%��ʱ��ȱ����Ϊ����ϵͳΪSISO

%����һЩȫ�ֱ����������
global Ac Bc Cc Cc1 A_e B_e C_e nu ny n_in ndec mc;
global P M L;
global Phi Phi1 Phi2 F F1 F2 Q QQ QQ2 xm G GL;
global u_k_1 u_k_2;
global QPTime TimeIter;
global delta_U_p delta_U_n U_p U_n Y_p Y_n OMEGA_L TotalIter;

global global_res;


N_sim  = 40;                    %����ʱ���趨

%ʱ���¼
QPTime = zeros(N_sim,1);
TotalIter = zeros(N_sim,1);
TimeIter = 1;

%��������ģ�ͣ�ȫ����
nu = 1;ny = 3;nx = 4;          %���������������,����nxΪȫ��ģ��

Ac = [ 0.24    0     0.1787  0;
      -0.3722  1     0.2703  0;
      -0.9901  0     0.1389  0;
      -48.9354 64.1  2.3992  1];
%Bc = [-1.5429;-1.3648;-4.1106;11.4668];
Bc = [-1.2346;-1.4383;-4.4828;-1.7999];
Cc = [ 0     1      0  0;
       0     0      0  1;
      -128.2 128.2  0  0];
%Cc1 =[0 1 0 0] ;                %����Լ��ʱ����y1�������������ǣ��γ��Լ���Phi
Dc = 0;

%Ԥ����Ʋ�������
P = 10;
M = 3;
R = 1;
Q = [1;1;1];          %�����޸ģ���MIMOʱ��R��Q��Ӧ��������
Q2 = 1;
%�����Lר��Ϊ���ֶ�������޸�
%L1 = eye(nx,ny);
L1 = zeros(nx,ny);
L2 = eye(ny,ny);
L=[L1;L2];  

%���߱�������Լ������
ndec = nu*M;
%mc = 4*nu*M;        %���������������Լ��
mc = 4*nu*M+2*1*P; %�������������Լ��

%augment���Զ����ȫ������ת�������̵ĺ���������ԭ����ĵ�
[A_e,B_e,C_e] = augment(Ac,Bc,Cc,Dc);
%[A_e1,B_e1,C_e1] = augment(Ac,Bc,Cc1,Dc);   %���ڵ�����y1����Լ��
C_e1 = C_e(1,:);
%C_e2 = C_e(2,:);

[F,Phi] = fphi_v2(A_e,B_e,C_e,P,M);
[F1,Phi1] = fphi_v2(A_e,B_e,C_e1,P,M);
%[F2,Phi2] = fphi_v2(A_e,B_e,C_e2,P,M);
%F1��Phi1�ļ���û���⣬Ҳ�����


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
OMEGA_L = [II;-II;B;-B;Phi1;-Phi1];   
%�������ر�����Լ��
%OMEGA_L = [II;-II;B;-B];   
delta_U_p_ = 0.524;delta_U_n_ = -0.524;     %MIMOʱ����������Ϊ����
U_p_ = 0.262; U_n_ = -0.262;                %MIMOʱ����������Ϊ����
Y_p_ = 0.349; Y_n_ = -0.349;       %MIMOʱ����������Ϊ����
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
delta_u_ini = 0.1*ones(nu*M,1);
y_ini = 0.5*ones(mc,1);
lambda_ini = 0.5*ones(mc,1);

%ȷ���ο��켣
rr1 = zeros(1,N_sim);
rr2 = 400*ones(1,N_sim);
rr3 = zeros(1,N_sim);
rr = []; 
for i=1:P
    rr = [rr;rr1;rr2;rr3];
end

%GΪ���ι滮����еĲ�����min 0.5*x'*G*x + c'*x   subject to:  A*x <= b
QQ = [];
for k=1:P
    QQ = [QQ;Q];
    k=k+1;
end
QQ = diag(QQ);
QQ2 = Q2*ones(P,1);
QQ2 = diag(QQ2);
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
    [delta_u,delta_u_M_in,u_k,y_k,x_k,delta_u_ini,y_ini,lambda_ini] = mpc_v3_model3_full(delta_u,delta_u_ini,u_k,y_k,x_k,r_k,delta_u_ini,y_ini,lambda_ini);%����MPC�����㷨���м���
    %QPTime(TimeIter,1) = toc;
    %TimeIter = TimeIter + 1;
    %�����������ڻ�ͼ
    delta_u_draw(kk,:) = delta_u';
    %delta_u_uc_draw(kk,:) = delta_u_uc';
    u_draw(kk+1,:) = u_k';
    y_draw(kk+1,:) = y_k';          
    %x_draw(1,kk) = x_k(1,1);x_draw(2,kk) = x_k(2,1);x_draw(3,kk) = x_k(3,1);%x_draw(4,kk) = x_k(4,1);x_draw(5,kk) = x_k(5,1);  %����Ĭ�ϵ�����3��������״̬
    %Iter_rec(kk) = Iter;     %��¼ÿ�����Ż��㷨�ĵ�������
end
%��ͼ
u_draw = u_draw/3.1416*180;
figure;
subplot(4,1,1);plot(rr(1,:),'-.');hold on;plot(y_draw(:,1),'LineWidth',2,'Color','r');  title('Plant Output: yp1(k)'); %axis([0 N_sim -2 2]);
subplot(4,1,2);plot(rr(2,:),'-.');hold on;plot(y_draw(:,2),'LineWidth',2,'Color','r');  title('Plant Output: yp2(k)'); %axis([0 N_sim -2 2]);
subplot(4,1,3);plot(rr(3,:),'-.');hold on;plot(y_draw(:,3),'LineWidth',2,'Color','r');  title('Plant Output: yp3(k)'); %axis([0 N_sim -2 2]);
subplot(4,1,4);stairs(u_draw(:,1),'LineWidth',2);                                      title('Control Input:u(k)');  %axis([0 N_sim -5 5]);
hold on; plot(15*ones(N_sim,1),'--');hold on; plot(-15*ones(N_sim,1),'--');

figure;
subplot(2,1,1); stairs(1000*QPTime,'LineWidth',2);                                     title('QP Time /ms');%axis([0 15 0 0.5]);
subplot(2,1,2); stairs(TotalIter,'LineWidth',2);                                       title('QP Iterations');%axis([0 15 0 0.5]);

% figure;
% subplot(2,1,1);plot(delta_u_draw,'LineWidth',2);title('QP solved solution');
% subplot(2,1,2);plot(delta_u_uc_draw,'LineWidth',2);title('Uncontrained solution');
