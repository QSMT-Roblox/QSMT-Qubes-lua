local HttpService = game:GetService("HttpService")
local GetName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)



local Connection = {}
Connection.__index = Connection

function Connection.new(options)
	local self = setmetatable({options = options}, Connection)

	self._events = {}

	return self
end

function Connection:_url(path)
	return "http" .. (self.secure and "s" or "") .. "://" .. (self.host .. "/" .. path):gsub("//+", "/")
end

-- Connect

function Connection:connect(host, apikey, secure)
	host = host:gsub("^https?://", "")

	self.host = host
	self.secure = not not secure
	print('[-] trying to connect to qube')


	local json = HttpService:RequestAsync(
		{
			Url = self:_url("/connect?pid=" .. game.PlaceId .. '&name=' .. GetName.Name),
			Method = "GET",
			Headers = {
				["Authorization"] = apikey
			}
		}
	)
	print('[-] Should be connected')

	local response = HttpService:JSONDecode(json.Body)

	if response.id then
		self.Id = response.id

		self._headers = { ["Connection-Id"] = response.id }
		self._connected = true

		self:_recieve()
	end
end

function Connection:disconnect()
	self._connected = false
	HttpService:GetAsync(self:_url("/disconnect"), true, self._headers)
end

-- Events

function Connection:_getEvent(target)
	if not self._events[target] then
		self._events[target] = Instance.new("BindableEvent")
	end

	return self._events[target]
end

function Connection:_emit(target, data)
	self:_getEvent(target):Fire(data)
end

function Connection:on(target, func)
	return self:_getEvent(target).Event:Connect(func)
end

-- Data

function Connection:_recieve()
	if self._connected then
		spawn(function()
			local json = HttpService:RequestAsync(
				{
					Url = self:_url("/data"),
					Method = "GET",
					Headers = self._headers
				}
			)

			
			local response = HttpService:JSONDecode(json.Body);

			for _, message in pairs(response) do
				self:_emit(message.t, message.d)
			end

			self:_recieve()
		end)
	end

end

function Connection:send(target, data)
	spawn(function()
		local body = HttpService:JSONEncode({ t = target, d = data })
		HttpService:PostAsync(self:_url("/data"), body, nil, nil, self._headers)
	end)
end

return Connection