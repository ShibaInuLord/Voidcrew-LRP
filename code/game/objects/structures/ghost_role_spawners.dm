//Objects that spawn ghosts in as a certain role when they click on it, i.e. away mission bartenders.

//Preserved terrarium/seed vault: Spawns in seed vault structures in lavaland. Ghosts become plantpeople and are advised to begin growing plants in the room near them.
/obj/effect/mob_spawn/human/seed_vault
	name = "preserved terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. The glass is obstructed by a mat of vines."
	mob_name = "a lifebringer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium"
	density = TRUE
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/pod
	short_desc = "You are a sentient ecosystem, an example of the mastery over life that your creators possessed."
	flavour_text = "Your masters, benevolent as they were, created uncounted seed vaults and spread them across \
	the universe to every planet they could chart. You are in one such seed vault. \
	Your goal is to cultivate and spread life wherever it will go while waiting for contact from your creators. \
	Estimated time of last contact: Deployment, 5000 millennia ago."
	assignedrole = "Lifebringer"

/obj/effect/mob_spawn/human/seed_vault/Initialize(mapload)
	. = ..()
	notify_ghosts("A preserved Terrarium is available", flashwindow = FALSE, notify_suiciders = FALSE)

/obj/effect/mob_spawn/human/seed_vault/special(mob/living/new_spawn)
	var/plant_name = pick("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout","Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")
	new_spawn.fully_replace_character_name(null,plant_name)
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.underwear = "Nude" //You're a plant, partner
		H.update_body()

/obj/effect/mob_spawn/human/seed_vault/Destroy()
	new/obj/structure/fluff/empty_terrarium(get_turf(src))
	return ..()

//Ash walker eggs: Spawns in ash walker dens in lavaland. Ghosts become unbreathing lizards that worship the Necropolis and are advised to retrieve corpses to create more ash walkers.

/obj/structure/ash_walker_eggshell
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within. The egg shell looks resistant to temperature but otherwise rather brittle."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF
	max_integrity = 80
	var/obj/effect/mob_spawn/human/ash_walker/egg

/obj/structure/ash_walker_eggshell/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0) //lifted from xeno eggs
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/ash_walker_eggshell/attack_ghost(mob/user) //Pass on ghost clicks to the mob spawner
	if(egg)
		egg.attack_ghost(user)
	. = ..()

/obj/structure/ash_walker_eggshell/Destroy()
	if(!egg)
		return ..()
	var/mob/living/carbon/human/yolk = new /mob/living/carbon/human/(get_turf(src))
	yolk.fully_replace_character_name(null,random_unique_lizard_name(gender))
	yolk.set_species(/datum/species/lizard/ashwalker/kobold) //WS Edit - Kobold
	yolk.underwear = "Nude"
	yolk.equipOutfit(/datum/outfit/ashwalker)//this is an authentic mess we're making
	yolk.update_body()
	yolk.gib()
	qdel(egg)
	return ..()


/obj/effect/mob_spawn/human/ash_walker
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within."
	mob_name = "an ash walker"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/lizard/ashwalker/kobold //WS Edit - Kobold
	outfit = /datum/outfit/ashwalker
	roundstart = FALSE
	death = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	short_desc = "You are an ash walker. Your tribe worships the Necropolis."
	flavour_text = "The wastes are sacred ground, its monsters a blessed bounty. \
	The invaders from the past have died long ago. You will survive until the next \
	day, and the day after. Your way of life is important to you."
	assignedrole = "Ash Walker"
	var/datum/team/ashwalkers/team
	var/obj/structure/ash_walker_eggshell/eggshell

/obj/effect/mob_spawn/human/ash_walker/allow_spawn(mob/user)
	if(!(user.key in team.players_spawned))//one per person unless you get a bonus spawn
		return TRUE
	to_chat(user, "<span class='warning'><b>You have exhausted your usefulness to the Necropolis</b>.</span>")
	return FALSE

/obj/effect/mob_spawn/human/ash_walker/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(null,random_unique_lizard_name(gender))
	to_chat(new_spawn, "<b>Drag the corpses of beasts and the dead to your nest. It will absorb them to create more of your kind. You have never seen a outsider before, as that was before your time.</b>")

	new_spawn.mind.add_antag_datum(/datum/antagonist/ashwalker, team)

	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.underwear = "Nude"
		H.update_body()
		ADD_TRAIT(H, TRAIT_PRIMITIVE, ROUNDSTART_TRAIT)
	team.players_spawned += (new_spawn.key)
	eggshell.egg = null
	qdel(eggshell)

