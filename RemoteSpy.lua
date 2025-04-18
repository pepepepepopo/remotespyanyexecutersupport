-- Create a ScreenGui to hold the UI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create the main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.5, 0)
frame.Position = UDim2.new(0.7, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Create the header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 20)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
header.BorderSizePixel = 0
header.Parent = frame

-- Create the title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Remote Spy"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Create the close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.2, 0, 1, 0)
closeButton.Position = UDim2.new(0.8, 0, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
closeButton.BorderSizePixel = 0
closeButton.Parent = header

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Make the header draggable
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

header.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Create a ScrollingFrame to hold the logs
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, -20) -- Adjusted to account for header
scrollingFrame.Position = UDim2.new(0, 0, 0, 20)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.Parent = frame

-- Create a UIListLayout for the ScrollingFrame
local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollingFrame

-- Create a template for the log entries
local logTemplate = Instance.new("TextLabel")
logTemplate.Size = UDim2.new(1, 0, 0, 20)
logTemplate.TextColor3 = Color3.new(1, 1, 1)
logTemplate.BackgroundTransparency = 1
logTemplate.TextXAlignment = Enum.TextXAlignment.Left
logTemplate.Text = "RemoteEvent: Args"
logTemplate.Visible = false
logTemplate.Parent = scrollingFrame

-- Function to add a log entry
local function addLog(name, args)
    local newLog = logTemplate:Clone()
    newLog.Text = name .. ": " .. tostring(args)
    newLog.Visible = true
    newLog.Parent = scrollingFrame

    -- Adjust the CanvasSize of the ScrollingFrame
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- Hook into all RemoteEvents
local function hookRemoteEvents()
    local remoteEvents = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
    if remoteEvents then
        for _, remoteEvent in pairs(remoteEvents:GetChildren()) do
            if remoteEvent:IsA("RemoteEvent") then
                remoteEvent.OnClientEvent:Connect(function(...)
                    addLog(remoteEvent.Name, {...})
                end)
            end
        end
    end
end

-- Hook into future RemoteEvents
game:GetService("ReplicatedStorage").ChildAdded:Connect(function(child)
    if child:IsA("RemoteEvent") then
        child.OnClientEvent:Connect(function(...)
            addLog(child.Name, {...})
        end)
    end
end)

-- Initial hook
hookRemoteEvents()
