////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message linkify\">[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_rights_for(C, R_ADMIN))
			to_chat(C, msg)


/proc/relay_msg_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">RELAY:</span> <span class=\"message linkify\">[msg]</span></span>"
	to_chat(GLOB.admins, msg)


///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(mob/M in GLOB.mob_list)
	set category = "Debug"
	set name = "Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!check_rights())
		return

	log_admin("[key_name(usr)] checked the individual player panel for [key_name(M)][isobserver(usr)?"":" while in game"].")

	if(!M)
		to_chat(usr, span_warning("I seem to be selecting a mob that doesn't exist anymore."))
		return

	var/body = "<html><head><title>Options for [M.key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += "\[<A href='?_src_=holder;[HrefToken()];editrights=[(GLOB.admin_datums[M.client.ckey] || GLOB.deadmins[M.client.ckey]) ? "rank" : "add"];key=[M.key]'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\]"
		if(CONFIG_GET(flag/use_exp_tracking))
			body += "\[<A href='?_src_=holder;[HrefToken()];getplaytimewindow=[REF(M)]'>" + M.client.get_exp_living() + "</a>\]"

	if(isnewplayer(M))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?_src_=holder;[HrefToken()];revive=[REF(M)]'>Heal</A>\] "

	if(M.client)
		body += "<br>\[<b>First Seen:</b> [M.client.player_join_date]\]\[<b>Byond account registered on:</b> [M.client.account_join_date]\]"
		body += "<br><br><b>Show related accounts by:</b> "
		body += "\[ <a href='?_src_=holder;[HrefToken()];showrelatedacc=cid;client=[REF(M.client)]'>CID</a> | "
		body += "<a href='?_src_=holder;[HrefToken()];showrelatedacc=ip;client=[REF(M.client)]'>IP</a> \]"
		var/rep = 0
		rep += SSpersistence.antag_rep[M.ckey]
		body += "<br><br>Antagonist reputation: [rep]"
		body += "<br><a href='?_src_=holder;[HrefToken()];modantagrep=add;mob=[REF(M)]'>\[increase\]</a> "
		body += "<a href='?_src_=holder;[HrefToken()];modantagrep=subtract;mob=[REF(M)]'>\[decrease\]</a> "
		body += "<a href='?_src_=holder;[HrefToken()];modantagrep=set;mob=[REF(M)]'>\[set\]</a> "
		body += "<a href='?_src_=holder;[HrefToken()];modantagrep=zero;mob=[REF(M)]'>\[zero\]</a>"

		//PQ
		body += "<br><br><b>Player Quality:</b> [get_playerquality(M.ckey, FALSE)]"
		body += "  <a href='?_src_=holder;[HrefToken()];modpq=adjust;mob=[REF(M)]'>\[adjust\]</a>     "

		//Triumphs
		body += "<b>Triumphs:</b> [M.get_triumphs()]"
		body += "  <a href='?_src_=holder;[HrefToken()];modtriumphs=adjust;mob=[REF(M)]'>\[adjust\]</a>"
		var/full_version = "Unknown"
		if(M.client.byond_version)
			full_version = "[M.client.byond_version].[M.client.byond_build ? M.client.byond_build : "xxx"]"
		body += "<br>\[<b>Byond version:</b> [full_version]\]<br>"


	body += "<br><br>\[ "
	body += "<a href='?_src_=vars;[HrefToken()];Vars=[REF(M)]'>VV</a> - "
	if(M.mind)
		body += "<a href='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>TP</a> - "
	else
		body += "<a href='?_src_=holder;[HrefToken()];initmind=[REF(M)]'>Init Mind</a> - "
	body += "<a href='?priv_msg=[M.ckey]'>PM</a> - "
	body += "<a href='?_src_=holder;[HrefToken()];subtlemessage=[REF(M)]'>SM</a> - "
	if (ishuman(M) && M.mind)
		body += "<a href='?_src_=holder;[HrefToken()];HeadsetMessage=[REF(M)]'>HM</a> - "
	body += "<a href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a> - "
	//Default to client logs if available
	var/source = LOGSRC_MOB
	if(M.client)
		source = LOGSRC_CLIENT
	body += "<a href='?_src_=holder;[HrefToken()];individuallog=[REF(M)];log_src=[source]'>LOGS</a>\] <br>"

	body += "<b>Mob type</b> = [M.type]<br><br>"

	body += "<A href='?_src_=holder;[HrefToken()];boot2=[REF(M)]'>Kick</A> | "
	if(M.client)
		body += "<A href='?_src_=holder;[HrefToken()];newbankey=[M.key];newbanip=[M.client.address];newbancid=[M.client.computer_id]'>Ban</A> | "
	else
		body += "<A href='?_src_=holder;[HrefToken()];newbankey=[M.key]'>Ban</A> | "

	body += "<A href='?_src_=holder;[HrefToken()];showmessageckey=[M.ckey]'>Notes | Messages | Watchlist</A> | "
	if(M.client)
		body += "| <A href='?_src_=holder;[HrefToken()];sendtoprison=[REF(M)]'>Prison</A> | "
		body += "\ <A href='?_src_=holder;[HrefToken()];sendbacktolobby=[REF(M)]'>Send back to Lobby</A> | "
		var/muted = M.client.prefs.muted
		body += "<br><b>Mute: </b> "
		body += "\[<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC)?"red":"blue"]'>IC</font></a> | "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC)?"red":"blue"]'>OOC</font></a> | "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY)?"red":"blue"]'>PRAY</font></a> | "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</font></a> | "
		body += "<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</font></a> | "
		body += "(<A href='?_src_=holder;[HrefToken()];mute=[M.ckey];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL)?"red":"blue"]'>toggle all</font></a>)"

	body += "<br><br>"
	body += "<A href='?_src_=holder;[HrefToken()];jumpto=[REF(M)]'><b>Jump to</b></A> | "
	body += "<A href='?_src_=holder;[HrefToken()];getmob=[REF(M)]'>Get</A> | "
	body += "<A href='?_src_=holder;[HrefToken()];sendmob=[REF(M)]'>Send To</A>"

	body += "<br><br>"
	body += "<A href='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Traitor panel</A> | "
	body += "<A href='?_src_=holder;[HrefToken()];narrateto=[REF(M)]'>Narrate to</A> | "
	body += "<A href='?_src_=holder;[HrefToken()];subtlemessage=[REF(M)]'>Subtle message</A> | "
	body += "<A href='?_src_=holder;[HrefToken()];languagemenu=[REF(M)]'>Language Menu</A>"

	if (M.client)
		if(!isnewplayer(M))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Human
			if(ishuman(M))
				body += "<B>Human</B> | "
			else
				body += "<A href='?_src_=holder;[HrefToken()];humanone=[REF(M)]'>Humanize</A> | "

			//Monkey
			if(ismonkey(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<A href='?_src_=holder;[HrefToken()];monkeyone=[REF(M)]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='?_src_=holder;[HrefToken()];corgione=[REF(M)]'>Corgize</A> | "

			if(ishuman(M))
				body += "<A href='?_src_=holder;[HrefToken()];makeai=[REF(M)]'>Make AI</A> | "
				body += "<A href='?_src_=holder;[HrefToken()];makerobot=[REF(M)]'>Make Robot</A> | "
				body += "<A href='?_src_=holder;[HrefToken()];makealien=[REF(M)]'>Make Alien</A> | "
				body += "<A href='?_src_=holder;[HrefToken()];makeslime=[REF(M)]'>Make Slime</A> | "
				body += "<A href='?_src_=holder;[HrefToken()];makeblob=[REF(M)]'>Make Blob</A> | "

			//Simple Animals
			if(isanimal(M))
				body += "<A href='?_src_=holder;[HrefToken()];makeanimal=[REF(M)]'>Re-Animalize</A> | "
			else
				body += "<A href='?_src_=holder;[HrefToken()];makeanimal=[REF(M)]'>Animalize</A> | "

			body += "<br><br>"
			body += "<b>Rudimentary transformation:</b><font size=2><br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</font><br>"
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=observer;mob=[REF(M)]'>Observer</A> | "
			body += "\[ Alien: <A href='?_src_=holder;[HrefToken()];simplemake=drone;mob=[REF(M)]'>Drone</A>, "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=hunter;mob=[REF(M)]'>Hunter</A>, "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=sentinel;mob=[REF(M)]'>Sentinel</A>, "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=praetorian;mob=[REF(M)]'>Praetorian</A>, "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=queen;mob=[REF(M)]'>Queen</A>, "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=larva;mob=[REF(M)]'>Larva</A> \] "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=human;mob=[REF(M)]'>Human</A> "
			body += "\[ slime: <A href='?_src_=holder;[HrefToken()];simplemake=slime;mob=[REF(M)]'>Baby</A>, "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=adultslime;mob=[REF(M)]'>Adult</A> \] "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=monkey;mob=[REF(M)]'>Monkey</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=robot;mob=[REF(M)]'>Cyborg</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=cat;mob=[REF(M)]'>Cat</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=runtime;mob=[REF(M)]'>Runtime</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=corgi;mob=[REF(M)]'>Corgi</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=ian;mob=[REF(M)]'>Ian</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=crab;mob=[REF(M)]'>Crab</A> | "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=coffee;mob=[REF(M)]'>Coffee</A> | "
			body += "\[ Construct: <A href='?_src_=holder;[HrefToken()];simplemake=constructarmored;mob=[REF(M)]'>Juggernaut</A> , "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=constructbuilder;mob=[REF(M)]'>Artificer</A> , "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=constructwraith;mob=[REF(M)]'>Wraith</A> \] "
			body += "<A href='?_src_=holder;[HrefToken()];simplemake=shade;mob=[REF(M)]'>Shade</A>"
			body += "<br>"

	if (M.client)
		body += "<br><br>"
		body += "<b>Other actions:</b>"
		body += "<br>"
		body += "<A href='?_src_=holder;[HrefToken()];forcespeech=[REF(M)]'>Forcesay</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];tdome1=[REF(M)]'>Thunderdome 1</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];tdome2=[REF(M)]'>Thunderdome 2</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];tdomeadmin=[REF(M)]'>Thunderdome Admin</A> | "
		body += "<A href='?_src_=holder;[HrefToken()];tdomeobserve=[REF(M)]'>Thunderdome Observer</A> | "

	body += "<br>"
	body += "</body></html>"

	usr << browse(body, "window=adminplayeropts-[REF(M)];size=550x515")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/admin_heal(mob/living/M in GLOB.mob_list)
	set name = "Mob - Heal"
	set desc = "Heal a mob to full health"
	set category = "-GameMaster-"

	if(!check_rights())
		return

	M.fully_heal(admin_revive = TRUE)
	message_admins(span_danger("Admin [key_name_admin(usr)] healed [key_name_admin(M)]!"))
	log_admin("[key_name(usr)] healed [key_name(M)].")

