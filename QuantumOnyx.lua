--[[
    QUANTUM ONYX HUB
    Luarmor removed.
    Authentication: Quantum Onyx VPS
    Required key: hello
]]

local API_CONFIG = {
    BASE_URL = "https://api.quantumonyx.cc",
    FALLBACK_URL = "http://165.232.169.51:22527",

    -- The only key accepted by this client.
    REQUIRED_KEY = "hello",

    DISCORD_INVITE = "https://discord.gg/quantumonyx",
}

local Directory =
    "https://raw.githubusercontent.com/flazhy/QuantumOnyx/refs/heads/main/Games"

local Scripts = {
    Free = {
        [994732206] = Directory .. "/BloxFruits.lua",
        [9186719164] = Directory .. "/SailorPiece.lua",
        [8191429227] = Directory .. "/CutTrees.lua",
    },
}

local FOLDER = "Quantum Onyx Hub"
local KEY_FILE = FOLDER .. "/Key.json"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local GameId = game.GameId
local gameId = GameId

--------------------------------------------------
-- HTTP
--------------------------------------------------

local HttpRequest =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or request
    or (fluxus and fluxus.request)
    or (delta and delta.request)

--------------------------------------------------
-- FILESYSTEM
--------------------------------------------------

local IsFileFunc = isfile or function()
    return false
end

local ReadFileFunc = readfile or function()
    return ""
end

local WriteFileFunc = writefile or function()
end

local MakeFolderFunc = makefolder or function()
end

local IsFolderFunc = isfolder or function()
    return false
end

--------------------------------------------------
-- EXECUTOR
--------------------------------------------------

local function GetExecutorName()
    if identifyexecutor then
        local ok, result = pcall(identifyexecutor)

        if ok and result then
            return tostring(result)
        end
    end

    if syn then
        return "Synapse X"
    end

    if KRNL_LOADED then
        return "Krnl"
    end

    if fluxus then
        return "Fluxus"
    end

    if is_sirhurt_closure then
        return "SirHurt"
    end

    return "Unknown Executor"
end

--------------------------------------------------
-- HWID
--------------------------------------------------

local function GetHWID()
    local hwid

    if gethwid then
        pcall(function()
            hwid = gethwid()
        end)
    elseif get_hwid then
        pcall(function()
            hwid = get_hwid()
        end)
    end

    if not hwid or tostring(hwid) == "" then
        pcall(function()
            hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        end)
    end

    if not hwid or tostring(hwid) == "" then
        hwid =
            "FALLBACK-"
            .. tostring(LocalPlayer.UserId)
            .. "-"
            .. tostring(game.PlaceId)
    end

    return tostring(hwid)
end

--------------------------------------------------
-- UI HELPERS
--------------------------------------------------

local function Tween(obj, props, time, style, direction)
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out

    pcall(function()
        TweenService:Create(
            obj,
            TweenInfo.new(time, style, direction),
            props
        ):Play()
    end)
end

local function Protect(gui)
    local env = (getgenv and getgenv()) or _G

    if env.HIDEUI then
        gui.Parent = env.HIDEUI

    elseif gethui then
        gui.Parent = gethui()

    elseif syn and syn.protect_gui then
        pcall(function()
            syn.protect_gui(gui)
        end)

        gui.Parent = game:GetService("CoreGui")

    else
        gui.Parent = game:GetService("CoreGui")
    end
end

local function New(class, props, parent)
    local instance = Instance.new(class)

    for key, value in pairs(props or {}) do
        if key ~= "Children" and key ~= "Parent" then
            pcall(function()
                instance[key] = value
            end)
        end
    end

    if props and props.Children then
        for _, child in ipairs(props.Children) do
            pcall(function()
                child.Parent = instance
            end)
        end
    end

    instance.Parent = (props and props.Parent) or parent

    return instance
end

local function CircleRipple(button, mouseX, mouseY)
    task.spawn(function()
        pcall(function()
            button.ClipsDescendants = true

            local nx =
                mouseX - button.AbsolutePosition.X

            local ny =
                mouseY - button.AbsolutePosition.Y

            local size =
                math.max(
                    button.AbsoluteSize.X,
                    button.AbsoluteSize.Y
                ) * 1.6

            local ripple = New("ImageLabel", {
                Name = "Ripple",
                Image = "rbxassetid://266543268",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ImageTransparency = 0.82,
                BackgroundTransparency = 1,
                ZIndex = button.ZIndex + 5,

                Size = UDim2.new(0, 0, 0, 0),

                Position = UDim2.new(
                    0,
                    nx,
                    0,
                    ny
                ),
            }, button)

            Tween(
                ripple,
                {
                    Size = UDim2.new(
                        0,
                        size,
                        0,
                        size
                    ),

                    Position = UDim2.new(
                        0.5,
                        -size / 2,
                        0.5,
                        -size / 2
                    ),
                },
                0.45,
                Enum.EasingStyle.Quad
            )

            Tween(
                ripple,
                {
                    ImageTransparency = 1
                },
                0.45,
                Enum.EasingStyle.Linear
            )

            task.wait(0.46)

            ripple:Destroy()
        end)
    end)
