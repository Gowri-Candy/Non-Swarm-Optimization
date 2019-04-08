%
% Copyright (c) 2019 at github.com
% All rights reserved. Please read the "license.txt" for license terms.
%
% Developer : R.Gowri, Dr. R. Rathipriya
% Contact email - gowri.candy@gmail.com ,
% rathi_priyar@periyaruniversity.ac.in
% 

function data=LoadDataset()

    dataset=load('Thyroid');
    data.x=dataset.Inputs;
    data.t=dataset.Targets;
    
    data.nx=size(data.x,1);
    data.nt=size(data.t,1);
    data.nSample=size(data.x,2);

end