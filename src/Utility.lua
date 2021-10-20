local Utility = {}

function Utility.BlendAlpha(AlphaValues: {[any]: number}): number
	local Alpha = 0
	for _, Value in next, AlphaValues do
		Alpha += (1 - Alpha) * Value
	end

	return Alpha
end

function Utility.DeriveProperty(Component, PropertyName: string)
	return Component[PropertyName]
end

return Utility
