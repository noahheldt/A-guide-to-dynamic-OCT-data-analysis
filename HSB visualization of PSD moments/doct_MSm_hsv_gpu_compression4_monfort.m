function [doct,Ht,St,Bt] = doct_MSm_hsv_gpu_compression4_monfort(imageT,fps)
%Author Tual MONFORT
%This is a faster version to calculate the metrics
%In the paper (A guide to dynamic OCT data analysis), what is referred to as PSD moments visualization should actually be referred to as Magnitude spectrum moments visualization.
%The code builds up upon Jules Scholler's original script from 2020 (https://doi.org/10.1038/s41377-020-00375-8), albeit with a better optimisation for calculation on the GPU
%imageT is a 2D space image over time, e.g. size(imageT)= x y t
%fps is the number of frames per second
%doct is the HSB rendering
%Ht is the raw <PSD>
%St is the raw StD(PSD)
%Bt is <|Delta_I(t)|>
  freq_min=4;
  s = size(imageT);
  imageT = single(squeeze(imageT));
  imageT=(imageT./(mean(imageT,[1 2])))-1;
tic
%<|Delta_I|>
  B=gather(mean(abs(diff(imageT,1,3)),3));

  %Compression of 4
        imageT=gpuArray(imageT);
        imageT_C = zeros(s(1),s(2),s(3)/4,'single','gpuArray');
        for i = 1:s(3)/4
            imageT_C(:,:,i) = single(mean(imageT(:,:,(i-1)*4+1:i*4),3));
        end
        clear imageT

%Magnitude spectrum (MS)
  imagefreq = abs(fft(gpuArray(imageT_C),[],3));
  clear imageT_C

  imagefreq = imagefreq(:,:,freq_min:s(3)/8+1);
  N=reshape(repmat(sum(imagefreq,3),1,floor(s(3)/8-freq_min+2)),s(1),s(2),floor(s(3)/8-freq_min+2));
  imagefreq = imagefreq./N;
  clear N
  freq = reshape(repelem(gpuArray.linspace(0,fps/4,floor(s(3)/8)-freq_min/2),s(1)*s(2)),s(1),s(2),floor(s(3)/8-freq_min+2));


%S
  S = gather(sqrt(dot(imagefreq,freq.^2,3)-dot(imagefreq,freq,3).^2));

%H
imagefreq = imagefreq - reshape(repmat(min(imagefreq,[],3),1,s(3)/8-freq_min/2),s(1),s(2),s(3)/8-freq_min/2);
  H = gather(dot(imagefreq,freq,3));
toc
  clear imagefreq

% HSB rendering
  Ht=double(H);
  St=double(S);
  Bt=double(B);


  Bt(Bt>prctile(Bt(:),99.9))=prctile(Bt(:),99.9);
  Bt(Bt<prctile(Bt(:),0.003))=prctile(Bt(:),0.003);
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