end

local function Notify(title, description, accent, duration)
    pcall(function()
        StarterGui:SetCore(
            "SendNotification",
            {
                Title = title or "Quantum Onyx",
                Text = description or "",
                Duration = duration or 5,
            }
        )
    end)
end

--------------------------------------------------
-- TIME
--------------------------------------------------

local function ToTime(expire)
    if not expire or expire <= 0 then
        return "Lifetime"
    end

    local left = expire - os.time()

    if left < 0 then
        return "Expired"
    end

    local days = math.floor(left / 86400)
    local hours =
        math.floor((left % 86400) / 3600)

    local minutes =
        math.floor((left % 3600) / 60)

    if days > 0 then
        return string.format(
            "%dd %dh",
            days,
            hours
        )
    end

    if hours > 0 then
        return string.format(
            "%dh %dm",
            hours,
            minutes
        )
    end

    return string.format(
        "%dm",
        minutes
    )
end

--------------------------------------------------
-- KEY STORAGE
--------------------------------------------------

local function SaveKey(key)
    pcall(function()
        if not IsFolderFunc(FOLDER) then
            MakeFolderFunc(FOLDER)
        end

        WriteFileFunc(
            KEY_FILE,
            HttpService:JSONEncode({
                key = tostring(key):gsub("%s+", "")
            })
        )
    end)
end

local function LoadSavedKey()
    local exists = false

    pcall(function()
        exists =
            IsFolderFunc(FOLDER)
            and IsFileFunc(KEY_FILE)
    end)

    if not exists then
        return ""
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(
            ReadFileFunc(KEY_FILE)
        )
    end)

    if ok
        and type(data) == "table"
        and data.key
    then
        return tostring(data.key):gsub("%s+", "")
    end

    return ""
end

local function ClearKey()
    pcall(function()
        if not IsFolderFunc(FOLDER) then
            MakeFolderFunc(FOLDER)
        end

        WriteFileFunc(
            KEY_FILE,
            HttpService:JSONEncode({})
        )
    end)
end

--------------------------------------------------
-- SCRIPT KEY
--------------------------------------------------

local function ApplyScriptKey(key)
    pcall(function()
        getgenv().script_key = key
        getgenv().key = key
    end)

    if type(_G) == "table" then
        _G.script_key = key
    end

    if type(shared) == "table" then
        shared.script_key = key
    end

    pcall(function()
        if type(getrenv) == "function" then
            local env = getrenv()

            if type(env) == "table" then
                env.script_key = key
            end
        end
    end)
end

--------------------------------------------------
-- SERVER AUTHENTICATION
--------------------------------------------------

local function VerifyWithServer(keyStr)
    if not HttpRequest then
        return false, nil,
            "Executor lacks HTTP request capability."
    end

    local payload = HttpService:JSONEncode({
        key = keyStr,
        hwid = GetHWID(),
        executor = GetExecutorName(),
        game_id = game.PlaceId,
    })

    local function Request(url)
        return HttpRequest({
            Url = url .. "/api/v1/authenticate",

            Method = "POST",

            Headers = {
                ["Content-Type"] =
                    "application/json",
            },

            Body = payload,
        })
    end

    local ok, response = pcall(function()
        return Request(API_CONFIG.BASE_URL)
    end)

    if not ok
        or not response
        or response.StatusCode == 0
        or response.StatusCode == 522
    then
        ok, response = pcall(function()
            return Request(API_CONFIG.FALLBACK_URL)
        end)
    end

    if not ok or not response then
        return false, nil,
            "Could not reach verification server."
    end

    local data

    pcall(function()
        data = HttpService:JSONDecode(
            response.Body
        )
    end)

    if response.StatusCode == 200
        and data
        and data.success
    then
        return true, data, nil
    end

    local errorMessage =
        (data and data.error)
        or (
            "HTTP "
            .. tostring(response.StatusCode)
        )

    return false, nil, errorMessage
