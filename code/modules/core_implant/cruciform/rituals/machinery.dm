/datum/ritual/cruciform/machines
	name = "machines"
	phrase = null
	implant_type = /obj/item/weapon/implant/core_implant/cruciform
	fail_message = "The Cruciform feels cold against your chest."
	category = "Machinery"

/*
//Cloning
/datum/ritual/cruciform/machines/resurrection
	name = "Resurrection"
	phrase = "Qui fuit, et crediderunt in me non morietur in aeternum"
	desc = "A ritual of formation of a new body in a speclially designed machine.  Deceased person's cruciform has to be placed on the scanner then a prayer is to be uttered over the apparatus."

/datum/ritual/cruciform/machines/resurrection/perform(mob/living/carbon/human/user, obj/item/weapon/implant/core_implant/C)
	var/list/OBJS = get_front(user)

	var/obj/machinery/neotheology/cloner/pod = locate(/obj/machinery/neotheology/cloner) in OBJS

	if(!pod)
		fail("You fail to find any cloner here.", user, C)
		return FALSE

	if(pod.cloning)
		fail("Cloner is already cloning.", user, C)
		return FALSE

	if(pod.stat & NOPOWER)
		fail("Cloner is off.", user, C)
		return FALSE

	pod.start()
	return TRUE
*/


////////////////////////BIOMATTER MANIPULATION MULTI MACHINES RITUALS

///////////////>Biogenerator manipulation rite</////////////////
/datum/ritual/cruciform/machines/power_biogen_awake
	name = "Power biogenerator song"
	phrase = "Dixitque Deus: Fiat lux. Et facta est lux.  Et lux in tenebris lucet, et renebrae eam non comprehenderunt."
	desc = "A ritual, that can activate or deactivate power biogenerator machine. You should be nearby its metrics screen."
	nutri_cost = 10
	blood_cost = 10

/datum/ritual/cruciform/machines/power_biogen_awake/perform(mob/living/carbon/human/H, obj/item/weapon/implant/core_implant/C)
	var/obj/machinery/multistructure/biogenerator_part/console/biogen_screen = locate() in range(4, H)
	if(biogen_screen && biogen_screen.MS)
		var/datum/multistructure/biogenerator/biogenerator = biogen_screen.MS
		if(biogenerator.working)
			biogenerator.deactivate()
		else
			biogenerator.activate()
		if(H.species?.reagent_tag != IS_SYNTHETIC)
			if(H.nutrition >= nutri_cost)
				H.nutrition -= nutri_cost
			else
				to_chat(H, SPAN_WARNING("You manage to cast the litany at a cost. The physical body consumes itself..."))
				H.vessel.remove_reagent("blood",blood_cost)
		return TRUE

	fail("There is no power biogenerator screen near you.", H, C)
	return FALSE


////////////////Bioreactor commands

/datum/ritual/cruciform/machines/bioreactor
	name = "Bioreactor command"
	nutri_cost = 10
	blood_cost = 10


/datum/ritual/cruciform/machines/bioreactor/perform(mob/living/carbon/human/H, obj/item/weapon/implant/core_implant/C)
	var/obj/machinery/multistructure/bioreactor_part/console/bioreactor_screen = locate() in range(4, H)
	if(bioreactor_screen && bioreactor_screen.MS)
		var/datum/multistructure/bioreactor/bioreactor = bioreactor_screen.MS
		//to prevent any copypaste
		//let's make it a bit better
		var/success = perform_command(bioreactor)
		if(H.species?.reagent_tag != IS_SYNTHETIC)
			if(H.nutrition >= nutri_cost)
				H.nutrition -= nutri_cost
			else
				to_chat(H, SPAN_WARNING("You manage to cast the litany at a cost. The physical body consumes itself..."))
				H.vessel.remove_reagent("blood",blood_cost)
		return success

	fail("You should be near the bioreactor metrics screen.", H, C)
	return FALSE

//There we perform any manipulations with our bioreactor
//Since console finder code is similar for both rituals
/datum/ritual/cruciform/machines/bioreactor/proc/perform_command(datum/multistructure/bioreactor/bioreactor)
	return

///////////////>Bioreactor pump solution ritual<//////////////////

/datum/ritual/cruciform/machines/bioreactor/solution
	name = "Bioreactor solution pump's lullaby"
	phrase = "Nihil igitur fieri de nihilo posse putandum est."
	desc = "This ritual pump in or pump out solution of bioreactor's chamber. You should stay nearby its screen."

/datum/ritual/cruciform/machines/bioreactor/solution/perform_command(datum/multistructure/bioreactor/bioreactor)
	if(!bioreactor.chamber_closed)
		return FALSE
	bioreactor.pump_solution()
	var/obj/machinery/multistructure/bioreactor_part/console/bioreactor_console = bioreactor.metrics_screen
	bioreactor_console.ping()
	bioreactor_console.visible_message("Bioreactor produces an echoing click. The platforms pumps start buzzing.")
	return TRUE



///////////////>Bioreactor chamber opening song<////////////////

/datum/ritual/cruciform/machines/bioreactor/chamber_doors
	name = "Bioreactor chamber's words"
	phrase = "Constituit quoque ianitores in portis domus Domini ut non ingrederetur eam inmundus in omni."
	desc = "This ritual open or close bioreactor chamber. You should stay nearby its screen."
/datum/ritual/cruciform/machines/bioreactor/chamber_doors/perform_command(datum/multistructure/bioreactor/bioreactor)
	if(bioreactor.chamber_solution)
		return FALSE
	bioreactor.toggle_platform_door()
	var/obj/machinery/multistructure/bioreactor_part/console/bioreactor_console = bioreactor.metrics_screen
	bioreactor_console.ping()
	bioreactor_console.visible_message("You hear a loud BANG. Then a pause... The chamber's door mechanism moves its position with a quiet grace.")