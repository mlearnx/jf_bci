function [cSp]=est2corr(Y,Yest,centYest)
% correlation score measure of similarity of Y and it's estimate
%
%  [cSp]=est2corr(Y,Yest)
%
% Input
%  Y    - [N x nSp] target to fit with N examples
%  Yest - [nSp x N] estimate of the target with N examples
%        OR
%         [N x nSp]
% Output
%  c    - [float] correlation between Y and Yest
%  cSp  - [nSp x 1] correlation for each sub-problem independently
%
if(nargin<3 || isempty(centYest) ) centYest=false; end; %centYest=true; end;
Y     = reshape(Y,[],size(Y,ndims(Y))); % [ N x nSp ]
if( size(Yest,1)~=size(Y,1) )
   if (size(Yest(:,:),2)==size(Y,2) ) Yest=Yest(:,:); % Yest=[nSp x N]
   elseif (size(Yest,1)==size(Y,2) )  Yest=Yest(:,:)';% Yest=[N x nSp] -> reshape to [N x nSp] 
   elseif (numel(Y)==size(Yest,1) )   Y   =Y(:);      % Y=[n-d x 1] -> [ N x 1 ]
   else warning('dv and Y dont seem compatiable');
   end
end
exInd = isnan(Y) | Y==0;% excluded points
Y(exInd(:))=0; Yest(exInd(:))=0; % ensure exclued points don't influence correlation compuation
% ensure is 0-mean, so it's a 'real' correlation
muY=sum(Y,1)./sum(~exInd,1); 
Y=repop(Y,'-',muY); % don't count fitting the bias as a good fit
if( centYest ) muY=sum(Yest,1)./sum(~exInd,1); end; % make-robust to bias shifts
Yest=repop(Yest,'-',muY); 
Y(exInd(:))=0; Yest(exInd(:))=0;
% Compute correlation on per-sub-problem basis
cSp   = sum(Y(:,:).*Yest(:,:),1);
cSp   = cSp./sqrt(sum(Y(:,:).*Y(:,:),1))./sqrt(sum(Yest(:,:).*Yest(:,:),1));
%c     = mean(cSp);
%c     = corr(Y(~exInd(:)),Yest(~exInd(:)));
return;
%----------------------------------------------------------------------------
function testCase()
X = cumsum(randn(10,100,200));
A = mkSig(size(X,1),'exp',1); % strongest on 1st channel
Y = tprod(A,[-1],X,[-1 2 3]);
est2corr(Y(:),X(1,:,:))
