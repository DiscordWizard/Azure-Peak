/datum/sex_action/force_suck_nipples
	name = "Force them to suck nipples"
	require_grab = TRUE
	stamina_cost = 1.0

/datum/sex_action/force_suck_nipples/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/force_suck_nipples/can_perform(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/userhuman = user
		if(userhuman.wear_shirt)
			var/obj/item/clothing/suit/roguetown/shirtsies = userhuman.wear_shirt
			if(shirtsies.flags_inv == HIDEBOOB)
				if(shirtsies.genitalaccess == FALSE)
					return FALSE
	if(!get_location_accessible(target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/force_suck_nipples/on_start(mob/living/user, mob/living/target)
	user.visible_message(span_warning("[user] forces [target]'s head down to suck on their nipples!"))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/force_suck_nipples/on_perform(mob/living/user, mob/living/target)
	user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] forces [target] to suck their nipples."))
	target.make_sucking_noise()

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)

	user.sexcon.perform_sex_action(target, 0, 7, FALSE)
	if(!user.sexcon.considered_limp())
		user.sexcon.perform_deepthroat_oxyloss(target, 0.6)
	target.sexcon.handle_passive_ejaculation()

	var/milk_to_add = min(max(user.getorganslot(ORGAN_SLOT_BREASTS).breast_size, 1), user.getorganslot(ORGAN_SLOT_BREASTS).milk_stored)
	if(user.getorganslot(ORGAN_SLOT_BREASTS).lactating && milk_to_add > 0 && prob(25))
		target.reagents.add_reagent(/datum/reagent/consumable/mothersmilk, milk_to_add)
		user.getorganslot(ORGAN_SLOT_BREASTS).milk_stored -= milk_to_add
		to_chat(target, span_notice("I can taste cloyingly sweet milk."))
		to_chat(user, span_notice("I can feel milk leak from my buds."))

/datum/sex_action/force_suck_nipples/on_finish(mob/living/user, mob/living/target)
	user.visible_message(span_warning("[user] pulls their nipples out of [target]'s mouth."))

/datum/sex_action/force_suck_nipples/is_finished(mob/living/user, mob/living/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE