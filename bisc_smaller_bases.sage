def clean_up(SG,B,perm_len_min,perm_len_max,patt_len_min,patt_len_max,report=False,detailed_report=False,limit_monitors=0):
    
    '''
    Note that if limit_monitors > 0 then we do not remove redundant monitors (last step)
    '''
    # Dictionaries to go between mesh patterns
    # and numbers (length, pattern number, shading number)
    dict_clpatts_to_numbs = dict()
    dict_numbs_to_patts = dict()
    
    SG_keys = SG.keys()
    
    # A dictionary that "looks" like SG, but has only numbers
    sg = dict()
    
    # Putting values in the three dictionaries
    for k in SG_keys:
        
        sg[k] = dict()
        
        patt_i = 0
        
        for clpatt in SG[k]:
            
            sh_i = 0
            for sh in SG[k][clpatt]:
                dict_clpatts_to_numbs[clpatt] = patt_i
                dict_numbs_to_patts[(k,patt_i,sh_i)] = (clpatt,sh)
                sh_i = sh_i+1
                
            sg[k][patt_i] = [0..sh_i-1]
                
            patt_i = patt_i+1
            
    # initialize len_calc_patts as the length of the smallest mesh patterns
    len_calc_patts = filter( lambda x : x in SG.keys(), [patt_len_min .. patt_len_max] ) #[SG_keys[0]]

    if limit_monitors:
        if limit_monitors<len(SG[patt_len_min].keys()):
            print "You need to allow larger bases"
            return [], dict_numbs_to_patts
    
    # initialize monitor by taking one mesh pattern for
    # every bad permutation on the first level
    if report:
        print "Creating the sets to monitor"
        print ""
    monitor = one_from_each( [ [(len_calc_patts[0],x,y) for y in sg[len_calc_patts[0]][x]] for x in sg[len_calc_patts[0]].keys() ] )
    
    if report:
        print "There are " + str(len(monitor)) + " potential bases to monitor"
        print "Starting the tests"
    # perm_len_min should be 1+len_calc_patts[0]
    for L in [perm_len_min..perm_len_max]:

        # Restricting to the pattern lengths that are smaller than the length of
        # the permutations we are looking at 
        appropriate_len_calc_patts = filter( lambda x : x < L, len_calc_patts )

        # When we try to expand with larger patterns below we need to now if L is
        # available as a length of forbidden patterns
        L_is_a_key = False
        if L in SG.keys():
            L_is_a_key = True

        if report:
                print "----------------------------------------------------------------"
                print ""
                print "Testing permutations of length " + str(L)
                print ""

        for perm in B[L]:
            
            if not monitor:
                print "No sets to monitor, try allowing longer patterns"
                if limit_monitors:
                    print "or larger bases"
                return [], dict_numbs_to_patts

            if report:
                print "-----------------------------------"
                print "Testing the permutation " + str(perm)
            
            dict_numbs_to_perm_avoids_patt = dict()
            saviors = []
            
            for ell in appropriate_len_calc_patts :
                for patt_i in sg[ell].keys():
                    for sh_i in sg[ell][patt_i]:
                        
                        mpat = dict_numbs_to_patts[(ell,patt_i,sh_i)]
                        
                        # Checking whether perm avoids mpat
                        if avoids_mpat(perm, mpat):
                            dict_numbs_to_perm_avoids_patt[(ell,patt_i,sh_i)] = True
                        else:
                            dict_numbs_to_perm_avoids_patt[(ell,patt_i,sh_i)] = False
                            saviors.append((ell,patt_i,sh_i))

            if detailed_report:
                print "When monitors fail below they will extended with " + str(len(saviors)) + " saviors"
                print "They are " + str(saviors)    

            # If L is available as a length of forbidden patterns (checked above) we
            # need to know if perm is one of the underlying classical patterns of that
            # length
            perm_is_a_key = False
            if L_is_a_key and perm in SG[L].keys():
                perm_is_a_key = True
                # Getting the number of this perm
                n_perm = dict_clpatts_to_numbs[perm]
                larger_patts = sg[L][n_perm]

                if detailed_report:
                    print "When monitors fail below they will extended with " + str(len(larger_patts)) + " larger patterns"
                    print "They are " + str(larger_patts)

            h = -1
            capture_failure = False
            loop_monitor = list(monitor)

            for mon in loop_monitor:
                h = h+1
                if all(dict_numbs_to_perm_avoids_patt[m] for m in filter( lambda x : x[0]<L , mon )):
                    capture_failure = True
                    if detailed_report:
                        print "Monitor nr. " + str(h) + " failed"
                        print "This monitor consists of:"
                        for m in mon:
                            print m
                    monitor.remove(mon)

                    if limit_monitors:
                        if len(mon) >= limit_monitors:
                            if detailed_report:
                                print "Unable to extend this monitor because its size has reached the limit"
                            continue
                    
                    if saviors:
                    
                        monitor.extend( map( lambda x : mon+[x], saviors ) )
                    
                    if perm_is_a_key:
                        
                        monitor.extend( map ( lambda x : mon+[(L,n_perm,x)], larger_patts ) )
            print "Number of monitors " + str(len(monitor))
            if capture_failure == True:
                lm = len(monitor)
                if report:
                    print ""
                    print "There are " + str(lm) + " monitors left"
                if not monitor:
                        return [], dict_numbs_to_patts
                if report:
                    print "Sorting the monitors"

                R = sorted(monitor, key = len)

                if report:
                    print ""
                    print "Removing redundant monitors"

                newR = []
                v = 0
                while v<lm :
                    r = R[0]
                    newR.append(r)
                    v = v + len(R)
                    R = filter(lambda s : not gaur(r,s), R[1:])
                    v = v - len(R)

                if report:
                    print ""
                    print "There are now " + str(len(newR)) + " monitors"
                monitor = newR

    return monitor, dict_numbs_to_patts

def gaur(r,s):
    return all( map( lambda x : x in s, r ) )

@parallel
def para_gaur(r,s):
    return all( map( lambda x : x in s, r ) )

def one_from_each(values):
    
    LV = len(values)
    
    if LV == 0:
        return []
        
    if LV == 1:
        return map( lambda x: [x], values[0] )
    
    return sum( [map( lambda x: x+[v], one_from_each(values[1:])) for v in values[0]], [] )