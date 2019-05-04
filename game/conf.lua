-- on love
if love.filesystem then
	-- loverocks
	--require 'rocks' ()

	-- src
	love.filesystem.setRequirePath("src/?.lua;src/?/init.lua;" .. love.filesystem.getRequirePath())

	-- lib
	love.filesystem.setRequirePath("lib/?;lib/?.lua;lib/?/init.lua;" .. love.filesystem.getRequirePath())
end

function love.conf(t)
	t.identity = "love-same-game"
	t.version = "11.2"

	--t.window = nil
	t.window.title = "SAME GAME"

end
