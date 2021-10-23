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

local Linear = {}
Linear.ClassName = "Linear"
Linear.__index = Linear

export type IOptions = {Velocity: number?}

function Linear:Step(State, DeltaTime: number)
	local Position = State.Value
	local Velocity = self._Velocity
	local Goal = self._TargetValue

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
		_TargetValue = TargetValue;
		_Velocity = Options.Velocity or 1;
	}, Linear)
end

export type Linear = typeof(Linear.new(1))
return Linear
