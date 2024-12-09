function v = compute_var2(v0,k)
%function v = compute_var2(v0,k)
% v0 is an NxM array
% k is the width and length of the neighborhood used to compute variance
% v is the variance array
good= isfinite(v0);
bad= ~isfinite(v0);
igood=find(good);
ibad=find(bad);
v0(ibad)=0;
ct=filter2(ones(k,k),good);
meanv=filter2(ones(k,k),v0)./ct;
v0(igood)=v0(igood)-meanv(igood);

v=filter2(ones(k,k),v0.*v0)./ct;
v(ibad)=NaN;

end