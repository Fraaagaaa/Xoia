require("T6.Zombie.HudCompetitiveScoreboardZombieOG")

CoD.CompetitiveScoreboard.TeamPlayerCount = 8

CoD.CompetitiveScoreboard.CompetitiveScoreTextShowPlayerColor = function (Text, LocalClientIndex, AnimDelay)
	if not AnimDelay then
		AnimDelay = 0
	end
	
	local ZombiesColorIndex = (LocalClientIndex - 1) % 4 + 1
	Text:beginAnimation("showplayercolor", AnimDelay)
	Text:setRGB(CoD.Zombie.PlayerColors[ZombiesColorIndex].r, CoD.Zombie.PlayerColors[ZombiesColorIndex].g, CoD.Zombie.PlayerColors[ZombiesColorIndex].b)
end
