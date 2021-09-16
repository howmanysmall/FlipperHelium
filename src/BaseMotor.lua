local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Shared = require(script.Parent.Shared)
local Signal = require(script.Parent.Signal)

local Noop = function() end

local ConnectionIndex = newproxy(false)
local ComponentIndex = newproxy(false)
local OnCompleteIndex = Shared.OnCompleteIndex
local OnStepIndex = Shared.OnStepIndex

local BaseMotor = {}
BaseMotor.ClassName = "BaseMotor"
BaseMotor.__index = BaseMotor

function BaseMotor:OnStep(Function)
	return self[OnStepIndex]:Connect(Function)
end

function BaseMotor:OnComplete(Function)
	return self[OnCompleteIndex]:Connect(Function)
end

function BaseMotor:UpdateComponent(ApplyFunction)
	local Component = self[ComponentIndex]
	local QueueRedraw = Component.QueueRedraw

	return self[OnStepIndex]:Connect(function(Value)
		ApplyFunction(Value, Component)
		QueueRedraw()
	end)
end

local Guid0Index = newproxy(false)
local Guid1Index = newproxy(false)

local RenderStepTwiceEvent = {}
RenderStepTwiceEvent.Connected = true
RenderStepTwiceEvent.__index = RenderStepTwiceEvent

function RenderStepTwiceEvent:Disconnect()
	if self.Connected then
		self.Connected = false
		RunService:UnbindFromRenderStep(self[Guid0Index])
		RunService:UnbindFromRenderStep(self[Guid1Index])
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
		[Guid0Index] = Guid0;
		[Guid1Index] = Guid1;
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
	if not self[ConnectionIndex] then
		local Component = self[ComponentIndex]
		local GetEvent = EVENTS_MAP[Component.RedrawBinding.Value] or GetHeartbeat

		self[ConnectionIndex] = GetEvent():Connect(function(DeltaTime)
			self:Step(DeltaTime)
		end)
	end

	return self
end

function BaseMotor:Stop()
	if self[ConnectionIndex] then
		self[ConnectionIndex]:Disconnect()
		self[ConnectionIndex] = nil
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
		[ComponentIndex] = Component;
		[ConnectionIndex] = nil;
		[OnCompleteIndex] = Signal.new();
		[OnStepIndex] = Signal.new();
	}, BaseMotor)
end

return BaseMotor