end

--------------------------------------------------
-- LOAD FREE / PREMIUM
--------------------------------------------------

local function LoadScript(tier, scriptPayload)
    if tier == "Free" then

        local url = Scripts.Free[GameId]

        if not url then
            warn(
                "[Quantum Onyx] No free script found for GameId: "
                .. tostring(GameId)
            )

            Notify(
                "Quantum Onyx",
                "No free script exists for this game.",
                Color3.fromRGB(255, 150, 80),
                6
            )

            return
        end

        task.spawn(function()
            local ok, result = pcall(function()
                return game:HttpGet(url)
            end)

            if not ok or not result then
                Notify(
                    "Quantum Onyx",
                    "Failed to download the free script.",
                    Color3.fromRGB(255, 90, 110),
                    7
                )

                return
            end

            local func, compileError =
                loadstring(result)

            if not func then
                warn(
                    "[Quantum Onyx] Free script compile error: "
                    .. tostring(compileError)
                )

                return
            end

            local success, runtimeError =
                pcall(func)

            if not success then
                warn(
                    "[Quantum Onyx] Free script runtime error: "
                    .. tostring(runtimeError)
                )
            end
        end)

    elseif tier == "Premium" then

        if type(scriptPayload) ~= "string"
            or #scriptPayload < 1
        then
            warn(
                "[Quantum Onyx] VPS returned an empty Premium script."
            )

            Notify(
                "Quantum Onyx",
                "Premium script was not returned by the server.",
                Color3.fromRGB(255, 90, 110),
                8
            )

            return
        end

        task.spawn(function()
            local func, compileError =
                loadstring(scriptPayload)

            if not func then
                warn(
                    "[Quantum Onyx] Premium compile error: "
                    .. tostring(compileError)
                )

                Notify(
                    "Script Compile Error",
                    tostring(compileError):sub(1, 100),
                    Color3.fromRGB(255, 90, 110),
                    10
                )

                return
            end

            local success, runtimeError =
                pcall(func)

            if not success then
                warn(
                    "[Quantum Onyx] Premium runtime error: "
                    .. tostring(runtimeError)
                )

                Notify(
                    "Script Runtime Error",
                    tostring(runtimeError):sub(1, 100),
                    Color3.fromRGB(255, 90, 110),
                    10
                )
            end
        end)
    end
end

--------------------------------------------------
-- AUTHENTICATION
--------------------------------------------------

local function ResolveAndLoadKey(keyStr, hooks)
    hooks = hooks or {}

    local onStatus =
        hooks.onStatus
        or function()
        end

    local onSuccess =
        hooks.onSuccess
        or function()
        end

    local onFail =
        hooks.onFail
        or function()
        end

    keyStr =
        tostring(keyStr or ""):gsub("%s+", "")

    if keyStr == "" then
        onFail(
            "empty",
            "Please enter the key."
        )

        return
    end

    --------------------------------------------------
    -- Client-side key format check
    --------------------------------------------------

    if keyStr ~= API_CONFIG.REQUIRED_KEY then
        onFail(
            "KEY_INCORRECT",
            "Incorrect key."
        )

        return
    end

    --------------------------------------------------
    -- Server verification
    --------------------------------------------------

    local startTime = os.clock()

    onStatus(
        "Verifying with Quantum Onyx VPS..."
    )

    local success, authData, errorMessage =
        VerifyWithServer(keyStr)

    if not success then
        onFail(
            "SERVER_REJECTED",
            errorMessage
                or "The server rejected the key."
        )

        return
    end

    if type(authData) ~= "table" then
        onFail(
            "INVALID_RESPONSE",
            "Invalid response from authentication server."
        )

        return
    end

    --------------------------------------------------
    -- Expiration
    --------------------------------------------------

    local expire = authData.auth_expire

    if expire
        and expire ~= 0
        and expire ~= -1
        and expire <= os.time()
    then
        ClearKey()

        onFail(
            "KEY_EXPIRED",
            "Key expired."
        )

        return
    end

    --------------------------------------------------
    -- Save authentication data
    --------------------------------------------------

    ApplyScriptKey(keyStr)
    SaveKey(keyStr)

    pcall(function()
        getgenv().key_expire =
            authData.auth_expire or 0

        getgenv().key_note =
            authData.note or ""

        getgenv().key_executions =
            authData.total_executions or 0
    end)

    local elapsed =
        string.format(
            "%.2fs",
            os.clock() - startTime
        )

    local permanent =
        not expire
        or expire == 0
        or expire == -1

    --------------------------------------------------
    -- Success
    --------------------------------------------------

    onSuccess({
        permanent = permanent,
        expire = expire or 0,
        elapsedStr = elapsed,
    })

    --------------------------------------------------
    -- Load server-provided Premium script
    --------------------------------------------------

    if type(authData.script) == "string"
        and #authData.script > 0
    then
        LoadScript(
            "Premium",
            authData.script
        )
    else
        onFail(
            "NO_SCRIPT",
            "Authentication succeeded, but the VPS returned no Premium script."
        )
    end
