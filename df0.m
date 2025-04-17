function grad=df0(x1,x2)
%This function returns the gradient of the objective function in Problem
%1
grad(1)= 2.0.*x1+3.0.*x2+2.0;
grad(2) = 3.0.*x1+18.0.*x2 -5.0;
end