/obj/effect/mob_spawn/human/ash_walker/Initialize(mapload, datum/team/ashwalkers/ashteam)
	. = ..()
	var/area/A = get_area(src)
	team = ashteam
	eggshell = new /obj/structure/ash_walker_eggshell(get_turf(loc))
	eggshell.egg = src
	src.forceMove(eggshell)
	if(A)
		notify_ghosts("An ash walker egg is ready to hatch in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_ASHWALKER)

/datum/outfit/ashwalker
	name ="Ashwalker"
	head = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker


//Timeless prisons: Spawns in Wish Granter prisons in lavaland. Ghosts become age-old users of the Wish Granter and are advised to seek repentance for their past.
/obj/effect/mob_spawn/human/exile
	name = "timeless prison"
	desc = "Although this stasis pod looks medicinal, it seems as though it's meant to preserve something for a very long time."
	mob_name = "a penitent exile"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/shadow
	short_desc = "You are cursed."
	flavour_text = "Years ago, you sacrificed the lives of your trusted friends and the humanity of yourself to reach the Wish Granter. Though you \
	did so, it has come at a cost: your very body rejects the light, dooming you to wander endlessly in this horrible wasteland."
	assignedrole = "Exile"

/obj/effect/mob_spawn/human/exile/Destroy()
	new/obj/structure/fluff/empty_sleeper(get_turf(src))
	return ..()

/obj/effect/mob_spawn/human/exile/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(null,"Wish Granter's Victim ([rand(1,999)])")
	var/wish = rand(1,4)
	switch(wish)
		if(1)
			to_chat(new_spawn, "<b>You wished to kill, and kill you did. You've lost track of how many, but the spark of excitement that murder once held has winked out. You feel only regret.</b>")
		if(2)
			to_chat(new_spawn, "<b>You wished for unending wealth, but no amount of money was worth this existence. Maybe charity might redeem your soul?</b>")
		if(3)
			to_chat(new_spawn, "<b>You wished for power. Little good it did you, cast out of the light. You are the [gender == MALE ? "king" : "queen"] of a hell that holds no subjects. You feel only remorse.</b>")
		if(4)
			to_chat(new_spawn, "<b>You wished for immortality, even as your friends lay dying behind you. No matter how many times you cast yourself into the lava, you awaken in this room again within a few days. There is no escape.</b>")

//Golem shells: Spawns in Free Golem ships in lavaland. Ghosts become mineral golems and are advised to spread personal freedom.
/obj/effect/mob_spawn/human/golem
	name = "inert free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species = /datum/species/golem
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	var/has_owner = FALSE
	var/can_transfer = TRUE //if golems can switch bodies to this new shell
	var/mob/living/owner = null //golem's owner if it has one
	short_desc = "You are a Free Golem. Your family worships The Liberator."
	flavour_text = "In his infinite and divine wisdom, he set your clan free to \
	travel the stars with a single declaration: \"Yeah go do whatever.\" Though you are bound to the one who created you, it is customary in your society to repeat those same words to newborn \
	golems, so that no golem may ever be forced to serve again."

/obj/effect/mob_spawn/human/golem/Initialize(mapload, datum/species/golem/species = null, mob/creator = null)
	notify_ghosts("A free golem shell is now available", flashwindow = FALSE, notify_suiciders = FALSE)
	if(species) //spawners list uses object name to register so this goes before ..()
		name += " ([initial(species.prefix)])"
		mob_species = species
	. = ..()
	var/area/A = get_area(src)
	if(!mapload && A)
		notify_ghosts("\A [initial(species.prefix)] golem shell has been completed in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	if(has_owner && creator)
		short_desc = "You are a golem."
		flavour_text = "You move slowly, but are highly resistant to heat and cold as well as blunt trauma. You are unable to wear clothes, but can still use most tools."
		important_info = "Serve [creator], and assist [creator.p_them()] in completing [creator.p_their()] goals at any cost."
		owner = creator

/obj/effect/mob_spawn/human/golem/special(mob/living/new_spawn, name)
	var/datum/species/golem/X = mob_species
	to_chat(new_spawn, "[initial(X.info_text)]")
	if(!owner)
		to_chat(new_spawn, "Build golem shells in the autolathe, and feed refined mineral sheets to the shells to bring them to life! You are generally a peaceful group unless provoked.")
	else
		new_spawn.mind.store_memory("<b>Serve [owner.real_name], your creator.</b>")
		new_spawn.mind.enslave_mind_to_creator(owner)
		log_game("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
		log_admin("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		if(has_owner)
			var/datum/species/golem/G = H.dna.species
			G.owner = owner
		H.set_cloned_appearance()
		if(!name)
			if(has_owner)
				H.fully_replace_character_name(null, "[initial(X.prefix)] Golem ([rand(1,999)])")
			else
				H.fully_replace_character_name(null, H.dna.species.random_name())
		else
			H.fully_replace_character_name(null, name)
	if(has_owner)
		new_spawn.mind.assigned_role = "Servant Golem"
	else
		new_spawn.mind.assigned_role = "Free Golem"

/obj/effect/mob_spawn/human/golem/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(isgolem(user) && can_transfer)
		var/mob/living/carbon/human/H = user
		var/transfer_choice = alert("Transfer your soul to [src]? (Warning, your old body will die!)",,"Yes","No")
		if(transfer_choice != "Yes")
			return
		if(QDELETED(src) || uses <= 0)
			return
		log_game("[key_name(H)] golem-swapped into [src]")
		H.visible_message("<span class='notice'>A faint light leaves [H], moving to [src] and animating it!</span>","<span class='notice'>You leave your old body behind, and transfer into [src]!</span>")
		show_flavour = FALSE
		var/mob/living/carbon/human/newgolem = create(newname = H.real_name)
		H.transfer_trait_datums(newgolem)
		H.mind.transfer_to(newgolem)
		H.death()
		return

/obj/effect/mob_spawn/human/golem/servant
	has_owner = TRUE
	name = "inert servant golem shell"
	mob_name = "a servant golem"


/obj/effect/mob_spawn/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	can_transfer = FALSE
	mob_species = /datum/species/golem/adamantine

//Malfunctioning cryostasis sleepers: Spawns in makeshift shelters in lavaland. Ghosts become hermits with knowledge of how they got to where they are now.
/obj/effect/mob_spawn/human/hermit
	name = "malfunctioning cryostasis sleeper"
	desc = "A humming sleeper with a silhouetted occupant inside. Its stasis function is broken and it's likely being used as a bed."
	mob_name = "a stranded hermit"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	outfit = /datum/outfit/hermit
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You've been stranded in this godless prison of a planet for longer than you can remember."
	flavour_text = "Each day you barely scrape by, and between the terrible conditions of your makeshift shelter, \
	the hostile creatures, and the ash drakes swooping down from the cloudless skies, all you can wish for is the feel of soft grass between your toes and \
	the fresh air of Earth. These thoughts are dispelled by yet another recollection of how you got here... "
	assignedrole = "Hermit"

/obj/effect/mob_spawn/human/hermit/Initialize(mapload)
	notify_ghosts("A malfunctioning cryostasis sleeper is available", flashwindow = FALSE, notify_suiciders = FALSE)
	. = ..()
	var/arrpee = rand(1,4)
	switch(arrpee)
		if(1)
			flavour_text += "you were a [pick("arms dealer", "shipwright", "docking manager")]'s assistant on a small trading station several sectors from here. Raiders attacked, and there was \
			only one pod left when you got to the escape bay. You took it and launched it alone, and the crowd of terrified faces crowding at the airlock door as your pod's engines burst to \
			life and sent you to this hell are forever branded into your memory."
			outfit.uniform = /obj/item/clothing/under/misc/assistantformal
		if(2)
			flavour_text += "you're an exile from the Tiger Cooperative. Their technological fanaticism drove you to question the power and beliefs of the Exolitics, and they saw you as a \
			heretic and subjected you to hours of horrible torture. You were hours away from execution when a high-ranking friend of yours in the Cooperative managed to secure you a pod, \
			scrambled its destination's coordinates, and launched it. You awoke from stasis when you landed and have been surviving - barely - ever since."
			outfit.uniform = /obj/item/clothing/under/rank/prisoner
			outfit.shoes = /obj/item/clothing/shoes/sneakers/orange
		if(3)
			flavour_text += "you were a doctor on one of Nanotrasen's space stations, but you left behind that damn corporation's tyranny and everything it stood for. From a metaphorical hell \
			to a literal one, you find yourself nonetheless missing the recycled air and warm floors of what you left behind... but you'd still rather be here than there."
			outfit.uniform = /obj/item/clothing/under/rank/medical/doctor
			outfit.suit = /obj/item/clothing/suit/toggle/labcoat
			outfit.back = /obj/item/storage/backpack/medic
		if(4)
			flavour_text += "you were always joked about by your friends for \"not playing with a full deck\", as they so <i>kindly</i> put it. It seems that they were right when you, on a tour \
			at one of Nanotrasen's state-of-the-art research facilities, were in one of the escape pods alone and saw the red button. It was big and shiny, and it caught your eye. You pressed \
			it, and after a terrifying and fast ride for days, you landed here. You've had time to wisen up since then, and you think that your old friends wouldn't be laughing now."

/obj/effect/mob_spawn/human/hermit/Destroy()
	new/obj/structure/fluff/empty_cryostasis_sleeper(get_turf(src))
	return ..()

/datum/outfit/hermit
	name = "Lavaland hermit"
	uniform = /obj/item/clothing/under/color/grey/ancient
	shoes = /obj/item/clothing/shoes/sneakers/black
	back = /obj/item/storage/backpack
	mask = /obj/item/clothing/mask/breath
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	r_pocket = /obj/item/flashlight/glowstick

//Prisoner containment sleeper: Spawns in crashed prison ships in lavaland. Ghosts become escaped prisoners and are advised to find a way out of the mess they've gotten themselves into.
/obj/effect/mob_spawn/human/prisoner_transport
	name = "prisoner containment sleeper"
	desc = "A sleeper designed to put its occupant into a deep coma, unbreakable until the sleeper turns off. This one's glass is cracked and you can see a pale, sleeping face staring out."
	mob_name = "an escaped prisoner"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/lavalandprisoner
	roundstart = FALSE
	death = FALSE
	short_desc = "You're a prisoner, sentenced to hard work in one of Nanotrasen's labor camps, but it seems as \
	though fate has other plans for you."
	flavour_text = "Good. It seems as though your ship crashed. You remember that you were convicted of "
	assignedrole = "Escaped Prisoner"

/obj/effect/mob_spawn/human/prisoner_transport/special(mob/living/L)
	L.fully_replace_character_name(null,"NTP #LL-0[rand(111,999)]") //Nanotrasen Prisoner #Lavaland-(numbers)

/obj/effect/mob_spawn/human/prisoner_transport/Initialize(mapload)
	. = ..()
	var/list/crimes = list("murder", "larceny", "embezzlement", "unionization", "dereliction of duty", "kidnapping", "gross incompetence", "grand theft", "collaboration with the Syndicate", \
	"worship of a forbidden deity", "interspecies relations", "mutiny")
	flavour_text += "[pick(crimes)]. but regardless of that, it seems like your crime doesn't matter now. You don't know where you are, but you know that it's out to kill you, and you're not going \
	to lose this opportunity. Find a way to get out of this mess and back to where you rightfully belong - your [pick("house", "apartment", "spaceship", "station")]."

/datum/outfit/lavalandprisoner
	name = "Lavaland Prisoner"
	uniform = /obj/item/clothing/under/rank/prisoner
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/tank/internals/emergency_oxygen


/obj/effect/mob_spawn/human/prisoner_transport/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

//Space Hotel Staff
/obj/effect/mob_spawn/human/hotel_staff //not free antag u little shits
	name = "staff sleeper"
	desc = "A sleeper designed for long-term stasis between guest visits."
	mob_name = "hotel staff member"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	objectives = "Cater to visiting guests with your fellow staff. Do not leave your assigned hotel and always remember: The customer is always right!"
	death = FALSE
	roundstart = FALSE
	random = TRUE
	outfit = /datum/outfit/hotelstaff
	short_desc = "You are a staff member of a top-of-the-line space hotel!"
	flavour_text = "You are a staff member of a top-of-the-line space hotel! Cater to guests and make sure the manager doesn't fire you."
	important_info = "DON'T leave the hotel"
	assignedrole = "Hotel Staff"

/datum/outfit/hotelstaff
	name = "Hotel Staff"
	uniform = /obj/item/clothing/under/misc/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield)

/obj/effect/mob_spawn/human/hotel_staff/security
	name = "hotel security sleeper"
	mob_name = "hotel security member"
	outfit = /datum/outfit/hotelstaff/security
	short_desc = "You are a peacekeeper."
	flavour_text = "You have been assigned to this hotel to protect the interests of the company while keeping the peace between \
		guests and the staff."
	important_info = "Do NOT leave the hotel, as that is grounds for contract termination."
	objectives = "Do not leave your assigned hotel. Try and keep the peace between staff and guests, non-lethal force heavily advised if possible."

/datum/outfit/hotelstaff/security
	name = "Hotel Security"
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	head = /obj/item/clothing/head/helmet/blueshirt
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full

/obj/effect/mob_spawn/human/hotel_staff/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	..()

/obj/effect/mob_spawn/human/demonic_friend
	name = "Essence of friendship"
	desc = "Oh boy! Oh boy! A friend!"
	mob_name = "Demonic friend"
	icon = 'icons/obj/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	outfit = /datum/outfit/demonic_friend
	death = FALSE
	roundstart = FALSE
	random = TRUE
	id_job = "SuperFriend"
	var/obj/effect/proc_holder/spell/targeted/summon_friend/spell
	var/datum/mind/owner
	assignedrole = "SuperFriend"

/obj/effect/mob_spawn/human/demonic_friend/Initialize(mapload, datum/mind/owner_mind, obj/effect/proc_holder/spell/targeted/summon_friend/summoning_spell)
	. = ..()
	owner = owner_mind
	flavour_text = "You have been given a reprieve from your eternity of torment, to be [owner.name]'s friend for [owner.p_their()] short mortal coil."
	important_info = "Be aware that if you do not live up to [owner.name]'s expectations, they can send you back to hell with a single thought. [owner.name]'s death will also return you to hell."
	var/area/A = get_area(src)
	if(!mapload && A)
		notify_ghosts("\A friendship shell has been completed in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)
	objectives = "Be [owner.name]'s friend, and keep [owner.name] alive, so you don't get sent back to hell."
	spell = summoning_spell


/obj/effect/mob_spawn/human/demonic_friend/special(mob/living/L)
	if(!QDELETED(owner.current) && owner.current.stat != DEAD)
		L.fully_replace_character_name(null,"[owner.name]'s best friend")
		soullink(/datum/soullink/oneway, owner.current, L)
		spell.friend = L
		spell.charge_counter = spell.charge_max
		L.mind.hasSoul = FALSE
		var/mob/living/carbon/human/H = L
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = worn.GetID()
		id.registered_name = L.real_name
		id.update_label()
	else
		to_chat(L, "<span class='userdanger'>Your owner is already dead! You will soon perish.</span>")
		addtimer(CALLBACK(L, /mob.proc/dust, 150)) //Give em a few seconds as a mercy.

/datum/outfit/demonic_friend
	name = "Demonic Friend"
	uniform = /obj/item/clothing/under/misc/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield) //No revolutionaries, he's MY friend.
	id = /obj/item/card/id

/obj/effect/mob_spawn/human/syndicate
	name = "Syndicate Operative"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/syndicate_empty
	assignedrole = "Space Syndicate"	//I know this is really dumb, but Syndicate operative is nuke ops

/datum/outfit/syndicate_empty
	name = "Syndicate Operative Empty"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/weapons_auth)
	id = /obj/item/card/id/syndicate

/datum/outfit/syndicate_empty/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

//shiptest edit start, adding egors updated starfury roles, this should theoritacly not fuck with shit since this code is unused anyways
/obj/effect/mob_spawn/human/syndicate/battlecruiser
	name = "Syndicate Battlecruiser Ship Operative"
	short_desc = "You are a crewmember aboard the Syndicate flagship <i>Starfury</i>."
	flavour_text = "Your job is to follow your higher-ranking operatives' orders, assisting in pretty much anything that might need your help."
	important_info = "While you don't have a strict role, you are supposed to obey orders given by anyone on the ship, including medical, engineering and assault operatives."
	outfit = /datum/outfit/syndicate_empty/sbc
	assignedrole = "Battlecruiser Operative"
	mob_name = "syndicate operative"
	id_job = "Syndicate Operative"
	random = TRUE
	roundstart = FALSE
	death = FALSE
	anchored = TRUE
	density = FALSE

/datum/outfit/syndicate_empty/sbc
	name = "Syndicate Battlecruiser Ship Deck Assistant"
	gloves = /obj/item/clothing/gloves/combat
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/kitchen/knife/combat/survival
	belt = /obj/item/storage/belt/military/assault
	id = /obj/item/card/id/syndicate_command/crew_id
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1)

/obj/effect/mob_spawn/human/syndicate/battlecruiser/engineering
	name = "Syndicate Battlecruiser Ship Engineer"
	short_desc = "You are an engineer aboard the Syndicate flagship <i>Starfury</i>."
	flavour_text = "Your job is to maintain the ship, and keep the engine running. If you are unfamiliar with how the supermatter engine functions, do not attempt to start it alone; ask a fellow crewman for help."
	important_info = "While your role means you can help in the assault with your tools,  you must first and foremost keep the cruiser and engine in a working state."
	outfit = /datum/outfit/syndicate_empty/sbc/engi
	assignedrole = "Battlecruiser Engineer"
	mob_name = "syndicate engineer"
	id_job = "Syndicate Engineer"

/datum/outfit/syndicate_empty/sbc/engi
	name = "Syndicate Battlecruiser Ship Engineer"
	glasses = /obj/item/clothing/glasses/meson/night
	uniform = /obj/item/clothing/under/syndicate/aclfgrunt
	r_pocket = /obj/item/analyzer
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	belt = /obj/item/storage/belt/utility/syndicate
	back = /obj/item/storage/backpack/industrial
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1, /obj/item/construction/rcd/combat, /obj/item/rcd_ammo/large, /obj/item/stack/sheet/mineral/plastitanium=50)

