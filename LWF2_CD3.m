clear all
tic
global Alpha Vc Sc K d_t t figure1
Alpha=1;
Vc=5*10^-16;
Sc=3*10^-10;
K=[ 1./3000   1./30000   1.e-4  3e-11  1e4]; % 6 kinetic constants
% Numerical discretization for Number Density Function
N=2001;
tmax=100000;
M=N;
d_t(1:N)=tmax/(M-1);
dt=d_t(1);
t=0:d_t(1):tmax;
%% Initial concentration of all proteins
c_init=[3.24*10^-10;0;0;0;0;0];% 'CD3','CD3i','CD25','IL 2','CD25-IL2'
%% solving DE
d=growth(c_init(1));
conc_Fig(d(:,:,:));
c1(1:M,1:M)=d(1,:,:);
[c1min,t1min]=min(min(c1));
[c1max,t1max]=max(max(c1));
Lc=round((N));
%% Interpolation of c3 as x3, c4 as x4 and c5 as x5
G=zeros(N,M);
for k=1:M
   G(k:-1:1,k)=-K(1).*c1(k,1:k);
end
for k=1:N
    G1(N:-1:1,k)=G(:,k);
end
G2=G1;%zeros(Lc,Lt);
for i=2:Lc
    G3(i,:)=(G1(i-1,:)+G1(i,:))/2;
end
G3(1,:)=G1(1,:);

%%  Reducing Problem
% discretization for c
Lc=round((N));
% for i=1:N-1
dC1=abs(diff(c1(:,1)));
% end
C1=sort(c1(:,1));
Lt=N;
%% Given condition
k=0;
n1=zeros(Lc,Lt);
B=@(t) 3*10^8*exp(-t/7200);
% figure
% hold on
n=zeros(Lc,Lt);
for i=1:Lc
   n1(i,1)=0;
end
for j=1:Lt
%     if not(G2(1,j)==0)
        n1(Lc,j)=-B(t(j))/G1(Lc,j);
%     end
end
    
%% Numerical Method
for j=1:Lt-1
    for i=2:Lc-1
        v=d_t(j)/dC1(Lc-i);
% Flux at 3 points
        F0=G2(i-1,j)*n1(i-1,j);
        F1=G2(i,j)*n1(i,j);
        F2=G2(i+1,j)*n1(i+1,j);
% mean growth function
    if i==2
    F(i-1,j)=F0;
    end
    
%     if not(n1(i+1,j)==n1(i,j))
%         G3(i,j)=v*(F2-F1)/(n1(i+1,j)-n1(i,j));
%     else
%         G3(i,j)=v*G2(i,j);
%     end
    k=i-sign(G3(i,j));
    r(i)=(n1(k,j)-n1(k-1,j))/(n1(i+1,j)-n1(i,j));
    PHI(i,j)=max(0,min(1,r(i)));%max(0,max(min(2*r(i),1),min(r(i),2)));%(abs(r(i))+r(i))/(1+abs(r(i)));%
% LWF Method with Flux limiter
    if G3(i,j)>0
        F(i,j)=F1+0.5*(1/v-G3(i,j))*(F2-F1)*PHI(i,j);
    elseif G3(i,j)<0
        F(i,j)=F2-0.5*(1/v+G3(i,j))*(F2-F1)*PHI(i,j);
    else
        F(i,j)=0;%(F1+F2-G3(i,j)*(F2-F1)*PHI(i,j))/2;
    end
%     if not(G2(i+1,j)==0)
        n1(i,j+1)=n1(i,j)-v*(F(i,j)-F(i-1,j));  
%     end
    end
end
%% Match the c3 values and make new nA.
figure
% hold on
for j=1:10:Lt
%     C5=sort(c5(1:M,k),'descend');
    plot(C1(1:Lc),n1(1:Lc,j));
    pause(0.05);
end
for k=1:4
  tvl=tmax*[0.2 0.5 0.8 1];
  len_t(k)=length(0:d_t:tvl(k));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create figure
figure1 = figure;

% Create axes
axes('Parent',figure1,'YTickLabel','','YTick',zeros(1,0),...
    'YColor',[0.8 0.8 0.8],...
    'XTickLabel','',...
    'XTick',zeros(1,0),...
    'XColor',[0.8 0.8 0.8],...
    'Position',[0.099 0.08269 0.8595 0.8145],...
    'CLim',[0 1]);

% Create title
title(['Population Density of T-cells for CD3 Protein',sprintf('\n'),'Method of Characteristics'],...
    'FontSize',12);

% Create xlabel
xlabel('State variable "c_1"','FontSize',16,'Color',[0 0 0]);

% Create ylabel
ylabel('Population Density','FontSize',16,'Color',[0 0 0]);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=1;
j=25;
k=0;
m=length(C1(1:Lc));%%In concentration variable, c5, values are repeating after m;
PBE_Figure(C1(i:j:m+k),n1(i:j:m+k,len_t(1)),n1(i:j:m+k,len_t(2)),n1(i:j:m+k,len_t(3)),n1(i:j:m+k,len_t(4)),len_t);
toc