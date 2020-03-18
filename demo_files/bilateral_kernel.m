function out = bilateral_kernel(im, G, norm)
    out = gpucoder.stencilKernel(@myfunc,im,size(G),'same',G,norm);
end

function out = myfunc(in1, in2, in3)
    coder.inline('always');
    coder.gpu.constantMemory(in2);
    b0 = single(0);
    b1 = single(0);
    [h,w] = size(in2);
    for n = 1:w
        for m = 1:h
            h0 = exp(-((in1(m,n) - in1(6,6))^2) * in3);
            f = h0 * in2(m,n);
            b0 = b0 + f * in1(m,n);
            b1 = b1 + f;
        end
    end
    out = b0 / b1;
end
% Copyright 2018 The MathWorks, Inc.