/obj/effect/mob_spawn/human/syndicate/battlecruiser/medical
	name = "Syndicate Battlecruiser Ship Medical Doctor"
	short_desc = "You are a medical doctor aboard the Syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to maintain the crew's physical health and keep your comrades alive at all cost."
	important_info = "The armory has nothing to help you with your job, and your role is to assist assault operatives, not to do their work for them."
	outfit = /datum/outfit/syndicate_empty/sbc/med
	assignedrole = "Battlecruiser Medical Doctor"
	mob_name = "syndicate medic"
	id_job = "Syndicate Medical Doctor"

/datum/outfit/syndicate_empty/sbc/med
	name = "Syndicate Battlecruiser Ship Medical Doctor"
	uniform = /obj/item/clothing/under/syndicate/intern
	glasses = /obj/item/clothing/glasses/hud/health/prescription
	l_pocket = /obj/item/gun/energy/e_gun/mini
	r_pocket = /obj/item/kitchen/knife/combat/survival
	belt = /obj/item/defibrillator/compact/combat/loaded
	back = /obj/item/storage/backpack/duffelbag/syndie/med
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1, /obj/item/storage/firstaid/medical, /obj/item/storage/firstaid/tactical, /obj/item/storage/box/medipens=3, /obj/item/gun/medbeam)

