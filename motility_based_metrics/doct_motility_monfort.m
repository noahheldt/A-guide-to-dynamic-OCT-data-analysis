function [Al,Rr,M] = doct_motility_monfort(imageT)
%Author Tual MONFORT
%imageT is a 2D space image over time, e.g. size(imageT)= x y t
%fps is the number of frames per second
%doct is the HSB rendering
%Al is alpha
%Rr is R^2
%M is M

s = size(imageT);
imageT = single(squeeze(imageT));
imageT=(imageT./(mean(imageT,[1 2])))-1; %power fluctuation correction (optional)


%M
Ga=zeros(s(1),s(2));
for ii=1:s(3)-1
Ga=imageT(:,:,ii).*imageT(:,:,ii+1)+Ga;
end
Ga=Ga./(s(3)-1);
%
M=abs(((Ga-(mean(imageT,3).^2)).^0.5)./mean(imageT,3));

% Alpha and R^2

IM=abs(fft(imageT,[],3)).^2;
IM=IM(:,:,2:(s(3)/2)+1);
f=2:floor(s(3)/2);
IM=IM(:,:,2:end);

IMM = smooth3(IM,"box",5);


Al=zeros(s(1),s(2));
Rr=zeros(s(1),s(2));
x0 = [1 1 1]; %initialization

fitfun = fittype( @(a,b,c,x) a*(x.^-b) +c);
warning('off')
for ii=1:s(1)
    ii
    for jj=1:s(2)
      [fitted_curve,gof] = fit(squeeze(f).',squeeze(IMM(ii,jj,:)),fitfun,'lower', [0, 0, 0],"Weights",squeeze(IMM(ii,jj,:)),'StartPoint',x0);
      coeffvals = coeffvalues(fitted_curve);
      Al(ii,jj)=squeeze(coeffvals(1,2));
      Rr(ii,jj)=gof.rsquare;
    end 
end

end