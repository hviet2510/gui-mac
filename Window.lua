local Window = {}
function Window.new(title)
    return setmetatable({Title=title}, {__index=Window})
end
return Window