/obj/effect/mob_spawn/human/syndicate/battlecruiser/assault
	name = "Syndicate Battlecruiser Assault Operative"
	short_desc = "You are an assault operative aboard the syndicate flagship <i>Starfury</i>."
	flavour_text = "Your job is to follow your captain's orders, keep intruders out of the ship, and assault Space Station 13. There is an armory, multiple assault ships, and beam cannons to attack the station with."
	important_info = "Work as a team with your fellow operatives and work out a plan of attack. If you are overwhelmed, escape back to your ship!"
	outfit = /datum/outfit/syndicate_empty/sbc/assault
	assignedrole = "Battlecruiser Assault Operative"
	mob_name = "syndicate assault operative"
	id_job = "Syndicate Assault Operative"

/datum/outfit/syndicate_empty/sbc/assault
	name = "Syndicate Battlecruiser Assault Operative"
	uniform = /obj/item/clothing/under/syndicate/camo
	l_pocket = /obj/item/ammo_box/magazine/m10mm
	r_pocket = /obj/item/kitchen/knife/combat/survival
	glasses = /obj/item/clothing/glasses/night
	belt = /obj/item/storage/belt/military
	back = /obj/item/storage/backpack/duffelbag/syndie
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/automatic/pistol
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1, /obj/item/gun_voucher/syndicate=1)

