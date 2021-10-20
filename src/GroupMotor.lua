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
local IsMotor = require(script.Parent.IsMotor)
local Shared = require(script.Parent.Shared)
local SingleMotor = require(script.Parent.SingleMotor)

local CompleteIndex = newproxy(false)
local MotorsIndex = newproxy(false)
local OnCompleteIndex = Shared.OnCompleteIndex
local OnStepIndex = Shared.OnStepIndex
local UseImplicitConnectionsIndex = newproxy(false)

local GroupMotor = setmetatable({}, BaseMotor)
GroupMotor.ClassName = "GroupMotor"
GroupMotor.__index = GroupMotor

local function ToMotor(Component, Value)
	if IsMotor(Value) then
		return Value
	end

	local ValueType = typeof(Value)

	if ValueType == "number" then
		return SingleMotor.new(Component, Value, false)
	elseif ValueType == "table" then
		return GroupMotor.new(Component, Value, false)
	end

	error(string.format("Unable to convert %q to motor; type %s is unsupported", Value, ValueType), 2)
end

function GroupMotor:Step(DeltaTime)
	if self[CompleteIndex] then
		return true
	end

	local AllMotorsComplete = true

	for _, Motor in next, self[MotorsIndex] do
		local Complete = Motor:Step(DeltaTime)
		if not Complete then
			-- If any of the sub-motors are incomplete, the group motor will not be complete either
			AllMotorsComplete = false
		end
	end

	self[OnStepIndex]:Fire(self:GetValue())

	if AllMotorsComplete then
		if self[UseImplicitConnectionsIndex] then
			self:Stop()
		end

		self[CompleteIndex] = true
		self[OnCompleteIndex]:Fire()
	end

	return AllMotorsComplete
end

function GroupMotor:SetGoal(Goals)
	self[CompleteIndex] = false

	for Key, Goal in next, Goals do
		local Motor = self[MotorsIndex][Key]
		if not Motor then
			error(string.format("Unknown motor for key %s", tostring(Key)))
		end

		Motor:SetGoal(Goal)
	end

	if self[UseImplicitConnectionsIndex] then
		self:Start()
	end

	return self
end

function GroupMotor:GetValue()
	local Values = {}

	for Key, Motor in next, self[MotorsIndex] do
		Values[Key] = Motor:GetValue()
	end

	return Values
end

function GroupMotor:__tostring()
	return "Motor(Group)"
end

function GroupMotor.new(Component, InitialValues, UseImplicitConnections)
	assert(InitialValues, "Missing argument #1: initialValues")
	assert(type(InitialValues) == "table", "initialValues must be a table!")

	local self = setmetatable(BaseMotor.new(Component), GroupMotor)

	if UseImplicitConnections ~= nil then
		self[UseImplicitConnectionsIndex] = UseImplicitConnections
	else
		self[UseImplicitConnectionsIndex] = true
	end

	self[CompleteIndex] = true
	self[MotorsIndex] = {}

	for Key, Value in next, InitialValues do
		self[MotorsIndex][Key] = ToMotor(Component, Value)
	end

	return self
end

return GroupMotor
