local TargetValueIndex = newproxy(false)

local Instant = {}
Instant.ClassName = "Instant"
Instant.__index = Instant

function Instant:Step()
	return {
		Complete = true;
		Value = self[TargetValueIndex];
	}
end

function Instant:__tostring()
	return "Instant"
end

function Instant.new(TargetValue)
	return setmetatable({
		[TargetValueIndex] = TargetValue;
	}, Instant)
end

export type Instant = typeof(Instant.new(1))
return Instant
