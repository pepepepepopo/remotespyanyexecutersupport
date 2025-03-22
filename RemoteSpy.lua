-- Create a ScreenGui to hold the frame
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create a frame to display the RemoteEvent information
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.5, 0)
frame.Position = UDim2.new(0.7, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Create a header for the frame
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 20)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
header.BorderSizePixel = 0
header.Parent = frame

-- Create a TextLabel for the header title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Remote Spy"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Create a close button
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

-- Create a ScrollingFrame to hold the list of RemoteEvents
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, -20) -- Adjusted to account for header
scrollingFrame.Position = UDim2.new(0, 0, 0, 20)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.Parent = frame

-- Create a UIListLayout for the ScrollingFrame
local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollingFrame

-- Create a TextLabel to display the RemoteEvent information
local templateLabel = Instance.new("TextLabel")
templateLabel.Size = UDim2.new(1, 0, 0, 20)
templateLabel.TextColor3 = Color3.new(1, 1, 1)
templateLabel.BackgroundTransparency = 1
templateLabel.TextXAlignment = Enum.TextXAlignment.Left
templateLabel.Text = "RemoteEvent: Args"
templateLabel.Visible = false
templateLabel.Parent = scrollingFrame

-- Table to store RemoteEvent data
local remoteEventData = {}

-- Function to update the UI with RemoteEvent data
local function updateUI()
    -- Clear the existing UI
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    -- Add new entries for each RemoteEvent
    for name, args in pairs(remoteEventData) do
        local newLabel = templateLabel:Clone()
        newLabel.Text = name .. ": " .. tostring(args)
        newLabel.Visible = true
        newLabel.Parent = scrollingFrame
    end

    -- Adjust the CanvasSize of the ScrollingFrame
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- Function to monitor RemoteEvents
local function monitorRemoteEvents()
    while true do
        -- Check for RemoteEvents in ReplicatedStorage
        local remoteEvents = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
        if remoteEvents then
            for _, remoteEvent in pairs(remoteEvents:GetChildren()) do
                if remoteEvent:IsA("RemoteEvent") then
                    -- Connect to the RemoteEvent to capture its data
                    remoteEvent.OnClientEvent:Connect(function(...)
                        remoteEventData[remoteEvent.Name] = {...}
                        updateUI() -- Update the UI when a new event is fired
                    end)
                end
            end
        end

        -- Wait for 0.25 seconds before checking again
        wait(0.25)
    end
end

-- Start monitoring RemoteEvents
monitorRemoteEvents()
