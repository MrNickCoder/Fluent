local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local Acrylic = require(Root.Acrylic)

local Spring = Flipper.Spring.new
local Instant = Flipper.Instant.new
local New = Creator.New

local Notification = {}

function Notification:Init(GUI)
    Notification.Holder = New("Frame", {
        Position = UDim2.new(1, -30, 1, -30),
        Size = UDim2.new(0, 300, 1, -30),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Parent = GUI
    }, {
        New("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 20)
        })
    })
end

function Notification:New(Config)
    Config.Title = Config.Title or "Title"
    Config.Content = Config.Content or "Content"
    Config.SubContent = Config.SubContent or ""
    Config.Duration = Config.Duration or nil
    local NewNotification = {}

    NewNotification.AcrylicPaint = Acrylic.AcrylicPaint()

    NewNotification.Title = New("TextLabel", {
        Position = UDim2.new(0, 13, 0, 15),
        Text = "Notification Title",
        RichText = true,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextTransparency = 0,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        TextSize = 12,
        TextXAlignment = "Left",
        TextYAlignment = "Center",
        Size = UDim2.new(1, -12, 0, 12),
        TextWrapped = true,
        BackgroundTransparency = 1,
        ThemeTag = {
            TextColor3 = "Text"
        }
    })

    NewNotification.ContentLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = Config.Content,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
        TextWrapped = true,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

    NewNotification.SubContentLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = Config.SubContent,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
        TextWrapped = true,
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})

    NewNotification.LabelHolder = New("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(13, 38),
		Size = UDim2.new(1, -26, 0, 0),
	}, {
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 2)
		}),
		NewNotification.ContentLabel,
		NewNotification.SubContentLabel,
	})

    NewNotification.Root = New("Frame", {
        BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.fromScale(1, 0)
    }, {
        NewNotification.AcrylicPaint.Frame,
        NewNotification.Title,
        NewNotification.LabelHolder
    })

    if Config.Content == "" then
        NewNotification.ContentLabel.Visible = false
    end

    if Config.SubContent == "" then
        NewNotification.SubContentLabel.Visible = false
    end

    NewNotification.Holder = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 200),
		Parent = Notification.Holder
	}, {
		NewNotification.Root
	})

    local RootMotor = Flipper.GroupMotor.new({
        Scale = 1,
        Offset = 60
    })

	RootMotor:onStep(function(Values)
		NewNotification.Root.Position = UDim2.new(Values.Scale, Values.Offset, 0, 0)
	end)

    function NewNotification:Open()
        local ContentSize = NewNotification.LabelHolder.AbsoluteSize.Y
        NewNotification.Holder.Size = UDim2.new(1, 0, 0, 55 + ContentSize)

        RootMotor:setGoal({
            Scale = Spring(0, { frequency = 5 }),
            Offset = Spring(0, { frequency = 5 })
        })
    end

    function NewNotification:Close()
        task.spawn(function()
            RootMotor:setGoal({
                Scale = Spring(1, { frequency = 5 }),
                Offset = Spring(60, { frequency = 5 })
            })
            task.wait(0.45)
            NewNotification.Holder:Destroy()
        end)
    end

    NewNotification:Open()
    if Config.Duration then
        task.delay(Config.Duration, function()
            NewNotification:Close()
        end)
    end
    return NewNotification
end

return Notification