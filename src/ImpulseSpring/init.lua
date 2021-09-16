local Spring = require(script.Spring)
local POSITION_THRESHOLD = 0.001
local VELOCITY_THRESHOLD = 0.001

local ImpulseSpring = {}
ImpulseSpring.ClassName = "ImpulseSpring"
ImpulseSpring.__index = ImpulseSpring

local SpringIndex = newproxy(false)

export type IOptions = {
	Damper: number,
	Position: number,
	Speed: number,
	Velocity: number,
}

function ImpulseSpring:Step(State, DeltaTime: number)
	local LocalSpring = self[SpringIndex]:Impulse(State.velocity or 0, DeltaTime)

	local Goal = LocalSpring:GetTarget(DeltaTime)
	local Velocity1 = LocalSpring:GetVelocity(DeltaTime)
	local Position1 = LocalSpring:GetPosition(DeltaTime)
	local Complete = math.abs(Velocity1) < VELOCITY_THRESHOLD and math.abs(Position1 - Goal) < POSITION_THRESHOLD

	return {
		Complete = Complete;
		Value = Complete and Goal or Position1;
		Velocity = Velocity1;
	}
end

function ImpulseSpring:__tostring()
	return "ImpulseSpring"
end

function ImpulseSpring.new(TargetValue, PossibleOptions: IOptions?)
	assert(TargetValue, "Missing argument #1: targetValue")
	local Options = PossibleOptions or {}

	-- stylua: ignore
	return setmetatable({
		[SpringIndex] = Spring.new(TargetValue)
			:SetTarget(TargetValue, 0)
			:SetDamper(Options.Damper or 1, 0)
			:SetPosition(TargetValue, 0)
			:SetSpeed(Options.Speed or 1, 0)
			:SetVelocity((Options.Velocity or 0) * 0, 0);
	}, ImpulseSpring)
end

export type ImpulseSpring = typeof(ImpulseSpring.new(1))
return ImpulseSpring
