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

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Signal = require(script.Parent.Signal)

local Noop = function() end

local BaseMotor = {}
BaseMotor.ClassName = "BaseMotor"
BaseMotor.__index = BaseMotor

function BaseMotor:OnStep(Function)
	return self._OnStep:Connect(Function)
end

function BaseMotor:OnComplete(Function)
	return self._OnComplete:Connect(Function)
end

function BaseMotor:UpdateComponent(ApplyFunction)
	local Component = self._Component

	return self._OnStep:Connect(function(Value)
		ApplyFunction(Value, Component)
		Component.QueueRedraw()
	end)
end

local RenderStepTwiceEvent = {}
RenderStepTwiceEvent.Connected = true
RenderStepTwiceEvent.__index = RenderStepTwiceEvent

function RenderStepTwiceEvent:Disconnect()
	if self.Connected then
		self.Connected = false
		RunService:UnbindFromRenderStep(self._Guid0)
		RunService:UnbindFromRenderStep(self._Guid1)
	end
end

local function GetHeartbeat()
	return RunService.Heartbeat
end

local function GetRenderStep()
	return RunService.RenderStepped
end

local RenderStepTwice = {}
function RenderStepTwice:Connect(Function)
	local Guid0 = HttpService:GenerateGUID(false)
	local Guid1 = Guid0 .. "_1"
	RunService:BindToRenderStep(Guid0, Enum.RenderPriority.Last.Value + 1, Function)
	RunService:BindToRenderStep(Guid1, Enum.RenderPriority.Last.Value + 2, Function)

	return setmetatable({
		_Guid0 = Guid0;
		_Guid1 = Guid1;
	}, RenderStepTwiceEvent)
end

local function GetRenderStepTwice()
	return RenderStepTwice
end

local function GetStepped()
	return RunService.Stepped
end

local EVENTS_MAP = {
	Heartbeat = GetHeartbeat;
	RenderStep = GetRenderStep;
	RenderStepTwice = GetRenderStepTwice;
	Stepped = GetStepped;
}

function BaseMotor:Start()
	if not self._Connection then
		local Component = self._Component
		local GetEvent = EVENTS_MAP[Component.RedrawBinding.Value] or GetHeartbeat

		self._Connection = GetEvent():Connect(function(DeltaTime)
			self:Step(DeltaTime)
		end)
	end

	return self
end

function BaseMotor:Stop()
	if self._Connection then
		self._Connection:Disconnect()
		self._Connection = nil
	end

	return self
end

function BaseMotor:Destroy()
	self:Stop()
	table.clear(self)
	setmetatable(self, nil)
end

BaseMotor.Step = Noop
BaseMotor.GetValue = Noop
BaseMotor.SetGoal = Noop

function BaseMotor:__tostring()
	return "Motor"
end

function BaseMotor.new(Component)
	return setmetatable({
		_Component = Component;
		_Connection = nil;
		_OnComplete = Signal.new();
		_OnStep = Signal.new();
	}, BaseMotor)
end

return BaseMotor
