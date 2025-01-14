#define MOVING_TO_TARGET 1
#define EATING_TARGET 2
#define LAYING_EGG 3

/mob/living/carbon/superior_animal/roach/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(eat_target == C && get_dist(src,eat_target) > 1)
				eat_target = null
				busy = 0
				stop_automated_movement = 0

/mob/living/carbon/superior_animal/roach/Life()
	. = ..()
	if(!stat) // if the roach is conscious
		if(stance == HOSTILE_STANCE_IDLE)
			// 5 percents chance that the roach is hungry
			if(!busy && prob(5))
				//first, check for potential food nearby
				var/list/eatTargets = new
				for(var/mob/living/carbon/C in getPotentialTargets())
					if ((C.stat == DEAD) && ((istype(C, /mob/living/carbon/human)) || (istype(C, /mob/living/carbon/superior_animal))))
						eatTargets += C

				eat_target = safepick(nearestObjectsInList(eatTargets,src,1))
				if (eat_target)
					busy = MOVING_TO_TARGET
					set_glide_size(DELAY2GLIDESIZE(move_to_delay))
					walk_to(src, eat_target, 1, move_to_delay)
					GiveUp(eat_target) //give up if we can't reach target
					return

			else if(busy == MOVING_TO_TARGET && eat_target)
				if(istype(eat_target, /mob/living/carbon/human))
					eating_time = 9000
				if(get_dist(src, eat_target) <= 1)
					busy = EATING_TARGET
					stop_automated_movement = 1
					src.visible_message(SPAN_NOTICE("\The [src] begins to eat \the [eat_target]."))
					walk(src,0)
					spawn(eating_time) // how much time it takes to eat a corpse, in tenths of second
						// Set to 15 minutes to let the crew enough time to get the corpse
						 //Takes to eat any non-human much shorter of a time, just 1 and a 1/2 min
						// Several roaches eating at the same time do not speed up the process
						// If disturbed the roach has to start back from 0
						if(busy == EATING_TARGET)
							if(eat_target && istype(eat_target.loc, /turf) && get_dist(src,eat_target) <= 1)
								var/turf/targetTurf = eat_target.loc
								var/mob/living/carbon/M = eat_target

								if((M.stat == DEAD)) // Don't try to eat something that is alive
									if ((istype(M, /mob/living/carbon/human)) && (M.icon)) // Eating a human
										// Icon check is to check if another roach has already finished eating this human

										var/mob/living/carbon/human/H = M

										// Process Cruciform
										var/obj/item/weapon/implant/core_implant/cruciform/CI = H.get_core_implant(/obj/item/weapon/implant/core_implant/cruciform, FALSE)
										if (CI)
											var/mob/N = CI.wearer
											CI.name = "[N]'s Cruciform"
											CI.uninstall()

										// Gib victim but remove non synthetic organs
										H.gib(max_range=1, keep_only_robotics=TRUE)

										// Spawn human remains
										var/remainsType = /obj/item/remains/human
										new remainsType(targetTurf)

										// End message
										src.visible_message(SPAN_WARNING("\The [src] finishes eating \the [eat_target], leaving only bones."))

										// Get fed
										fed += rand(8,12)

									else if (istype(M, /mob/living/carbon/superior_animal) && (M.icon)) // Eating a spider or roach

										// Gib victim
										M.gib(null, FALSE)
										gibs(targetTurf, null, /obj/effect/gibspawner/generic, fleshcolor, bloodcolor)

										// End message
										src.visible_message(SPAN_WARNING("\The [src] finishes eating \the [eat_target], leaving only bones."))

										// Get fed
										fed += rand(2,3)

								eat_target = null
								eating_time = 900 //Resetting the timer just in case

							busy = 0
							stop_automated_movement = 0

			else if (!busy && prob(probability_egg_laying)) // chance to lay an egg
				if((fed > 0) && !(locate(/obj/effect/spider/eggcluster) in get_turf(src)))
					busy = LAYING_EGG
					src.visible_message(SPAN_NOTICE("\The [src] begins to lay an egg."))
					stop_automated_movement = 1
					spawn(50)
						if(busy == LAYING_EGG)
							if(!(locate(/obj/effect/roach/roach_egg) in get_turf(src)))
								new /obj/effect/roach/roach_egg(loc, src)
								fed--
								update_openspace()
							busy = 0
							stop_automated_movement = 0
		else
			busy = 0
			stop_automated_movement = 0

#undef MOVING_TO_TARGET
#undef EATING_TARGET
#undef LAYING_EGG
