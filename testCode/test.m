% test file

clc;clear;

G = [4.1404,3.6272,3.2295;3.6272,3.3613,2.9082;3.2295,2.9082,2.6977];

c = [-21.0266;-18.3786;-15.9347];

Omega_L = [1,0,0;0,1,0;0,0,1;-1,0,0;0,-1,0;0,0,-1;1,0,0;1,1,0;1,1,1;-1,0,0;-1,-1,0;-1,-1,-1];

omega_r = [1;1;1;1;1;1;2;2;2;2;2;2];

A = -Omega_L;

b = -omega_r;

F1 = [-(G+eye(3,3)),A';A,eye(12,12)];
x1 = linsolve(F1,[c;b])

%eig(F)

F2 = (G+eye(3,3))+A'*A;
x2 = linsolve(F2,A'*b-c);

y2 = b-A*x2

%eig(F2)