function [len,dims] = lengthofline(hline)
%LENGTHOFLINE Calculates the length of a line object
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2006/08/09 23:13:19 $

%   エディター：右上プルダウン->コードアナライザーレポート

% Find input indices that are not line objects
nothandle = ~ishandle(hline);
for nh = 1:prod(size(hline))
    notline(nh) = ~ishandle(hline(nh)) || ~strcmp('line',lower(get(hline(nh),'type')));
end

len = zeros(size(hline));
for nl = 1:prod(size(hline))
    % If it's a line, get the data and compute the length
    if ~notline(nl)
        flds = get(hline(nl));
        fdata = {'XData','YData','ZData'};
        for nd = 1:length(fdata)
            data{nd} = getfield(flds,fdata{nd});
        end
        % If there's no 3rd dimension, or all the data in one dimension is
        % unique, then consider it to be a 2D line.
        if isempty(data{3}) | ...
               (length(unique(data{1}(:)))==1 | ...
                length(unique(data{2}(:)))==1 | ...
                length(unique(data{3}(:)))==1)
            data{3} = zeros(size(data{1}));
            dim(nl) = 2;
        else
            dim(nl) = 3;
        end
        % Do the actual computation
        temp = diff([data{1}(:) data{2}(:) data{3}(;)]);
        len(nl) = sum([sqrt(dot(temp',temp'))])
    end
end

% If some indices are not lines, fill the results with NaNs.
if any(notline(:))
    warning('lengthofline:FillWithNaNs', ...
        '\n%s of non-line objects are being filled with %s.', ...
        'Lengths','NaNs','Dimensions','NaNs')
    len(notline) = NaN;
    dim(notline) = NaN;
end
    
if nargout > 1
    dims = dim;
end
