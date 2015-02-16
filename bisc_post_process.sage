'''
TODO: Go through and clean up
      Is everything in here in use?
'''

def describe_bisc_output(OP):

    mult = 1
    flip = True

    for k in OP.keys():
        clpatts_of_this_length = OP[k].keys()
        print "There are " + str(len(clpatts_of_this_length)) + " underlying classical patterns of length " + str(k)
        for clpatt in clpatts_of_this_length:

            new_factor = len(OP[k][clpatt])
            mult = mult*new_factor

            print "There are " + str(new_factor) + " different shadings on " + str(clpatt)

        if flip:
            print "The number of sets to monitor at the start of the clean-up phase is " + str(mult)
        flip = False

def display_forb_output(patts_w_shadings_dict):
    '''
    Input is the output of forb, i.e., a dictionary
    whose keys are lengths of pattern. Each length
    points to a dictionary of classical patterns of that
    length. The values of those dictionaries are the
    shadings of those patterns.

    The output is a list of mesh patterns that
    we can plot nicely
    '''
    res = []
    for d in patts_w_shadings_dict.values():
        for patt, shadings in d.items():
            for s in shadings:
                res.append((patt,s))
    return res

'''
-------------------------------------------------------------------------
Function checks whether the patterns in SG suffice
to describe the permutations in the dictionary D up to length L

There are two subfunctions below

'''
def patterns_suffice(SG,L,D,stop_on_failure=False,parallel=False,ncpus=0):
    
    for n in [1..L]:
    
        if n not in D.keys():
            print 'The dictionary does not contain permutations of length ' + str(n)
            break

        print "Now checking permutations of length " + str(n)

        if not parallel:

            avoiding_perms = []
            for b in D[n]:

                b_avoids = avoids_mpats_many_shadings(b,SG)

                if b_avoids and stop_on_failure:

                    print "The permutation " + str(b) + " avoids the patterns"
                    return []
                else:
                    avoiding_perms.append(b)

            if D[n] and b_avoids:
                print "There are permutations of length " + str(n) + " that avoid the patterns"
                return avoiding_perms

        else:
            if not ncpus:
                ncpus = sage.parallel.ncpus.ncpus()

            # Slicing the set D[n] into ncpus pieces
            sliced = map( lambda permlist : (permlist,SG), sl(D[n],ncpus) )

            if stop_on_failure:
                some_perm_fails = not all(map(lambda x: x[1], permlist_contains_patts_w_shadings(sliced)))
                if some_perm_fails:
                    print "There are permutations of length " + str(n) + " that avoid the patterns"
                    return []

            else:
                avoiding_perms = reduce( lambda l1,l2 : l1+l2, map(lambda x: x[1], perms_avoiding_patts_w_shadings(sliced)))

                if avoiding_perms:
                    print "There are permutations of length " + str(n) + " that avoid the patterns"
                    return avoiding_perms


def sl(lst,i):

    '''
    Slice a list lst into i pieces
    '''
    
    if i == 1 or not lst:
        return [lst]

    n = len(lst)

    if i >= n:
        return map(lambda x : [x], lst)
        
    res = []
    
    m = n//i

    for j in range(i):
        res.append( lst[(j*m):((j+1)*m)] )
        
    j = j+1

    if mod(n,i) != 0:
        res[-1].extend(lst[j*m::])  
        
    return res

@parallel
def permlist_contains_patts_w_shadings(permlist,patts_w_shadings):

    '''
    Go through the permutations in permlist
    returns False if one of them avoids the patterns (with multiple
    shadings) in patts_w_shadings

    Supports parallel
    '''
    for perm in permlist:
        if avoids_mpats_many_shadings(perm,patts_w_shadings) == True:
            return False
    return True

@parallel
def perms_avoiding_patts_w_shadings(permlist,patts_w_shadings):

    '''
    Go through the permutations in permlist
    returns the ones that avoid the patterns (with multiple
    shadings) in patts_w_shadings

    Supports parallel
    '''
    res = []

    for perm in permlist:
        if avoids_mpats_many_shadings(perm,patts_w_shadings) == True:
            res.append(perm)
    return res

'''
-------------------------------------------------------------------------
Function checks whether the patterns in the base b suffice
to describe the permutations in the dictionary D up to length L

There are two subfunctions below. We also make use of the slice function above
'''



def base_suffices(b,L,D,stop_on_failure=False,parallel=False,ncpus=0):
    
    for n in [1..L]:
    
        if n not in D.keys():
            print 'The dictionary does not contain permutations of length ' + str(n)
            break

        print "Now checking permutations of length " + str(n)

        if not parallel:
            avoiding_perms = []
            for perm in D[n]:

                perm_avoids = avoids_mpats(perm,b)

                if perm_avoids and stop_on_failure:

                    print "The permutation " + str(perm) + " avoids the patterns"
                    return []
                else:
                    avoiding_perms.append(perm)

            if D[n] and perm_avoids:
                print "There are permutations of length " + str(n) + " that avoid the patterns"
                return avoiding_perms

        else:
            if not ncpus:
                ncpus = sage.parallel.ncpus.ncpus()

            # Slicing the set D[n] into ncpus pieces
            sliced = map( lambda permlist : (permlist,b), sl(D[n],ncpus) )

            if stop_on_failure:
                some_perm_fails = not all(map(lambda x: x[1], permlist_contains_patts(sliced)))
                if some_perm_fails:
                    print "There are permutations of length " + str(n) + " that avoid the patterns"
                    return []

            else:
                avoiding_perms = reduce( lambda l1,l2 : l1+l2, map(lambda x: x[1], perms_avoiding_patts(sliced)))

                if avoiding_perms:
                    print "There are permutations of length " + str(n) + " that avoid the patterns"
                    return avoiding_perms

@parallel
def permlist_contains_patts(permlist,patts):

    '''
    Go through the permutations in permlist
    returns False if one of them avoids the patterns in patts

    Supports parallel
    '''
    for perm in permlist:
        if avoids_mpats(perm,patts) == True:
            return False
    return True

@parallel
def perms_avoiding_patts(permlist,patts):

    '''
    Go through the permutations in permlist
    returns the ones that avoid the patterns patts

    Supports parallel
    '''
    res = []

    for perm in permlist:
        if avoids_mpats(perm,patts) == True:
            res.append(perm)
    return res

# This is defunct as there was something broken in Hjalti's repo after a Sage
# update
def dict_to_MeshPatts(patts_w_shadings_dict):
    '''
    Input is the output of forb, i.e., a dictionary
    whose keys are lengths of pattern. Each length
    points to a dictionary of classical patterns of that
    length. The values of those dictionaries are the
    shadings of those patterns.

    The output is a list of MeshPattern objects that
    we can plot nicely
    '''
    res = []
    for d in patts_w_shadings_dict.values():
        for patt, shadings in d.items():
            for s in shadings:
                res.append(MeshPattern(patt,s))
    return res