/datum/outfit/syndicate_empty/sbc/assault/operative
	name = "Syndicate Battlecruiser Operative"
	head = /obj/item/clothing/head/warden
	uniform = /obj/item/clothing/under/syndicate/combat
	id = /obj/item/card/id/syndicate_command/operative
	backpack_contents = list(/obj/item/melee/baton/loaded=1, /obj/item/storage/box/survival/syndie=1, /obj/item/gun_voucher/syndicate=1)

/obj/effect/mob_spawn/human/syndicate/battlecruiser/captain
	name = "Syndicate Battlecruiser Captain"
	short_desc = "You are the captain aboard the Syndicate flagship <i>Starfury</i>."
	flavour_text = "Your job is to oversee your crew, defend the ship, and destroy Space Station 13. The ship has an armory, multiple ships, beam cannons, and multiple crewmembers to accomplish this goal."
	important_info = "As the captain, this whole operation falls on your shoulders. You do not need to nuke the station, causing sufficient damage and preventing your ship from being destroyed will be enough."
	outfit = /datum/outfit/syndicate_empty/sbc/assault/captain
	id_access_list = list(150,151)
	id_job = "Syndicate Captain"
	assignedrole = "Battlecruiser Captain"
	mob_name = "syndicate captain"

/datum/outfit/syndicate_empty/sbc/assault/captain
	name = "Syndicate Battlecruiser Captain"
	l_pocket = /obj/item/melee/transforming/energy/sword/saber/red
	r_pocket = /obj/item/melee/classic_baton/telescopic
	uniform = /obj/item/clothing/under/syndicate/gorlex
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	suit_store = /obj/item/gun/ballistic/revolver/mateba
	head = /obj/item/clothing/head/HoS/syndicate
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	id = /obj/item/card/id/syndicate_command/captain_id

