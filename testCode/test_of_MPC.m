%�����Ա��MPC�����Ƿ����
%2013.1.17
%ע�⣬��Ϊ�ǳ����Ĳ��Գ���������������Щ�ǿ����Զ���ȡģ�ͽ����ģ���Щ�ǰ���Ĭ��ȫ������Ϊ2�ף���������Ϊ3��д��
%���Ҫ�õ�����������ʱ����Ҫ���޸�

%����ʱ����Ƶ�ʵ��
clear;clc;
%��������ģ�ͣ�ȫ����
Ac = [0.5 1;0 0.5];
Bc = [0.5;1];
Cc = [1 0];
Dc = 0;

%Ԥ����Ʋ�������
Np = 10;            %Ԥ��ʱ���ѡ������Ծ���ԣ��������ԣ����ͺ�
Nc = 2;
R = 1;
Q = 1;

%augment���Զ����ȫ������ת�������̵ĺ���
[A_e,B_e,C_e] = augment(Ac,Bc,Cc,Dc);

%fphi���Զ���ļ������F�ͦյĺ�����AA��BBΪ�����U��ʽ�еĲ���
[BarRs,Phi_Phi,Phi_F,Phi_R,F,Phi] = fphi(A_e,B_e,C_e,Np,Nc);
AA = (Phi_Phi+R*eye(Nc,Nc))\ Phi_R;
BB = (Phi_Phi+R*eye(Nc,Nc))\ Phi_F;

%�����Ż���ʼ��
[n,n_in] = size(B_e);%ȷ��״̬ά��
xm = [0;0];          %ȫ��״̬��ʼ��
x_k = zeros(n,1);    %����״̬��ʼ��
N_sim  = 50;         %����ʱ���趨
r = ones(N_sim,1);   %Ŀ�����߳�ʼ��
u_k = 0;            
y_k = 0;
u_k_1 = 0;
u_k_2 = 0;
delta_u1 = zeros(N_sim,1);
rr = ones(Np,N_sim);
delta_u2 = [0;0];

G = Phi'*(Q*eye(Np,Np))*Phi + R*eye(Nc,Nc);


%����;����Ԥ�ȷ�����Լӿ�MATLAB�����ٶ�
y1 = zeros(N_sim+1,1);
x1 = zeros(n,N_sim);
u1 = zeros(N_sim+1,1);

%tic;
%�����Ż�
for kk = 1:N_sim;
    x_k = fankui(kk,x_k,y_k,u_k_1,u_k_2,A_e,B_e,C_e);
    c = (F*x_k-rr(:,kk))'*(Q*eye(Np,Np))*Phi;
    c = c';
    delta_u = quadprog(G,c,[1,0;-1,0;0,1;0,-1],0.8*[1;1;1;1],[],[],[],[],[0;0],'TolFun',1e-8);
    %[delta_u,~,~] = priduip(G,c,-[1,0;-1,0;0,1;0,-1],-0.8*[1;1;1;1],[0;0],[2;2;2;2],[0.5;0.1;0.1;0.1]);
    %[delta_u,~,~] = barrier(G,c,[1,0;0,-1],[0.3;0.3],[0;0]);
    delta_u = delta_u(1,1);
    %delta_u = youhua(AA,BB,r(kk),x_k);
    u_k = u_k + delta_u;
    delta_u1(kk) = delta_u;
    u1(kk+1,1) = u_k;
    xm = Ac*xm + Bc*u_k;  %ȫ��״̬����
    y = Cc*xm;            %�������
    y1(kk+1,1) = y;
    y_k = y;              %����������Ԥ��õ���y��Ϊ��һ�������߼���yֵ
    x1(1,kk) = x_k(1,1);x1(2,kk) = x_k(2,1);x1(3,kk) = x_k(3,1);
    u_k_2 = u_k_1;
    u_k_1 = u_k;
end
%toc;

%��ͼ
k=0:(N_sim-1);
kk=0:(N_sim);
%figure
%subplot(4,4,12);    plot(kk,y1,'LineWidth',2,'Color','r');title('y(k),AS,��U = 0.8');axis([0 15 0 1.5]);
%subplot(412);   plot(k,y2);  legend('y2');
%subplot(4,4,16);    stairs(kk,u1,'LineWidth',2);title('u(k),AS,��U = 0.8');axis([0 15 0 0.5]);
%subplot(414);   plot(k,u2);  legend('u2');
%xlabel('Sampling Instant');