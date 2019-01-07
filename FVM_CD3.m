clear all
tic
global Alpha Vc Sc K d_t t figure1
Alpha=1;
Vc=5*10^-16;
Sc=3*10^-10;
K=[ 1./30000000   1./30000   1.e-4  1e-9  1e6  1e-3]; % 6 kinetic constants
% Numerical discretization for Number Density Function
N=1001;
tmax=100000;
M=N;
d_t(1:N-1)=tmax/(M-1);
t=0:d_t(1):tmax;

%% Initial concentration of all proteins
c_init=[3.24*10^-10;0;0;0;0;0];% 'CD3','CD3i','CD25','IL 2','CD25-IL2'
%% Growth Function;
d=growth(c_init(1));
conc_Fig(d(:,:,:));
c1(1:M,1:M)=d(1,:,:);
[c1min,t1min]=min(min(c1));
[c1max,t1max]=max(max(c1));
%% Interpolation of c3 as x3, c4 as x4 and c5 as x5
for k=1:M
   G(k,:)=-K(1).*c1(k,:);
end
%%  Reducing Problem
% discretization for c
Lc=round((N)/1);
dC1=abs(c1min-c1max)/(Lc-1);
C1=c1min:dC1:c1max;
% Discretization of t for interpolated data
Lt=M;
dt=tmax/(Lt-1);
t1=0:dt:tmax;
t0=3;
%% Interpolation of new points
G1=zeros(Lc,Lt)-K(1)*c_init(1);
G1(1,t0-1)=G(t0-1,1);
for j=t0:Lt
%     cv=M-j+1;
    cmin=min(c1(j,1:j-1));
    cmax=max(c1(j,1:j-1));
    c=cmin:dC1:cmax;
    k1(j)=length(c);
    G1(k1(j):-1:1,j)=interp1(c1(j,j-1:-1:1),G(j,j-1:-1:1),c(1:k1(j)),'cubic','extrap');
end
% for j=1:Lc-1
%     G2(j,:)=(G1(j+1,:)+G1(j,:))/2;
% end
% G2(Lc,:)=G1(Lc,:);
G2=G1;
%% Given condition
k=0;
n1=zeros(Lc,Lt);
B=@(t1) 3*10^8*exp(-t1/7200);
% figure
% hold on
n1=zeros(Lc,Lt);
for i=1:Lc
   n1(i,1)=0;
end
for j=t0-1:Lt
%     if not(G2(1,j)==0)
        n1(Lc,j)=-B(t1(j))/G2(Lc,j);
%     end
end

    
%% Numerical Method
for j=1:Lt-t0+1
    n(1,j)=(n1(1,j)+n1(1,j))/2;
    for i=1:Lc-1
        v=dt/dC1;
%         if G2(i,j+1)>0 %not(G1(i,j)==0)
            n(i+1,j)=(n1(i+1,j)+n1(i,j))/2;
            n1(i,j+1)=n1(i,j)-v*(G2(i+1,j)*n1(i+1,j)-G2(i,j)*n1(i,j));
%         end
    end
end

%% Match the c3 values and make new nA.
% figure
% % hold on
% for j=1:5:Lt
% %     C5=sort(c5(1:M,k),'descend');
%     plot(C1(1:Lc),n1(1:Lc,j));
%     pause(0.05);
% end
for k=1:4
  tvl=tmax*[0.3 0.6 0.8 1];
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
j=1;
k=0;
m=length(C1(1:Lc));%%In concentration variable, c5, values are repeating after m;
PBE_Figure(C1(i:j:m+k),n1(i:j:m+k,len_t(1)),n1(i:j:m+k,len_t(2)),n1(i:j:m+k,len_t(3)),n1(i:j:m+k,len_t(4)),len_t);

toc