/datum/admins/proc/admin_revive(mob/living/M in GLOB.mob_list)
	set name = "Mob - Revive"
	set desc = "Resuscitate a mob"
	set category = "-GameMaster-"

	if(!check_rights())
		return

	M.revive(full_heal = TRUE, admin_revive = TRUE)
	message_admins(span_danger("Admin [key_name_admin(usr)] revived [key_name_admin(M)]!"))
	log_admin("[key_name(usr)] Revived [key_name(M)].")

/datum/admins/proc/checkpq(mob/living/M in GLOB.mob_list)
	set name = "Check PQ"
	set desc = "Check a mob's PQ"
	set category = null

	if(!check_rights())
		return

	if(!M.ckey)
		to_chat(src, span_warning("There is no ckey attached to this mob."))
		return

	check_pq_menu(M.ckey)

/datum/admins/proc/admin_sleep(mob/living/M in GLOB.mob_list)
	set name = "Toggle Sleeping"
	set desc = "Toggle a mob's sleeping state"
	set category = "-GameMaster-"

	if(!check_rights())
		return

	var/S = M.IsSleeping()
	if(S)
		M.remove_status_effect(S)
		M.set_resting(FALSE, TRUE)
	else
		M.SetSleeping(999999)
	message_admins(span_danger("Admin [key_name_admin(usr)] toggled [key_name_admin(M)]'s sleeping state!"))
	log_admin("[key_name(usr)] toggled [key_name(M)]'s sleeping state.")

