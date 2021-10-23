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

local EPS = 0.0001
local POSITION_THRESHOLD = 0.001
local VELOCITY_THRESHOLD = 0.001

local Spring = {}
Spring.ClassName = "Spring"
Spring.__index = Spring

export type IOptions = {
	DampingRatio: number?,
	Frequency: number?,
}

function Spring:Step(State, DeltaTime)
	-- Copyright 2018 Parker Stebbins (parker@fractality.io)
	-- github.com/Fraktality/Spring
	-- Distributed under the MIT license

	local DampingRatio = self._DampingRatio
	local Frequency = self._Frequency * 2 * math.pi
	local Goal = self._TargetValue
	local Position0 = State.Value
	local Velocity0 = State.Velocity or 0

	local Offset = Position0 - Goal
	local Decay = math.exp(-DampingRatio * Frequency * DeltaTime)

	local Position1, Velocity1

	if DampingRatio == 1 then -- Critically damped
		Position1 = (Offset * (1 + Frequency * DeltaTime) + Velocity0 * DeltaTime) * Decay + Goal
		Velocity1 = (Velocity0 * (1 - Frequency * DeltaTime) - Offset * (Frequency * Frequency * DeltaTime)) * Decay
	elseif DampingRatio < 1 then -- Underdamped
		local C = math.sqrt(1 - DampingRatio * DampingRatio)

		local I = math.cos(Frequency * C * DeltaTime)
		local J = math.sin(Frequency * C * DeltaTime)

		-- Damping ratios approaching 1 can cause division by small numbers.
		-- To fix that, group terms around z=j/c and find an approximation for z.
		-- Start with the definition of z:
		--    z = sin(dt*f*c)/c
		-- Substitute a=dt*f:
		--    z = sin(a*c)/c
		-- Take the Maclaurin expansion of z with respect to c:
		--    z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)
		--    z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120
		-- Rewrite in Horner form:
		--    z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6

		local Z
		if C > EPS then
			Z = J / C
		else
			local A = DeltaTime * Frequency
			Z = A + ((A * A) * (C * C) * (C * C) / 20 - C * C) * (A * A * A) / 6
		end

		-- Frequencies approaching 0 present a similar problem.
		-- We want an approximation for y as f approaches 0, where:
		--    y = sin(dt*f*c)/(f*c)
		-- Substitute b=dt*c:
		--    y = sin(b*c)/b
		-- Now reapply the process from z.

		local Y
		if Frequency * C > EPS then
			Y = J / (Frequency * C)
		else
			local B = Frequency * C
			Y = DeltaTime + ((DeltaTime * DeltaTime) * (B * B) * (B * B) / 20 - B * B) * (DeltaTime * DeltaTime * DeltaTime) / 6
		end

		Position1 = (Offset * (I + DampingRatio * Z) + Velocity0 * Y) * Decay + Goal
		Velocity1 = (Velocity0 * (I - Z * DampingRatio) - Offset * (Z * Frequency)) * Decay
	else -- Overdamped
		local C = math.sqrt(DampingRatio * DampingRatio - 1)

		local R1 = -Frequency * (DampingRatio - C)
		local R2 = -Frequency * (DampingRatio + C)

		local CO2 = (Velocity0 - Offset * R1) / (2 * Frequency * C)
		local CO1 = Offset - CO2

		local E1 = CO1 * math.exp(R1 * DeltaTime)
		local E2 = CO2 * math.exp(R2 * DeltaTime)

		Position1 = E1 + E2 + Goal
		Velocity1 = E1 * R1 + E2 * R2
	end

	local Complete = math.abs(Velocity1) < VELOCITY_THRESHOLD and math.abs(Position1 - Goal) < POSITION_THRESHOLD

	return {
		Complete = Complete;
		Value = Complete and Goal or Position1;
		Velocity = Velocity1;
	}
end

function Spring:__tostring()
	return "Spring"
end

function Spring.new(TargetValue, PossibleOptions: IOptions?)
	assert(TargetValue, "Missing argument #1: targetValue")
	local Options = PossibleOptions or {}

	return setmetatable({
		_DampingRatio = Options.DampingRatio or 1;
		_Frequency = Options.Frequency or 4;
		_TargetValue = TargetValue;
	}, Spring)
end

export type Spring = typeof(Spring.new(1, {}))
return Spring
