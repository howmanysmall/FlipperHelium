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

local GroupMotor = require(script.GroupMotor)
local ImpulseSpring = require(script.ImpulseSpring)
local Instant = require(script.Instant)
local IsMotor = require(script.IsMotor)
local Linear = require(script.Linear)
local SingleMotor = require(script.SingleMotor)
local Spring = require(script.Spring)
local Utility = require(script.Utility)

local FlipperHelium = {}

FlipperHelium.GroupMotor = GroupMotor
FlipperHelium.ImpulseSpring = ImpulseSpring
FlipperHelium.Instant = Instant
FlipperHelium.IsMotor = IsMotor
FlipperHelium.Linear = Linear
FlipperHelium.SingleMotor = SingleMotor
FlipperHelium.Spring = Spring
FlipperHelium.Utility = Utility

return FlipperHelium