/datum/admins/proc/start_vote()
	set name = "Start Vote"
	set desc = "Start a vote"
	set category = "-Server-"

	if(!check_rights(R_POLL))
		to_chat(usr, span_warning("You do not have the rights to start a vote."))
		return

	var/list/allowed_modes = list("End Round", "Gamemode", "Custom")

	var/type = input("What kind of vote?") as null|anything in allowed_modes
	switch(type)
		if("Gamemode")
			type = "gamemode"
		if("End Round")
			type = "endround"
		if("Custom")
			type = "custom"
	SSvote.initiate_vote(type, usr.key)

/datum/admins/proc/adjustpq(mob/living/M in GLOB.mob_list)
	set name = "Adjust PQ of Anything"
	set desc = "Adjust a player's PQ"
	set category = "-GameMaster-"
	set hidden = 1

	if(!check_rights())
		return
	
	if(!M.ckey)
		to_chat(src, span_warning("There is no ckey attached to this mob."))
		return

	var/ckey = lowertext(M.ckey)
	var/admin = lowertext(usr.key)

	/*if(ckey == admin)
		to_chat(src, span_boldwarning("That's you!"))
		return
	*/
	if(!fexists("data/player_saves/[copytext(ckey,1,2)]/[ckey]/preferences.sav"))
		to_chat(src, span_boldwarning("User does not exist."))
		return
	var/amt2change = input("How much to modify the PQ by? (20 to -20, or 0 to just add a note)") as null|num
	if(!check_rights(R_ADMIN,0))
		amt2change = CLAMP(amt2change, -20, 20)
	var/raisin = stripped_input("State a short reason for this change", "Game Master", "", null)
	if(!amt2change && !raisin)
		return
	adjust_playerquality(amt2change, ckey, admin, raisin)
	to_chat(M.client, "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message linkify\">Your PQ has been adjusted by [amt2change] by [admin] for reason: [raisin]</span></span>")