//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.
/obj/effect/mob_spawn/human/oldsec
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a security officer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You are a security officer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_info = "Work as a team with your fellow survivors and do not abandon them."
	uniform = /obj/item/clothing/under/rank/security/old //WS edit - Command/Sec resprite
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/sec
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/assembly/flash/handheld
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldsec/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldeng
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise an engineering uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "an engineer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You are an engineer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. The last thing \
	you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_info = "Work as a team with your fellow survivors and do not abandon them."
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	shoes = /obj/item/clothing/shoes/workboots
	id = /obj/item/card/id/away/old/eng
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldeng/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldsci
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a scientist"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You are a scientist working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_info = "Work as a team with your fellow survivors and do not abandon them."
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci
	l_pocket = /obj/item/stack/medical/bruise_pack
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldsci/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldcap
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a captain"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You are a officer of Nanotrasen, onboard your state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_info = "Command your fellow survivors and do not abandon them."
	head = /obj/item/clothing/head/caphat/nt
	uniform = /obj/item/clothing/under/rank/command/captain/nt
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/cap
	back = /obj/item/storage/backpack
	l_pocket = /obj/item/melee/classic_baton/telescopic
	backpack_contents = list(/obj/item/gun/ballistic/automatic/pistol/deagle)
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldcap/Initialize(mapload)
	notify_ghosts("An old cryogenics pod has been created", flashwindow = FALSE, notify_suiciders = FALSE)
	. = ..()

