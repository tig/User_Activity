--Copyright 2019 Control4 Corporation. All rights reserved.
--
--This driver implements a simple "receiver" for incoming 
--messages from a user activity monitor. For example
--see https://tig.github.io/mcec.
--

function OnDriverInit ()
	PersistData = PersistData or {}
end

function OnDriverLateInit ()
	for property, _ in pairs (Properties) do
		OnPropertyChanged (property)
	end
end

function OnPropertyChanged (strProperty)
	local value = Properties [strProperty]
	if (value == nil) then
		value = ''
	end

	if (strProperty == 'TCP Port') then
		local ip = C4:GetControllerNetworkAddress ()

		local serverport = tonumber (value)

		if (serverport ~= SERVERPORT) then

			if (SERVERPORT) then
				C4:DestroyServer (SEVERPORT)
				SERVERPORT = nil
			end

			if (ip and ip ~= '') then
				local success = C4:CreateServer (serverport)
				print ('success: ' .. tostring (success))
				SERVERPORT = serverport
			else
				print ('error: Could not set ' .. strProperty .. tostring (ip))
			end
		end
	elseif (string.find (strProperty, 'Activity Command')) then
		SetPattern (value)
	end
end

function OnServerConnectionStatusChanged (nHandle, nPort, strStatus)
	print (nHandle, nPort, strStatus)
	if (strStatus == 'ONLINE') then
		if (not ServerBuffer) then ServerBuffer = {} end
		ServerBuffer [nHandle] = ''
	elseif (strStatus == 'OFFLINE') then
		C4:ServerCloseClient (nHandle)
		ServerBuffer [nHandle] = nil
	end
end

function OnServerDataIn (nHandle, strData)
	print (nHandle, strData)

	local toMatch = strData

	local found = CheckPattern (toMatch)
end

function SetPattern (value)
	Pattern = value
	if (value == '') then
		Pattern = nil
	else
		print ('Pattern ' .. value .. ' accepted')
		Pattern = value
	end


	if (Pattern) then
		local captures = 0

		local captureCheck = value or ''

		captureCheck = string.gsub (captureCheck, '%%%(', '') or ''
		captureCheck = string.gsub (captureCheck, '%%%)', '') or ''

		for _, _ in string.gfind (captureCheck, '%b()') do
			captures = captures + 1
		end

		for i = 1, captures do
			C4:AddVariable ('Activity Command' .. ' Capture ' .. tostring (i), '', 'STRING', true, false)
		end
	end
end

function CheckPattern (data)
	local pattern = Pattern
	if (pattern == nil) then
		print ('error: CheckPattern: Pattern is nil')
		return
	end

	local result = {string.find (data, pattern)}
	if (result [1] and result [2]) then
		table.remove (result, 1)
		table.remove (result, 1)

		for i = 1, #result do
			C4:SetVariable ('Activity Detected ' .. ' Capture ' .. tostring (i), result [i] or '')
			print ('Setting Variable: Activity Detected ' .. ' Capture ' .. tostring (i) .. ': ' .. result [i] or '')
		end

		print ('Firing Event: Activity Detected')
		C4:FireEvent ('Activity Detected')
		C4:SendToProxy(5001, "CLOSED", {}, "NOTIFY")
		return true
	end
	return false
end