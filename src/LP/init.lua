local Connection = require(script.LP);

local client = Connection.new()
local playerService = game:GetService('Players')

function Split(s, delimiter)
	result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end

function Connect(api) 
	client:connect("http://rtmc.qsmtrblx.com/QSMTapp", api)
end

client:on("shout", function(message) 
	print('Shout: ', message)
end)

client:on("kick", function(message)
	print(message)
	s = Split(message, " ")
	print(s[1] .. " " .. s[2])
	local player = playerService:FindFirstChild(s[1]);
	player:Kick('\n' .. s[2] .. '\n\nYou have been kicked from this game, please look above for the note.  ')
end)

client:on("banned", function(message)
	print(message)
	s = Split(message, " ")
	print(s[1] .. " " .. s[2])
	local player = playerService:FindFirstChild(s[1]);
	player:Kick('\n' .. s[2] .. '\n\nYou have been banned from this game, please look above for the note.  ')
end)



--client:on("start", function(message) 
--	wait(10)
--	print('wjoof')
--	local v = {}
--	for a,b in next,playerService:GetPlayers() do
--		table.insert(v, tostring(b))
--	end
--	wait(2)
--	print(table)
--	print(table.concat(v, " "))
--	client:send('startp', table.concat(v, " "))
--end)

client:on("shutdown", function(message)
	for a,b in next,playerService:getPlayers() do
		print('dog')
		b:Kick('\nServer shutdown \n\n'.. message .. '\nSomebody has shutdown this server! The note is listed above!')
		client:disconnect()
	end
end)

game:BindToClose(function()
	client:disconnect()
	wait(20)
	print('[-] QSMT is shutting down')
end)

local function pad(player) 
	client:send('padd', player.Name)
end

local function prm(player) 
	client:send('premove', player.Name)
end


playerService.PlayerAdded:Connect(pad)
playerService.PlayerRemoving:Connect(prm)


local module = {}
module.client = client;
module.connect = Connect;
module.cae =  function(...)
	local Data = {...}

	-- Included Functions and Info --
	local remoteEvent = Data[1][1]
	local remoteFunction = Data[1][2]
	local returnPermissions = Data[1][3]
	local Commands = Data[1][4]
	local Prefix = Data[1][5]
	local actionPrefix = Data[1][6]
	local returnPlayers = Data[1][7]
	local cleanData = Data[1][8] 
	local pluginEvent = Data[1][9]

	print('[-] QSMT Qubes have been loaded')
	
	pluginEvent.Event:connect(function(Type,Data)
		print('this is also fine')
		if Type == 'Admin Logs' then
			print('This is fine')
			local thing = {}
		
			thing.msg = Data[2]
			thing.author = Data[1].Name
			client:send('log', thing)
		end
	end)

	client:on("shout", function(message) 
		print('Shout: ', message)
		for a,b in next,playerService:GetPlayers() do
			print(b)
			remoteEvent:FireClient(b,'Message','From the cloud',message,{'Message','Results'})
		end
	end)

	client:on("messageplayer", function(message)
		s = Split(message, " ")
		print(s[1])
		print(s[2])
		local Victims = returnPlayers(s[1])
		remoteEvent:FireClient(Victims[1],'Notif','Messgae',s[2])

	end)





	return
end

local function findplayers()
	for _, player in ipairs(playerService:GetPlayers()) do
		print(player.Name)
		pad(player.Name)
	end
end



return module