/obj/effect/mob_spawn/human/oldcap/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_name = "a space pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate/space
	roundstart = FALSE
	death = FALSE
	anchored = TRUE
	density = FALSE
	show_flavour = FALSE //Flavour only exists for spawners menu
	short_desc = "You are a space pirate."
	flavour_text = "The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot."
	assignedrole = "Space Pirate"
	var/rank = "Mate"

/obj/effect/mob_spawn/human/pirate/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name,generate_pirate_name())
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/human/pirate/proc/generate_pirate_name()
	var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
	var/endings = strings(PIRATE_NAMES_FILE, "endings")
	return "[rank] [pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/human/pirate/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/human/pirate/gunner
	rank = "Gunner"

//Forgotten syndicate ship

/obj/effect/mob_spawn/human/syndicatespace
	name = "Syndicate Ship Crew Member"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	short_desc = "You are a syndicate operative on old ship, stuck in hostile space."
	flavour_text = "Your ship docks after a long time somewhere in hostile space, reporting a malfunction. You are stuck here, with Nanotrasen station nearby. Fix the ship, find a way to power it and follow your captain's orders."
	important_info = "Obey orders given by your captain. DO NOT let the ship fall into enemy hands."
	outfit = /datum/outfit/syndicatespace/syndicrew
	assignedrole = "Cybersun Crewmember"

/obj/effect/mob_spawn/human/syndicatespace/Initialize(mapload)
	. = ..()
	var/policy = get_policy(ROLE_SYNDICATE_CYBERSUN)
	if(policy)
		important_info = policy

/datum/outfit/syndicatespace/syndicrew/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/human/syndicatespace/special(mob/living/new_spawn)
	new_spawn.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)

/obj/effect/mob_spawn/human/syndicatespace/captain
	name = "Syndicate Ship Captain"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	short_desc = "You are the captain of an old ship, stuck in hostile space."
	flavour_text = "Your ship docks after a long time somewhere in hostile space, reporting a malfunction. You are stuck here, with Nanotrasen station nearby. Command your crew and turn your ship into the most protected fortress."
	important_info = "Protect the ship and secret documents in your backpack with your own life. DO NOT let the ship fall into enemy hands."
	outfit = /datum/outfit/syndicatespace/syndicaptain
	assignedrole = "Cybersun Captain"

/obj/effect/mob_spawn/human/syndicatespace/syndicaptain/Initialize(mapload)
	notify_ghosts("A stranded syndicate ship has spawned", flashwindow = FALSE, notify_suiciders = FALSE)
	. = ..()
	var/policy = get_policy(ROLE_SYNDICATE_CYBERSUN_CAPTAIN)
	if(policy)
		important_info = policy

/datum/outfit/syndicatespace/syndicaptain/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/human/syndicatespace/captain/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate/captain(get_turf(src))
	return ..()

/datum/outfit/syndicatespace/syndicrew
	name = "Syndicate Ship Crew Member"
	uniform = /obj/item/clothing/under/syndicate/combat
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	ears = /obj/item/radio/headset/syndicate/alt
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/kitchen/knife/combat/survival
	belt = /obj/item/storage/belt/military/assault
	id = /obj/item/card/id/syndicate_command/crew_id
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/syndicatespace/syndicaptain
	name = "Syndicate Ship Captain"
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	head = /obj/item/clothing/head/HoS/beret/syndicate
	ears = /obj/item/radio/headset/syndicate/alt/leader
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack
	l_pocket = /obj/item/gun/ballistic/automatic/pistol/APS
	r_pocket = /obj/item/kitchen/knife/combat/survival
	belt = /obj/item/storage/belt/military/assault
	id = /obj/item/card/id/syndicate_command/captain_id
	backpack_contents = list(/obj/item/documents/syndicate/red, /obj/item/paper/fluff/ruins/forgottenship/password)
	implants = list(/obj/item/implant/weapons_auth)