/datum/admins/proc/Game()
	if(!check_rights(0))
		return

	var/dat = "<html><meta charset='UTF-8'><head><title>Game Panel</title></head><body>"
	dat += {"
		<center><B>Game Panel</B></center><hr>\n
		<A href='?src=[REF(src)];[HrefToken()];c_mode=1'>Change Game Mode</A><br>
		"}
	if(GLOB.master_mode == "secret")
		dat += "<A href='?src=[REF(src)];[HrefToken()];f_secret=1'>(Force Secret Mode)</A><br>"
	if(GLOB.master_mode == "dynamic")
		if(SSticker.current_state <= GAME_STATE_PREGAME)
			dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart=1'>(Force Roundstart Rulesets)</A><br>"
			if (GLOB.dynamic_forced_roundstart_ruleset.len > 0)
				for(var/datum/dynamic_ruleset/roundstart/rule in GLOB.dynamic_forced_roundstart_ruleset)
					dat += {"<A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_remove=\ref[rule]'>-> [rule.name] <-</A><br>"}
				dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_clear=1'>(Clear Rulesets)</A><br>"
			dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_options=1'>(Dynamic mode options)</A><br>"
		else if (SSticker.IsRoundInProgress())
			dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_latejoin=1'>(Force Next Latejoin Ruleset)</A><br>"
			if (SSticker && SSticker.mode && istype(SSticker.mode,/datum/game_mode/dynamic))
				var/datum/game_mode/dynamic/mode = SSticker.mode
				if (mode.forced_latejoin_rule)
					dat += {"<A href='?src=[REF(src)];[HrefToken()];f_dynamic_latejoin_clear=1'>-> [mode.forced_latejoin_rule.name] <-</A><br>"}
			dat += "<A href='?src=[REF(src)];[HrefToken()];f_dynamic_midround=1'>(Execute Midround Ruleset!)</A><br>"
		dat += "<hr/>"
	if(SSticker.IsRoundInProgress())
		dat += "<a href='?src=[REF(src)];[HrefToken()];gamemode_panel=1'>(Game Mode Panel)</a><BR>"
	dat += {"
		<BR>
		<A href='?src=[REF(src)];[HrefToken()];create_object=1'>Create Object</A><br>
		<A href='?src=[REF(src)];[HrefToken()];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=[REF(src)];[HrefToken()];create_turf=1'>Create Turf</A><br>
		<A href='?src=[REF(src)];[HrefToken()];create_mob=1'>Create Mob</A><br>
		"}

	if(marked_datum && istype(marked_datum, /atom))
		dat += "<A href='?src=[REF(src)];[HrefToken()];dupe_marked_datum=1'>Duplicate Marked Datum</A><br>"

	dat += "</body></html>"
	usr << browse(dat, "window=admin2;size=240x280")
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "-Server-"
	set name = "Reboot World"
	set desc="Restarts the world immediately"
	if (!usr.client.holder)
		return

	var/list/options = list("Regular Restart", "Hard Restart (No Delay/Feeback Reason)", "Hardest Restart (No actions, just reboot)")
	if(world.TgsAvailable())
		options += "Server Restart (Kill and restart DD)";

	var/rebootconfirm
	if(SSticker.admin_delay_notice)
		if(alert(usr, "Are you sure? An admin has already delayed the round end for the following reason: [SSticker.admin_delay_notice]", "Confirmation", "Yes", "No") == "Yes")
			rebootconfirm = TRUE
	else
		rebootconfirm = TRUE
	if(rebootconfirm)
		var/result = input(usr, "Select reboot method", "World Reboot", options[1]) as null|anything in options
		if(result)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Reboot World") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			var/init_by = "Initiated by Admin."
			switch(result)
				if("Regular Restart")
					SSticker.Reboot(init_by, "admin reboot - by Admin", 10)
				if("Hard Restart (No Delay, No Feeback Reason)")
					to_chat(world, "World reboot - [init_by]")
					world.Reboot()
				if("Hardest Restart (No actions, just reboot)")
					to_chat(world, "Hard world reboot - [init_by]")
					world.Reboot(fast_track = TRUE)
				if("Server Restart (Kill and restart DD)")
					to_chat(world, "Server restart - [init_by]")
					world.TgsEndProcess()

/datum/admins/proc/end_round()
	set category = "-Server-"
	set name = "End Round"
	set desc = ""

	if (!usr.client.holder)
		return
	var/confirm = alert("End the round and restart the game world?", "End Round", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		SSticker.force_ending = 1
		SSblackbox.record_feedback("tally", "admin_verb", 1, "End Round") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/announce()
	set category = "-Special Verbs-"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))
		return

	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if(message)
		if(!check_rights(R_SERVER,0))
			message = adminscrub(message,500)
		to_chat(world, "<span class='adminnotice'><b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b></span>\n \t [message]")
		log_admin("Announce: [key_name(usr)] : [message]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Announce") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/set_admin_notice()
	set category = "-Server-"
	set name = "Set Admin Notice"
	set desc ="Set an announcement that appears to everyone who joins the server. Only lasts this round"
	if(!check_rights(0))
		return

	var/new_admin_notice = input(src,"Set a public notice for this round. Everyone who joins the server will see it.\n(Leaving it blank will delete the current notice):","Set Notice",GLOB.admin_notice) as message|null
	if(new_admin_notice == null)
		return
	if(new_admin_notice == GLOB.admin_notice)
		return
	if(new_admin_notice == "")
		message_admins("[key_name(usr)] removed the admin notice.")
		log_admin("[key_name(usr)] removed the admin notice:\n[GLOB.admin_notice]")
	else
		message_admins("[key_name(usr)] set the admin notice.")
		log_admin("[key_name(usr)] set the admin notice:\n[new_admin_notice]")
		to_chat(world, span_adminnotice("<b>Admin Notice:</b>\n \t [new_admin_notice]"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Admin Notice") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	GLOB.admin_notice = new_admin_notice
	return

/datum/admins/proc/toggleooc()
	set category = "-Server-"
	set desc="Toggle dis bitch"
	set name="Toggle OOC"
	toggle_ooc()
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle OOC", "[GLOB.ooc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleoocdead()
	set category = "-Server-"
	set desc="Toggle dis bitch"
	set name="Toggle Dead OOC"
	toggle_dooc()

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Dead OOC", "[GLOB.dooc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "-Server-"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(SSticker.current_state == GAME_STATE_PREGAME || SSticker.current_state == GAME_STATE_STARTUP)
		SSticker.start_immediately = TRUE
		log_admin("[usr.key] has started the game.")
		var/msg = ""
		if(SSticker.current_state == GAME_STATE_STARTUP)
			msg = " (The server is still setting up, but the round will be \
				started as soon as possible.)"
		message_admins("<font color='blue'>\
			[usr.key] has started the game.[msg]</font>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Now") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		to_chat(usr, "<font color='red'>Error: Start Now: Game has already started.</font>")

	return 0

/datum/admins/proc/forcemode()
	set category = "-Server-"
	set name = "Force Gamemode"

	if(SSticker.current_state == GAME_STATE_PREGAME || SSticker.current_state == GAME_STATE_STARTUP)
		if(alert("Enter Manual Gamemode Selection? Will disable random generation",,"Yes","No") == "Yes")
			for(var/I in 1 to 10)
				var/choice = input(usr, "Select Gamemodes", "Select Gamemodes") as anything in roguegamemodes|null
				if(!choice || choice == "CANCEL")
					message_admins("<font color='blue'>\
						[usr.key] has forced the gamemode.</font>")
					return
				SSticker.manualmodes |= choice
				roguegamemodes -= choice
	else
		to_chat(usr, "<font color='red'>Error: Force Modes: Game has already started.</font>")

	return 0
/datum/admins/proc/toggleenter()
	set category = "-Server-"
	set desc="People can't enter"
	set name="Toggle Entering"
	GLOB.enter_allowed = !( GLOB.enter_allowed )
	if (!( GLOB.enter_allowed ))
		to_chat(world, "<B>New players may no longer enter the game.</B>")
	else
		to_chat(world, "<B>New players may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins(span_adminnotice("[key_name_admin(usr)] toggled new player game entering."))
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Entering", "[GLOB.enter_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "-Server-"
	set desc="People can't be AI"
	set name="Toggle AI"
	set hidden = 1
	var/alai = CONFIG_GET(flag/allow_ai)
	CONFIG_SET(flag/allow_ai, !alai)
	if (alai)
		to_chat(world, "<B>The AI job is no longer chooseable.</B>")
	else
		to_chat(world, "<B>The AI job is chooseable now.</B>")
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle AI", "[!alai ? "Disabled" : "Enabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "-Server-"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	set hidden = 1
	var/new_nores = !CONFIG_GET(flag/norespawn)
	CONFIG_SET(flag/norespawn, new_nores)
	if (!new_nores)
		to_chat(world, "<B>I may now respawn.</B>")
	else
		to_chat(world, "<B>I may no longer respawn :(</B>")
	message_admins(span_adminnotice("[key_name_admin(usr)] toggled respawn to [!new_nores ? "On" : "Off"]."))
	log_admin("[key_name(usr)] toggled respawn to [!new_nores ? "On" : "Off"].")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Respawn", "[!new_nores ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "-Server-"
	set desc="Delay the game start"
	set name="Delay pre-game"

	var/newtime = input("Set a new time in seconds. Set -1 for indefinite delay.","Set Delay",round(SSticker.GetTimeLeft()/10)) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return alert("Too late... The game has already started!")
	if(newtime)
		newtime = newtime*10
		SSticker.SetTimeLeft(newtime)
		if(newtime < 0)
			to_chat(world, "<b>The game start has been delayed.</b>")
			log_admin("[key_name(usr)] delayed the round start.")
		else
			to_chat(world, "<b>The game will start in [DisplayTimeText(newtime)].</b>")
			SEND_SOUND(world, sound('sound/blank.ogg'))
			log_admin("[key_name(usr)] set the pre-game delay to [DisplayTimeText(newtime)].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delay Game Start") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/unprison(mob/M in GLOB.mob_list)
	set category = "-Admin-"
	set name = "Unprison"
	if (is_centcom_level(M.z))
		SSjob.SendToLateJoin(M)
		message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]")
		log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
	else
		alert("[M.name] is not prisoned.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Unprison") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/datum/admins/proc/spawn_atom(object as text)
	set category = "-GameMaster-"
	set desc = ""
	set name = "Spawn..."

	if(!check_rights(R_SPAWN) || !object)
		return

	var/list/preparsed = splittext(object,":")
	var/path = preparsed[1]
	var/amount = 1
	if(preparsed.len > 1)
		amount = CLAMP(text2num(preparsed[2]),1,ADMIN_SPAWN_CAP)

	var/chosen = pick_closest_path(path)
	if(!chosen)
		return
	var/turf/T = get_turf(usr)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		for(var/i in 1 to amount)
			var/atom/A = new chosen(T)
			A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(usr)] spawned [amount] x [chosen] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Atom") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/podspawn_atom(object as text)
	set category = "Debug"
	set desc = ""
	set name = "Podspawn"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object)
	if(!chosen)
		return
	var/turf/T = get_turf(usr)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		var/obj/structure/closet/supplypod/centcompod/pod = new()
		var/atom/A = new chosen(pod)
		A.flags_1 |= ADMIN_SPAWNED_1
		new /obj/effect/DPtarget(T, pod)

	log_admin("[key_name(usr)] pod-spawned [chosen] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Podspawn Atom") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/spawn_cargo(object as text)
	set category = "Debug"
	set desc = ""
	set name = "Spawn Cargo"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/datum/supply_pack)))
	if(!chosen)
		return
	var/datum/supply_pack/S = new chosen
	S.admin_spawned = TRUE
	S.generate(get_turf(usr))

	log_admin("[key_name(usr)] spawned cargo pack [chosen] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Cargo") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(mob/M in GLOB.mob_list)
	set category = "-Admin-"
	set desc = ""
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.traitor_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Traitor Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmes"
	GLOB.tinted_weldhelh = !( GLOB.tinted_weldhelh )
	if (GLOB.tinted_weldhelh)
		to_chat(world, "<B>The tinted_weldhelh has been enabled!</B>")
	else
		to_chat(world, "<B>The tinted_weldhelh has been disabled!</B>")
	log_admin("[key_name(usr)] toggled tinted_weldhelh.")
	message_admins("[key_name_admin(usr)] toggled tinted_weldhelh.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Tinted Welding Helmets", "[GLOB.tinted_weldhelh ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "-Server-"
	set desc="Guests can't enter"
	set name="Toggle guests"
	set hidden = 1
	var/new_guest_ban = !CONFIG_GET(flag/guest_ban)
	CONFIG_SET(flag/guest_ban, new_guest_ban)
	if (new_guest_ban)
		to_chat(world, "<B>Guests may no longer enter the game.</B>")
	else
		to_chat(world, "<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed.")
	message_admins(span_adminnotice("[key_name_admin(usr)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed."))
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Guests", "[!new_guest_ban ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/manage_free_slots()
	if(!check_rights())
		return
	var/datum/browser/browser = new(usr, "jobmanagement", "Manage Free Slots", 520)
	var/list/dat = list()
	var/count = 0

	if(!SSjob.initialized)
		alert(usr, "You cannot manage jobs before the job subsystem is initialized!")
		return

	dat += "<table>"

	for(var/j in SSjob.occupations)
		var/datum/job/job = j
		count++
		var/J_title = html_encode(job.title)
		var/J_opPos = html_encode(job.total_positions - (job.total_positions - job.current_positions))
		var/J_totPos = html_encode(job.total_positions)
		dat += "<tr><td>[J_title]:</td> <td>[J_opPos]/[job.total_positions < 0 ? " (unlimited)" : J_totPos]"

		dat += "</td>"
		dat += "<td>"
		if(job.total_positions >= 0)
			dat += "<A href='?src=[REF(src)];[HrefToken()];customjobslot=[job.title]'>Custom</A> | "
			dat += "<A href='?src=[REF(src)];[HrefToken()];addjobslot=[job.title]'>Add 1</A> | "
			if(job.total_positions > job.current_positions)
				dat += "<A href='?src=[REF(src)];[HrefToken()];removejobslot=[job.title]'>Remove</A> | "
			else
				dat += "Remove | "
			dat += "<A href='?src=[REF(src)];[HrefToken()];unlimitjobslot=[job.title]'>Unlimit</A></td>"
		else
			dat += "<A href='?src=[REF(src)];[HrefToken()];limitjobslot=[job.title]'>Limit</A></td>"

	browser.height = min(100 + count * 20, 650)
	browser.set_content(dat.Join())
	browser.open()

/datum/admins/proc/dynamic_mode_options(mob/user)
	var/dat = {"
		<center><B><h2>Dynamic Mode Options</h2></B></center><hr>
		<br/>
		<h3>Common options</h3>
		<i>All these options can be changed midround.</i> <br/>
		<br/>
		<b>Force extended:</b> - Option is <a href='?src=[REF(src)];[HrefToken()];f_dynamic_force_extended=1'> <b>[GLOB.dynamic_forced_extended ? "ON" : "OFF"]</a></b>.
		<br/>This will force the round to be extended. No rulesets will be drafted. <br/>
		<br/>
		<b>No stacking:</b> - Option is <a href='?src=[REF(src)];[HrefToken()];f_dynamic_no_stacking=1'> <b>[GLOB.dynamic_no_stacking ? "ON" : "OFF"]</b></a>.
		<br/>Unless the threat goes above [GLOB.dynamic_stacking_limit], only one "round-ender" ruleset will be drafted. <br/>
		<br/>
		<b>Classic secret mode:</b> - Option is <a href='?src=[REF(src)];[HrefToken()];f_dynamic_classic_secret=1'> <b>[GLOB.dynamic_classic_secret ? "ON" : "OFF"]</b></a>.
		<br/>Only one roundstart ruleset will be drafted. Only traitors and minor roles will latespawn. <br/>
		<br/>
		<br/>
		<b>Forced threat level:</b> Current value : <a href='?src=[REF(src)];[HrefToken()];f_dynamic_forced_threat=1'><b>[GLOB.dynamic_forced_threat_level]</b></a>.
		<br/>The value threat is set to if it is higher than -1.<br/>
		<br/>
		<b>High population limit:</b> Current value : <a href='?src=[REF(src)];[HrefToken()];f_dynamic_high_pop_limit=1'><b>[GLOB.dynamic_high_pop_limit]</b></a>.
		<br/>The threshold at which "high population override" will be in effect. <br/>
		<br/>
		<b>Stacking threeshold:</b> Current value : <a href='?src=[REF(src)];[HrefToken()];f_dynamic_stacking_limit=1'><b>[GLOB.dynamic_stacking_limit]</b></a>.
		<br/>The threshold at which "round-ender" rulesets will stack. A value higher than 100 ensure this never happens. <br/>
		<h3>Advanced parameters</h3>
		Curve centre: <A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_centre=1'>-> [GLOB.dynamic_curve_centre] <-</A><br>
		Curve width: <A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_width=1'>-> [GLOB.dynamic_curve_width] <-</A><br>
		Latejoin injection delay:<br>
		Minimum: <A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_latejoin_min=1'>-> [GLOB.dynamic_latejoin_delay_min / 60 / 10] <-</A> Minutes<br>
		Maximum: <A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_latejoin_max=1'>-> [GLOB.dynamic_latejoin_delay_max / 60 / 10] <-</A> Minutes<br>
		Midround injection delay:<br>
		Minimum: <A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_midround_min=1'>-> [GLOB.dynamic_midround_delay_min / 60 / 10] <-</A> Minutes<br>
		Maximum: <A href='?src=[REF(src)];[HrefToken()];f_dynamic_roundstart_midround_max=1'>-> [GLOB.dynamic_midround_delay_max / 60 / 10] <-</A> Minutes<br>
		"}

	user << browse(dat, "window=dyn_mode_options;size=900x650")

/datum/admins/proc/create_or_modify_area()
	set category = "Debug"
	set name = "Create/Modify area"
	create_area(usr)

//
//
//ALL DONE
//*********************************************************************************************************
//TO-DO:
//
//

//RIP ferry snowflakes

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk()) //Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message)
			kicked_client_names.Add("[C.key]")
			qdel(C)
	return kicked_client_names

//returns 1 to let the dragdrop code know we are trapping this event
//returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, mob/tomob)

	//this is the exact two check rights checks required to edit a ckey with vv.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_SPAWN|R_DEBUG,0))
		return 0

	if (!frommob.ckey)
		return 0

	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"

	var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
	if (ask != "Yes")
		return 1

	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1

	tomob.ghostize(0)

	message_admins(span_adminnotice("[key_name_admin(usr)] has put [frommob.key] in control of [tomob.name]."))
	log_admin("[key_name(usr)] stuffed [frommob.key] into [tomob.name].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag Control")

	tomob.ckey = frommob.ckey
	qdel(frommob)

	return 1

/client/proc/adminGreet(logout)
	if(SSticker.HasRoundStarted())
		var/string
		if(logout && CONFIG_GET(flag/announce_admin_logout))
			string = pick(
				"Admin logout: [key_name(src)]")
		else if(!logout && CONFIG_GET(flag/announce_admin_login) && (prefs.toggles & ANNOUNCE_LOGIN))
			string = pick(
				"Admin login: [key_name(src)]")
		if(string)
			message_admins("[string]")


/client/proc/returntolobby()
	set category = "-Special Verbs-"
	set name = "Back to Lobby"

	var/mob/living/carbon/human/H = mob
	var/datum/job/mob_job
	var/target_job = SSrole_class_handler.get_advclass_by_name(H.advjob)

	if(H.mind)
		mob_job = SSjob.GetJob(H.mind.assigned_role)
		if(mob_job)
			mob_job.current_positions = max(0, mob_job.current_positions - 1)
		if(target_job)
			SSrole_class_handler.adjust_class_amount(target_job, -1)
		H.mind.unknow_all_people()
		for(var/datum/mind/MF in get_minds())
			H.mind.become_unknown_to(MF)
		for(var/datum/bounty/removing_bounty in GLOB.head_bounties)
			if(removing_bounty.target == H.real_name)
				GLOB.head_bounties -= removing_bounty
	else
		alert(usr, "Target has no mind!") // Optional Error check that may or may not be neccessary
	GLOB.chosen_names -= H.real_name
	LAZYREMOVE(GLOB.actors_list, H.mobid)
	LAZYREMOVE(GLOB.roleplay_ads, H.mobid)
	H.returntolobby()


/datum/admins/proc/sleep_view()
	set name = "inview Sleep"
	set category = "-GameMaster-"
	set hidden = FALSE

	if(!check_rights(R_ADMIN))
		return

	if(alert("This will sleep ALL mobs within your view range. Are you sure?",,"Yes","Cancel") == "Cancel")
		return
	for(var/mob/living/M in view(usr.client))
		M.SetSleeping(999999)

	message_admins("[key_name(usr)] used Toggle Sleep In View.")

/datum/admins/proc/wake_view()
	set name = "inview Wake"
	set category = "-GameMaster-"
	set hidden = FALSE

	if(!check_rights(R_ADMIN))
		return

	if(alert("This wake ALL mobs within your view range. Are you sure?",,"Yes","Cancel") == "Cancel")
		return
	for(var/mob/living/M in view(usr.client))
		var/S = M.IsSleeping()
		if(S)
			M.remove_status_effect(S)
			M.set_resting(FALSE, TRUE)

	message_admins("[key_name(usr)] used Toggle Wake In View.")
