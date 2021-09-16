local BaseMotor = require(script.Parent.BaseMotor)
local Shared = require(script.Parent.Shared)

local GoalIndex = newproxy(false)
local OnCompleteIndex = Shared.OnCompleteIndex
local OnStepIndex = Shared.OnStepIndex
local StateIndex = newproxy(false)
local UseImplicitConnectionsIndex = newproxy(false)

local SingleMotor = setmetatable({}, BaseMotor)
SingleMotor.ClassName = "SingleMotor"
SingleMotor.__index = SingleMotor

function SingleMotor:Step(DeltaTime)
	local State = self[StateIndex]
	if State.Complete then
		return true
	end

	local NewState = self[GoalIndex]:Step(State, DeltaTime)

	self[StateIndex] = NewState
	self[OnStepIndex]:Fire(NewState.Value)

	if NewState.Complete then
		if self[UseImplicitConnectionsIndex] then
			self:Stop()
		end

		self[OnCompleteIndex]:Fire()
	end

	return NewState.Complete
end

function SingleMotor:GetValue()
	return self[StateIndex].Value
end

function SingleMotor:SetGoal(Goal)
	self[StateIndex].Complete = false
	self[GoalIndex] = Goal

	if self[UseImplicitConnectionsIndex] then
		self:Start()
	end

	return self
end

function SingleMotor:__tostring()
	return "Motor(Single)"
end

function SingleMotor.new(Component, InitialValue, UseImplicitConnections)
	assert(InitialValue, "Missing argument #1: initialValue")
	assert(type(InitialValue) == "number", "initialValue must be a number!")

	local self = setmetatable(BaseMotor.new(Component), SingleMotor)

	if UseImplicitConnections ~= nil then
		self[UseImplicitConnectionsIndex] = UseImplicitConnections
	else
		self[UseImplicitConnectionsIndex] = true
	end

	self[GoalIndex] = nil
	self[StateIndex] = {
		Complete = true;
		Value = InitialValue;
	}

	return self
end

return SingleMotor
