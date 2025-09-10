function [doct,Ht,St,Bt] = doct_gpu_monfort(imageT,fps)
%Author Tual MONFORT
%imageT is a 2D space image over time, e.g. size(imageT)= x y t
%fps is the number of frames per second
%doct is the HSB rendering
%Ht is the raw <PSD>
%St is the raw StD(PSD)
%Bt is <|Delta_I(t)|>
  
  s = size(imageT);
  imageT = single(squeeze(imageT));
  imageT=(imageT./(mean(imageT,[1 2])))-1;

%<|Delta_I|>
  B=mean(abs(diff(imageT,1,3)),3);

%PSD
  imagefreq = abs(fft(gpuArray(imageT),[],3));
  imagefreq = imagefreq(:,:,2:s(3)/2+1);
  N=reshape(repmat(sum(imagefreq,3),1,floor(s(3)/2)),s(1),s(2),floor(s(3)/2));
  imagefreq = imagefreq./N;
  clear N
  freq = reshape(repelem(gpuArray.linspace(0,fps,floor(s(3)/2)),s(1)*s(2)),s(1),s(2),floor(s(3)/2));

%S
  S = gather(sqrt(dot(imagefreq,freq.^2,3)-dot(imagefreq,freq,3).^2));

%H
  H = gather(dot(imagefreq,freq,3));

% HSB rendering
  Ht=double(H);
  St=double(S);
  Bt=double(B);


  Bt(Bt>prctile(Bt(:),99.9))=prctile(Bt(:),99.9);
  Bt = rescale(Bt,0,1);

  St = rescale(St, 0, 0.95);
  smin=prctile(St(:),5);
  smax=prctile(St(:),100);
  St(St>smax) = smax;
  St(St<smin) = smin;
  St = rescale(-St, 0, 0.95);


  Ht = imgaussfilt(rescale(Ht,0,1),4);
  Ht = rescale(Ht,0,0.66);
  hmin=prctile(Ht(Bt>0.5),0.1);
  hmax=prctile(Ht(Bt>0.5),99.9);
  Ht(Ht<hmin) = hmin;
  Ht(Ht>hmax) = hmax;
  Ht = rescale(-Ht,0,0.66);


  doct_hsv(:,:,1) = (Ht);
  doct_hsv(:,:,2) = (St);
  doct_hsv(:,:,3) = (Bt);
  doct = hsv2rgb(doct_hsv);


end