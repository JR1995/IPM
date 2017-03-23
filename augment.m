%augmentΪȫ�����̴���Ϊ�������̵ĳ���
%2013.4.17 ���˳������ڶ�ע�ܻ�����״̬�ռ�ģ�͵�������
%2014.4.15 ��չΪMIMOϵͳ����


function[A_e,B_e,C_e] = augment(Ac,Bc,Cc,~)
%��ȫ������������������
[m1,n1] = size(Ac);             
[m2,n2] = size(Bc);
[m3,n3] = size(Cc);
A_e=zeros(m1+m3,n1+m3);     
A_e(1:m1,1:n1)=Ac;     
A_e(m1+1:m1+m3,1:n1)=Cc*Ac;
A_e(m1+1:m1+m3,n1+1:n1+m3) = eye(m3,m3);
B_e=zeros(m2+m3,n2);
B_e(1:m2,:)=Bc;
B_e(m2+1:m2+m3,:)=Cc*Bc;
C_e=zeros(m3,n3+m3);     
for k = 1:m3
    C_e(k,n3+k)=1;
end
%A_e,B_e,C_e������ģ���еĲ���