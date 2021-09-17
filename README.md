# HeliumAnimator

Based on [Flipper](https://github.com/Reselim/Flipper).

## Differences from Flipper

- Added the Utility library for some motor related functions.
- Added the `ImpulseSpring` library for making impulsable springs.

## Usage

```Lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Helium = require(ReplicatedStorage.Vendor.Helium)
local HeliumAnimator = require(ReplicatedStorage.Vendor.HeliumAnimator)

local AnimatorComponent = Helium.Component.Extend("AnimatorComponent")

local BASE_SIZE = UDim2.fromOffset(100, 100)
local GOAL_SIZE = UDim2.fromOffset(80, 80)

function AnimatorComponent:Constructor(Parent: Instance)
	self.Alpha = 0
	self.Motor = self.Janitor:Add(HeliumAnimator.SingleMotor.new(self, 0), "Destroy")

	self.Janitor:Add(self.Motor:UpdateComponent(function(Value: number)
		self.Alpha = Value
	end), "Disconnect")

	local TextButton: TextButton = self.Janitor:Add(Instance.new("TextButton"), "Destroy")
	TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
	TextButton.Position = UDim2.fromScale(0.5, 0.5)
	TextButton.Size = BASE_SIZE
	TextButton.Parent = Parent

	self.Janitor:Add(TextButton.InputBegan:Connect(function(InputObject: InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Motor:SetGoal(HeliumAnimator.Spring.new(1, {
				DampingRatio = 1;
				Frequency = 5;
			}))
		end
	end), "Disconnect")

	self.Janitor:Add(TextButton.InputEnded:Connect(function(InputObject: InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Motor:SetGoal(HeliumAnimator.Spring.new(0, {
				DampingRatio = 0.75;
				Frequency = 4;
			}))
		end
	end), "Disconnect")

	self.Gui = TextButton
end

AnimatorComponent.RedrawBinding = Helium.RedrawBinding.Heartbeat
function AnimatorComponent:Redraw()
	self.Gui.Size = BASE_SIZE:Lerp(GOAL_SIZE, self.Alpha)
end

return AnimatorComponent

```
