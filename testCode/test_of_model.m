%��д��С���������Ա��ض��������

clear;clc;

%Ac = [0.5 1;0 0.5];
%Bc = [0.5;1];
%Cc = [1 0];
%Dc = 0;

%���ס�Two-time dimensional dynamic matrix control for batch processes with
%convergence analysis against the 2D interval uncertainty���е�ģ��

% %ԭ�����еļ�ģ��
% NUM = [290];
% DEN = [0.205,1];
% 
% %��ɢ���ļ�ģ��
% NUM = [13.81,0];
% DEN = [1,-0.9524];

%���ס�Auto-Code Generation for Fast Embedded Model Predictive
%Controllers���е�ģ��

% Ac = [1,0.1;0,0.9];
% Bc = [0;0.0787];
% Cc = [1,0];
% Dc = 0;

%���ס�Auto-Code Generation for Fast Embedded Model Predictive
%Controllers���е�ģ��2
Ac = [0 1 0 0;0 0 -4.5277 0;0 0 0 1;0 0 47.0088 0];
Bc = [0;2.1978;0;-7.2059];
Cc = [1 0 0 0;0 0 1 0];
Dc = 0;

% % �ޠĵ�ģ��
% Ac = [ -1.2822  0      0.98     0;
%         0       0      1        0;
%        -5.4293  0      -1.8366  0;
%        -128.2   128.2  0        0];
% Bc = [-0.3;0;-17;0];
% Cc = [0       1     0  0;
%       0       0     0  1;
%       -128.2  128.2 0  0];
% Dc = 0;

SYSc = ss(Ac,Bc,Cc,Dc);
SYSd = c2d(SYSc,0.05);

% figure;
% step(SYSc);
% figure;
% step(SYSd);

%step(SYSc);

[Yc,Tc] = step(SYSc);
[Yd,Td] = step(SYSd);
figure;
plot(Tc,Yc,'linewidth',2);axis([0 10 -10^25 10^25]);
figure;
plot(Td,Yd,'linewidth',2);axis([0 10 -10^25 10^25]);

%�õ���׼�Ĵ�һ�������ͺ����ɢ���ƶ���Ĵ��ݺ���ģ��
%dis_tf_d = tf([0,0,13.8],[1 -0.9524],0.01,'Variable','z^-1')

%�õ���׼�����ͺ����ɢ���ƶ���Ĵ��ݺ���ģ��
%dis_tf = tf([0,13.8],[1 -0.9524],0.01,'Variable','z^-1')


%�õ���ɢ���ƶ����Ӧ��״̬�ռ�ģ��
%dis_ss=ss(dis_tf)


%��������������ȷ��û�п���֮�󣬶���Ҳ��֪��״̬������ѡ��
%[A,B,C,D] = tf2ss(NUM,DEN)

%SYS = ss(Ac,Bc,Cc,Dc,-1);
%SYS =tf(NUM,DEN,10)
%SYSDis = c2d(SYS,10)

%���ֱ�ʾ
%SYS1=tf(SYS)
%SYS2=zpk(SYS)

%figure
%step(dis_tf);
%figure
%step(dis_ss);
