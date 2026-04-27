function bound_value(minval,val,maxval)
	if (val<minval) then return minval end
	if (val>maxval) then return maxval end
	return val
end