end

--------------------------------------------------
-- KEY UI
--------------------------------------------------

local function ShowKeyUI()
    local submitting = false
    local done = false

    local productName = "Unknown"

    pcall(function()
        productName =
            game:GetService(
                "MarketplaceService"
            ):GetProductInfo(
                game.PlaceId
            ).Name
    end)

    local SG = Instance.new("ScreenGui")

    SG.Name =
        "QuantumOnyx_" ..
        tostring(math.random(100000, 999999))

    SG.ZIndexBehavior =
        Enum.ZIndexBehavior.Global

    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true

    Protect(SG)

    --------------------------------------------------
    -- BACKDROP
    --------------------------------------------------

    local Backdrop = New("Frame", {
        BackgroundColor3 =
            Color3.fromRGB(0, 0, 0),

        BackgroundTransparency = 0.45,

        BorderSizePixel = 0,

        Size =
            UDim2.new(1, 0, 1, 0),

        ZIndex = 200,

        Parent = SG,
    })

    --------------------------------------------------
    -- CARD
    --------------------------------------------------

    local W = 450
    local H = 310

    local Card = New("Frame", {
        AnchorPoint =
            Vector2.new(0.5, 0.5),

        Position =
            UDim2.new(
                0.5,
                0,
                0.5,
                0
            ),

        Size =
            UDim2.new(
                0,
                W,
                0,
                H
            ),

        BackgroundColor3 =
            Color3.fromRGB(
                15,
                12,
                24
            ),

        BorderSizePixel = 0,

        ZIndex = 201,

        ClipsDescendants = true,

        Parent = SG,

        Children = {
            New("UICorner", {
                CornerRadius =
                    UDim.new(0, 14),
            }),

            New("UIStroke", {
                Color =
                    Color3.fromRGB(
                        120,
                        60,
                        220
                    ),

                Transparency = 0.3,

                Thickness = 1.5,

                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,
            }),
        },
    })

    --------------------------------------------------
    -- HEADER
    --------------------------------------------------

    local Header = New("Frame", {
        BackgroundColor3 =
            Color3.fromRGB(
                22,
                16,
                36
            ),

        BorderSizePixel = 0,

        Size =
            UDim2.new(
                1,
                0,
                0,
                44
            ),

        ZIndex = 202,

        Parent = Card,

        Children = {
            New("UICorner", {
                CornerRadius =
                    UDim.new(0, 14),
            }),

            New("Frame", {
                BackgroundColor3 =
                    Color3.fromRGB(
                        22,
                        16,
                        36
                    ),

                BorderSizePixel = 0,

                Position =
                    UDim2.new(
                        0,
                        0,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.new(
                        1,
                        0,
                        0.5,
                        0
                    ),

                ZIndex = 202,
            }),
        },
    })

    New("ImageLabel", {
        BackgroundTransparency = 1,

        Position =
            UDim2.new(
                0,
                13,
                0.5,
                -8
            ),

        Size =
            UDim2.new(
                0,
                16,
                0,
                16
            ),

        Image =
            "rbxassetid://7733992528",

        ImageColor3 =
            Color3.fromRGB(
                155,
                90,
                255
            ),

        ZIndex = 203,

        Parent = Header,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,

        Position =
            UDim2.new(
                0,
                35,
                0,
                0
            ),

        Size =
            UDim2.new(
                1,
                -80,
                1,
                0
            ),

        Font =
            Enum.Font.FredokaOne,

        Text =
            "Quantum Onyx — Authentication",

        TextColor3 =
            Color3.fromRGB(
                220,
                200,
                255
            ),

        TextSize = 14,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        ZIndex = 203,

        Parent = Header,
    })

    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    local CloseBtn = New("TextButton", {
        BackgroundTransparency = 1,

        AnchorPoint =
            Vector2.new(1, 0.5),

        Position =
            UDim2.new(
                1,
                -10,
                0.5,
                0
            ),

        Size =
            UDim2.new(
                0,
                25,
                0,
                25
            ),

        Text = "×",

        Font =
            Enum.Font.GothamBold,

        TextSize = 20,

        TextColor3 =
            Color3.fromRGB(
                220,
                80,
                90
            ),

        ZIndex = 204,

        Parent = Header,
    })

    CloseBtn.MouseButton1Click:Connect(function()
        SG:Destroy()
    end)

    --------------------------------------------------
    -- HEADER LINE
    --------------------------------------------------

    New("Frame", {
        BackgroundColor3 =
            Color3.fromRGB(
                120,
                60,
                220
            ),

        BackgroundTransparency = 0.3,

        BorderSizePixel = 0,

        Position =
            UDim2.new(
                0,
                0,
                0,
                44
            ),

        Size =
            UDim2.new(
                1,
                0,
                0,
                1
            ),

        ZIndex = 202,

        Parent = Card,
    })

    --------------------------------------------------
    -- INFORMATION BOX
    --------------------------------------------------

    local InfoBox = New("Frame", {
        BackgroundColor3 =
            Color3.fromRGB(
                22,
                16,
                36
            ),

        BorderSizePixel = 0,

        Position =
            UDim2.new(
                0,
                10,
                0,
                58
            ),

        Size =
            UDim2.new(
                0,
                170,
                0,
                125
            ),

        ZIndex = 202,

        Parent = Card,

        Children = {
            New("UICorner", {
                CornerRadius =
                    UDim.new(0, 8),
            }),

            New("UIStroke", {
                Color =
                    Color3.fromRGB(
                        100,
                        50,
                        190
                    ),

                Transparency = 0.4,

                Thickness = 1,

                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,
            }),
        },
    })

    New("TextLabel", {
        BackgroundTransparency = 1,

        Position =
            UDim2.new(
                0,
                10,
                0,
                7
            ),

        Size =
            UDim2.new(
                1,
                -20,
                0,
                16
            ),

        Font =
            Enum.Font.GothamBold,

        Text = "Information",

        TextColor3 =
            Color3.fromRGB(
                160,
                110,
                240
            ),

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        ZIndex = 203,

        Parent = InfoBox,
    })

    local info = {
        {
            "Game",
            productName,
        },

        {
            "Version",
            "v.Freemium",
        },

        {
            "Auth",
            "Quantum Onyx VPS",
        },

        {
            "Key",
            "hello",
        },
    }

    local infoY = 31

    for _, entry in ipairs(info) do
        New("TextLabel", {
            BackgroundTransparency = 1,

            Position =
                UDim2.new(
                    0,
                    10,
                    0,
                    infoY
                ),

            Size =
                UDim2.new(
                    0,
                    48,
                    0,
                    15
                ),

            Font =
                Enum.Font.GothamBold,

            Text =
                entry[1] .. ":",

            TextColor3 =
                Color3.fromRGB(
                    140,
                    110,
                    190
                ),

            TextSize = 9,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            ZIndex = 203,

            Parent = InfoBox,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,

            Position =
                UDim2.new(
                    0,
                    58,
                    0,
                    infoY
                ),

            Size =
                UDim2.new(
                    1,
                    -68,
                    0,
                    15
                ),

            Font =
                Enum.Font.Gotham,

            Text =
                tostring(entry[2]),

            TextColor3 =
                Color3.fromRGB(
                    205,
                    185,
                    240
                ),

            TextSize = 9,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            TextTruncate =
                Enum.TextTruncate.AtEnd,

            ZIndex = 203,

            Parent = InfoBox,
        })

        infoY = infoY + 22
    end

    --------------------------------------------------
    -- NOTICE
    --------------------------------------------------

    local Notice = New("Frame", {
        BackgroundColor3 =
            Color3.fromRGB(
                22,
                16,
                36
            ),

        BorderSizePixel = 0,

        Position =
            UDim2.new(
                0,
                190,
                0,
                58
            ),

        Size =
            UDim2.new(
                0,
                250,
                0,
                55
            ),

        ZIndex = 202,

        Parent = Card,

        Children = {
            New("UICorner", {
                CornerRadius =
                    UDim.new(0, 7),
            }),

            New("UIStroke", {
                Color =
                    Color3.fromRGB(
                        80,
                        200,
                        110
                    ),

                Transparency = 0.4,

                Thickness = 1,

                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,
            }),
        },
    })

    New("TextLabel", {
        BackgroundTransparency = 1,

        Position =
            UDim2.new(
                0,
                12,
                0,
                4
            ),

        Size =
            UDim2.new(
                1,
                -20,
                1,
                -8
            ),

        Font =
            Enum.Font.Gotham,

        Text =
            "Quantum Onyx authentication.\n"
            .. "Enter the required key to continue.",

        TextColor3 =
            Color3.fromRGB(
                140,
                230,
                170
            ),

        TextSize = 10,

        TextWrapped = true,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextYAlignment =
            Enum.TextYAlignment.Center,

        ZIndex = 203,

        Parent = Notice,
    })

    --------------------------------------------------
    -- AUTH STATUS
    --------------------------------------------------

    local StatusBox = New("Frame", {
        BackgroundColor3 =
            Color3.fromRGB(
                22,
                16,
                36
            ),

        BorderSizePixel = 0,

        Position =
            UDim2.new(
                0,
                190,
                0,
                122
            ),

        Size =
            UDim2.new(
                0,
                250,
                0,
                30
            ),

        ZIndex = 202,

        Parent = Card,

        Children = {
            New("UICorner", {
                CornerRadius =
                    UDim.new(0, 6),
            }),

            New("UIStroke", {
                Color =
                    Color3.fromRGB(
                        100,
                        50,
                        190
                    ),

                Transparency = 0.4,

                Thickness = 1,

                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,
            }),
        },
    })

    local StatusSystem = New("TextLabel", {
        BackgroundTransparency = 1,

        Position =
            UDim2.new(
                0,
                10,
                0,
                0
            ),

        Size =
            UDim2.new(
                1,
                -20,
                1,
                0
            ),

        Font =
            Enum.Font.GothamBold,

        Text =
            "Ready for Authentication",

        TextColor3 =
            Color3.fromRGB(
                180,
                160,
                225
            ),

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        ZIndex = 203,

        Parent = StatusBox,
    })

    --------------------------------------------------
    -- KEY INPUT
    --------------------------------------------------

    local InputBg = New("Frame", {
        BackgroundColor3 =
            Color3.fromRGB(
                10,
                8,
                18
            ),

        BorderSizePixel = 0,

        Position =
            UDim2.new(
                0,
                190,
                0,
                163
            ),

        Size =
            UDim2.new(
                0,
                250,
                0,
                38
            ),

        ZIndex = 202,

        Parent = Card,

        Children = {
            New("UICorner", {
                CornerRadius =
                    UDim.new(0, 7),
            }),

            New("UIStroke", {
                Color =
                    Color3.fromRGB(
                        120,
                        60,
                        220
                    ),

                Transparency = 0.3,

                Thickness = 1,

                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,
            }),
        },
    })

    New("ImageLabel", {
        BackgroundTransparency = 1,

        Position =
            UDim2.new(
                0,
                10,
                0.5,
                -7
            ),

        Size =
            UDim2.new(
                0,
                14,
                0,
                14
            ),

        Image =
            "rbxassetid://7733992528",

        ImageColor3 =
            Color3.fromRGB(
                140,
                90,
                215
            ),

        ZIndex = 203,

        Parent = InputBg,
    })

    local KeyInput = New("TextBox", {
        BackgroundTransparency = 1,

        Position =
            UDim2.new(
                0,
                32,
                0,
                0
            ),

        Size =
            UDim2.new(
                1,
                -42,
                1,
                0
            ),

        Font =
            Enum.Font.GothamBold,

        PlaceholderText = "hello",

        PlaceholderColor3 =
            Color3.fromRGB(
                110,
                85,
                155
            ),

        Text =
            API_CONFIG.REQUIRED_KEY,

        TextColor3 =
            Color3.fromRGB(
                225,
                205,
                255
            ),

        TextSize = 12,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        ClearTextOnFocus = false,

        ZIndex = 203,

        Parent = InputBg,
    })

    --------------------------------------------------
    -- FORCE KEY TO "hello"
    --------------------------------------------------

    KeyInput:GetPropertyChangedSignal("Text"):Connect(
        function()
            if KeyInput.Text ~= API_CONFIG.REQUIRED_KEY then
                KeyInput.Text =
                    API_CONFIG.REQUIRED_KEY
            end
        end
    )

    --------------------------------------------------
    -- STATUS LABEL
    --------------------------------------------------

    local StatusLabel = New("TextLabel", {
        BackgroundTransparency = 1,

        Position =
            UDim2.new(
                0,
                190,
                0,
                207
            ),

        Size =
            UDim2.new(
                0,
                250,
                0,
                18
            ),

        Font =
            Enum.Font.GothamBold,

        Text =
            "HWID: "
            .. GetHWID():sub(1, 12)
            .. "...",

        TextColor3 =
            Color3.fromRGB(
                175,
                155,
                210
            ),

        TextSize = 9,

        TextXAlignment =
            Enum.TextXAlignment.Center,

        ZIndex = 202,

        Parent = Card,
    })

    local function SetStatus(message, color)
        StatusLabel.Text = message

        StatusLabel.TextColor3 =
            color
            or Color3.fromRGB(
                175,
                155,
                210
            )
    end

    --------------------------------------------------
    -- CLOSE ANIMATION
    --------------------------------------------------

    local function AnimateClose()
        if done then
            return
        end

        done = true

        Tween(
            Card,
            {
                Size =
                    UDim2.new(
                        0,
                        W * 0.65,
                        0,
                        H * 0.65
                    ),

                BackgroundTransparency = 1,
            },
            0.20,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.In
        )

        Tween(
            Backdrop,
            {
                BackgroundTransparency = 1,
            },
            0.20,
            Enum.EasingStyle.Quint
        )

        task.delay(
            0.22,
            function()
                pcall(function()
                    SG:Destroy()
                end)
            end
        )
    end

    --------------------------------------------------
    -- SUBMIT
    --------------------------------------------------

    local function SubmitKey()
        if submitting then
            return
        end

        submitting = true

        KeyInput.Text =
            API_CONFIG.REQUIRED_KEY

        ResolveAndLoadKey(
            API_CONFIG.REQUIRED_KEY,
            {
                onStatus = function(message)
                    SetStatus(
                        message,
                        Color3.fromRGB(
                            175,
                            150,
                            255
                        )
                    )

                    StatusSystem.Text =
                        "Authenticating..."
                end,

                onSuccess = function(info)
                    submitting = false

                    StatusSystem.Text =
                        info.permanent
                        and "Premium Active"
                        or "Time-Limited Key Active"

                    StatusSystem.TextColor3 =
                        Color3.fromRGB(
                            80,
                            230,
                            130
                        )

                    SetStatus(
                        "Verified in "
                        .. info.elapsedStr
                        .. "! Loading...",
                        Color3.fromRGB(
                            80,
                            230,
                            130
                        )
                    )

                    Notify(
                        "Key Verified",
                        "Expires: "
                        .. ToTime(info.expire),
                        Color3.fromRGB(
                            80,
                            230,
                            130
                        ),
                        6
                    )

                    task.wait(0.3)

                    AnimateClose()
                end,

                onFail = function(code, message)
                    submitting = false

                    StatusSystem.Text =
                        "Authentication Failed"

                    StatusSystem.TextColor3 =
                        Color3.fromRGB(
                            255,
                            100,
                            110
                        )

                    if code == "SERVER_REJECTED" then
                        SetStatus(
                            tostring(
                                message
                                or "Server rejected the key."
                            ),
                            Color3.fromRGB(
                                255,
                                90,
                                110
                            )
                        )

                        Notify(
                            "Authentication Failed",
                            tostring(
                                message
                                or "Server rejected the key."
                            ),
                            Color3.fromRGB(
                                255,
                                90,
                                110
                            ),
                            7
                        )

                    elseif code == "HTTP_UNAVAILABLE" then
                        SetStatus(
                            "HTTP requests are unavailable.",
                            Color3.fromRGB(
                                255,
                                90,
                                110
                            )
                        )

                    elseif code == "KEY_EXPIRED" then
                        ClearKey()

                        SetStatus(
                            "Key expired.",
                            Color3.fromRGB(
                                255,
                                90,
                                110
                            )
                        )

                    elseif code == "NO_SCRIPT" then
                        SetStatus(
                            "No Premium script was returned.",
                            Color3.fromRGB(
                                255,
                                90,
                                110
                            )
                        )

                    else
                        SetStatus(
                            tostring(
                                message
                                or code
                                or "Authentication failed."
                            ),
                            Color3.fromRGB(
                                255,
                                90,
                                110
                            )
                        )
                    end
                end,
            }
        )
    end

    --------------------------------------------------
    -- BUTTONS
    --------------------------------------------------

    local ButtonY = 239
    local ButtonHeight = 32

    local function MakeButton(
        text,
        x,
        width,
        background,
        textColor,
        callback
    )
        local button = New("TextButton", {
            BackgroundColor3 = background,

            BorderSizePixel = 0,

            Position =
                UDim2.new(
                    0,
                    x,
                    0,
                    ButtonY
                ),

            Size =
                UDim2.new(
                    0,
                    width,
                    0,
                    ButtonHeight
                ),

            AutoButtonColor = false,

            Text = "",

            ClipsDescendants = true,

            ZIndex = 202,

            Parent = Card,

            Children = {
                New("UICorner", {
                    CornerRadius =
                        UDim.new(0, 7),
                }),

                New("TextLabel", {
                    BackgroundTransparency = 1,

                    Size =
                        UDim2.new(
                            1,
                            0,
                            1,
                            0
                        ),

                    Font =
                        Enum.Font.FredokaOne,

                    Text = text,

                    TextColor3 =
                        textColor,

                    TextSize = 12,

                    TextXAlignment =
                        Enum.TextXAlignment.Center,

                    ZIndex = 203,
                }),
            },
        })

        button.MouseEnter:Connect(
            function()
                Tween(
                    button,
                    {
                        BackgroundColor3 =
                            background:Lerp(
                                Color3.fromRGB(
                                    255,
                                    255,
                                    255
                                ),
                                0.15
                            ),
                    },
                    0.12
                )
            end
        )

        button.MouseLeave:Connect(
            function()
                Tween(
                    button,
                    {
                        BackgroundColor3 =
                            background,
                    },
                    0.16
                )
            end
        )

        button.MouseButton1Click:Connect(
            function()
                CircleRipple(
                    button,
                    Mouse.X,
                    Mouse.Y
                )

                callback()
            end
        )

        return button
    end

    local buttonGap = 8
    local buttonWidth = 119

    --------------------------------------------------
    -- FREE BUTTON
    --------------------------------------------------

    MakeButton(
        "Free Version",
        190,
        buttonWidth,
        Color3.fromRGB(
            45,
            20,
            85
        ),
        Color3.fromRGB(
            200,
            165,
            255
        ),
        function()
            if not Scripts.Free[gameId] then
                SetStatus(
                    "No free version for this game.",
                    Color3.fromRGB(
                        255,
                        150,
                        80
                    )
                )

                return
            end

            AnimateClose()

            task.wait(0.25)

            LoadScript(
                "Free",
                nil
            )
        end
    )

    --------------------------------------------------
    -- DISCORD BUTTON
    --------------------------------------------------

    MakeButton(
        "Discord",
        190 + buttonWidth + buttonGap,
        buttonWidth,
        Color3.fromRGB(
            35,
            45,
            90
        ),
        Color3.fromRGB(
            150,
            195,
            255
        ),
        function()
            pcall(function()
                (
                    setclipboard
                    or toclipboard
                )(
                    API_CONFIG.DISCORD_INVITE
                )
            end)

            SetStatus(
                "Discord invite copied!",
                Color3.fromRGB(
                    105,
                    195,
                    255
                )
            )

            Notify(
                "Quantum Onyx",
                "Discord invite copied.",
                Color3.fromRGB(
                    105,
                    195,
                    255
                ),
                4
            )
        end
    )

    --------------------------------------------------
    -- ENTER BUTTON
    --------------------------------------------------

    MakeButton(
        "Enter Key",
        190
            + (buttonWidth + buttonGap) * 2,
        buttonWidth,
        Color3.fromRGB(
            65,
            25,
            130
        ),
        Color3.fromRGB(
            225,
            180,
            255
        ),
        function()
            SubmitKey()
        end
    )

    --------------------------------------------------
    -- ENTER KEYBOARD
    --------------------------------------------------

    KeyInput.FocusLost:Connect(
        function(enterPressed)
            if enterPressed then
                SubmitKey()
            end
        end
    )
end

--------------------------------------------------
-- STARTUP
--------------------------------------------------

local function AuthenticateAndLoad()
    -- The key is intentionally fixed.
    local savedKey = LoadSavedKey()

    if savedKey == API_CONFIG.REQUIRED_KEY then

        task.spawn(function()
            ResolveAndLoadKey(
                API_CONFIG.REQUIRED_KEY,
                {
                    onStatus = function()
                    end,

                    onSuccess = function(info)
                        Notify(
                            "Welcome Back",
                            "Authenticated in "
                            .. info.elapsedStr
                            .. ".",
                            Color3.fromRGB(
                                80,
                                230,
                                130
                            ),
                            5
                        )
                    end,

                    onFail = function()
                        ClearKey()
                        ShowKeyUI()
                    end,
                }
            )
        end)

    else
        ClearKey()
        ShowKeyUI()
    end
end

--------------------------------------------------
-- RUN
--------------------------------------------------

AuthenticateAndLoad()