//ashdrake lair ghost roles
/obj/effect/mob_spawn/human/lost
	death = FALSE
	roundstart = FALSE
	random = TRUE

/obj/effect/mob_spawn/human/lost/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Someone has defeated a ash drake! A prisoner has been freed in \the [A.name]!", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)

/obj/effect/mob_spawn/human/lost/doctor
	name = "old cryogenics pod"
	desc = "A sleeper designed to put its occupant into a deep coma."
	mob_name = "a lost vet"
	short_desc = "You are a animal doctor who just woke up in..?"
	flavour_text = "What...? Where are you? Where are the others? This isn't the animal hospital anymore, where the hell are you? \
	Where is everyone? Where did they go? What happened to the hospital? And is that <i>smoke</i> you smell? \
	One of the cats scratched you just a few minutes ago. That's why you were asleep - to heal the scratch. The scabs are still fresh."
	assignedrole = "Lost Vet"
	outfit = /datum/outfit/job/doctor


/obj/effect/mob_spawn/human/lost/centcom
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	name = "old cryogenics pod"
	desc = "A sleeper designed to put its occupant into a deep coma."
	short_desc = "You are a CentCom Official."
	flavour_text = "Central Command is sending you to... wait, where the hell even are you?"
	assignedrole = "Lost CentCom Official"
	outfit = /datum/outfit/centcom/centcom_official

/obj/effect/mob_spawn/human/lost/shaftminer
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	name = "old cryogenics pod"
	desc = "A sleeper designed to put its occupant into a deep coma."
	short_desc = "You are a Shaft Miner."
	flavour_text = "You were mining peacefully, then a ash drake suddenly attacked, then you have died... or so you thought?\
	You have no idea where you now, but you are glad to be alive."
	assignedrole = "Lost Shaft Miner"
	outfit = /datum/outfit/job/miner/equipped

/obj/effect/mob_spawn/human/lost/ashwalker_heir
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	name = "old cryogenics pod"
	desc = "A sleeper designed to put its occupant into a deep coma."
	short_desc = "You are the heir to a Ash Kingdom."
	flavour_text = "You are the heir to a great kingdom in the area. You were sent on a diplomatic mission to another kingdom and... wait where are you?"
	assignedrole = "Lost Ash Kingdom Heir"
	mob_species = /datum/species/lizard/ashwalker/kobold
	outfit = /datum/outfit/ashwalker/heir

/datum/outfit/ashwalker/heir
	name ="Ashwalker Heir"
	head = /obj/item/clothing/head/hopcap
	neck = /obj/item/clothing/neck/cloak/head_of_personnel
	uniform = /obj/item/clothing/under/color/brown
	belt = /obj/item/storage/belt/sabre

/obj/effect/mob_spawn/human/lost/assistant
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	name = "old cryogenics pod"
	desc = "A sleeper designed to put its occupant into a deep coma."
	short_desc = "You are a Assistant."
	flavour_text = "You are an assistant on a state of the art station. Except you aren't, really. You aren't even lost either. You are simply here to see the cool dragon.\
	When you saw it, you thought \"What a cool dragon\" When it saw you, it thought \"What a cool snack\". You have no idea why it hasn't eaten you yet, but you are now\
	an assistant in an very much not state-of-the-art ashdrake prison."
	assignedrole = "Lost Assistant"
	important_info = "You are very much obsessed with the dragon. Do NOT stop thinking about the dragon."
	outfit = /datum/outfit/job/assistant
	mob_species = /datum/species/ipc

/obj/effect/mob_spawn/human/lostassistant/Initialize(mapload)
	..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Someone has defeated a ash drake! A prisoner has been freed in \the [A.name]!", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)

/obj/effect/mob_spawn/human/lost/syndicate
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	name = "old cryogenics pod"
	desc = "A sleeper designed to put its occupant into a deep coma."
	short_desc = "You are a Syndicate Operative."
	flavour_text = "You are a nuclear agent! Your objective is- wait where the hell are you? This isn't the base, so where are you?"
	assignedrole = "Lost Syndicate"
	outfit = /datum/outfit/syndicate/lost

/datum/outfit/syndicate/lost
	name = "Syndicate Operative - Lost"
	tc = 10
