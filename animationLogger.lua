local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AnimationCopierGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 400)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    Frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Text = "Animation Copier"
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Frame

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -20, 1, -70)
    ScrollingFrame.Position = UDim2.new(0, 10, 0, 40)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.ScrollBarThickness = 8
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.Parent = Frame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ScrollingFrame

    local CopyAllButton = Instance.new("TextButton")
    CopyAllButton.Size = UDim2.new(0, 100, 0, 30)
    CopyAllButton.Position = UDim2.new(0.25, -50, 1, -35)
    CopyAllButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    CopyAllButton.TextColor3 = Color3.new(1, 1, 1)
    CopyAllButton.Text = "Copy All"
    CopyAllButton.TextSize = 14
    CopyAllButton.Font = Enum.Font.SourceSansBold
    CopyAllButton.Parent = Frame

    local ClearButton = Instance.new("TextButton")
    ClearButton.Size = UDim2.new(0, 100, 0, 30)
    ClearButton.Position = UDim2.new(0.75, -50, 1, -35)
    ClearButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    ClearButton.TextColor3 = Color3.new(1, 1, 1)
    ClearButton.Text = "Clear"
    ClearButton.TextSize = 14
    ClearButton.Font = Enum.Font.SourceSansBold
    ClearButton.Parent = Frame

    return ScreenGui, Frame, ScrollingFrame, CopyAllButton, ClearButton
end

local ScreenGui, Frame, ScrollingFrame, CopyAllButton, ClearButton = createGUI()

local loggedAnimations = {}

local function getAnimationName(animationId)
    local success, result = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(tonumber(animationId:match("%d+")))
    end)
    if success and result and result.Name then
        return result.Name
    else
        return "Unknown Animation"
    end
end

local function logAnimation(animationId)
    if not table.find(loggedAnimations, animationId) then
        table.insert(loggedAnimations, animationId)
        
        local animationName = getAnimationName(animationId)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 30)
        button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Text = animationName .. " (" .. animationId .. ")"
        button.TextSize = 14
        button.Font = Enum.Font.SourceSans
        button.Parent = ScrollingFrame
        
        button.MouseButton1Click:Connect(function()
            setclipboard(animationId)
        end)
    end
end

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.AnimationPlayed:Connect(function(animTrack)
        local animationId = animTrack.Animation.AnimationId
        logAnimation(animationId)
    end)
end

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

CopyAllButton.MouseButton1Click:Connect(function()
    local allAnimations = table.concat(loggedAnimations, "\n")
    setclipboard(allAnimations)
end)

ClearButton.MouseButton1Click:Connect(function()
    loggedAnimations = {}
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
end)

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
