--[[
	Copyright (c) 2020 Reselim

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

-- Adapted for Helium by HowManySmall.

local BaseMotor = require(script.Parent.BaseMotor)

local SingleMotor = setmetatable({}, BaseMotor)
SingleMotor.ClassName = "SingleMotor"
SingleMotor.__index = SingleMotor

function SingleMotor:Step(DeltaTime)
	local State = self._State
	if State.Complete then
		return true
	end

	local NewState = self._Goal:Step(State, DeltaTime)

	self._State = NewState
	self._OnStep:Fire(NewState.Value)

	if NewState.Complete then
		if self._UseImplicitConnections then
			self:Stop()
		end

		self._OnComplete:Fire()
	end

	return NewState.Complete
end

function SingleMotor:GetValue()
	return self._State.Value
end

function SingleMotor:SetGoal(Goal)
	self._State.Complete = false
	self._Goal = Goal

	if self._UseImplicitConnections then
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
		self._UseImplicitConnections = UseImplicitConnections
	else
		self._UseImplicitConnections = true
	end

	self._Goal = nil
	self._State = {
		Complete = true;
		Value = InitialValue;
	}

	return self
end

return SingleMotor
