local TargetValueIndex = newproxy(false)
local VelocityIndex = newproxy(false)

local Linear = {}
Linear.ClassName = "Linear"
Linear.__index = Linear

export type IOptions = {Velocity: number?}

function Linear:Step(State, DeltaTime: number)
	local Position = State.Value
	local Velocity = self[VelocityIndex]
	local Goal = self[TargetValueIndex]

	local DeltaPosition = DeltaTime * Velocity
	local Complete = DeltaPosition >= math.abs(Goal - Position)
	Position += DeltaPosition * (Goal > Position and 1 or -1)

	if Complete then
		Position = Goal
		Velocity = 0
	end

	return {
		Complete = Complete;
		Value = Position;
		Velocity = Velocity;
	}
end

function Linear:__tostring()
	return "Linear"
end

function Linear.new(TargetValue, PossibleOptions: IOptions?)
	assert(TargetValue, "Missing TargetValue.")
	local Options = PossibleOptions or {}

	return setmetatable({
		[TargetValueIndex] = TargetValue;
		[VelocityIndex] = Options.Velocity or 1;
	}, Linear)
end

export type Linear = typeof(Linear.new(1))
return Linear
