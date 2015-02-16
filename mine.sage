'''
TODO: Go through and clean up
      Is everything in here in use?
'''

def mine( goodperms, M, N, report=False):
    '''
    goodperms is the set of permutations satisfying some
    property. This should be in the form of a dictionary
    whose keys are lengths. Each key points to the good permutations
    of that length. There should be no gaps, i.e., the keys should
    form a contiguous interval of integers

    M is the longest mesh patterns you want to consider
    
    N is the longest permutations you want to consider from
    goodperms

    The output will be a dictionary of maximal mesh patterns that appear inside goodperms
    '''
    # This will be a dictionary whose keys are lengths. Each length
    # points at another dictionary whose keys are classical patterns
    # of that length. Each classical pattern points at a list of
    # good (maximal) shadings for that pattern
    goodpatts = {}
    
    # This interval contains the lengths of the patterns we want
    # to consider
    interval = range(1,M+1)

    if report:
        if 1 < M:
            print 'Starting search for allowed patterns of lengths 1...' + str(M)
        else:
             print 'Starting search for allowed patterns of length 1'
        print ''

    # Initializing the dictionary goodpatts by adding (p,fullshading)
    # for any permutation p in goodperms

    # The following interval contains pattern lengths where there
    # are potential patterns to consider
    check_interval = []
    for j in interval:

        goodpatts[j] = {}
        
        if len(goodperms[j]) == factorial(j):
            for perm in goodperms[j]:
                goodpatts[j][Permutation(perm)] = [Set([])]
        else:
            for perm in goodperms[j]:
                goodpatts[j][Permutation(perm)] = [Set([])]
            check_interval.append(j)

    if not check_interval:
        print 'You need to search for longer patterns'
        return [], {}

    minci = min(check_interval)
    maxci = max(check_interval)
    
    if report:
        if minci < maxci:
            print 'Only need to consider patterns of lengths ' + str(minci) + '...' + str(maxci)
        else:
            print 'Only need to consider patterns of length ' + str(minci)
        print ''

    '''
    -----------------------------------------------------------------------------------------
    Here we define a function

    add_good_shadings_to_goodpatts: Looks for allowed mesh patterns in perm
    '''

    def add_good_shadings_to_goodpatts(perm,shading,loc,min_len,max_patt_len):

        L = len(perm)

        # If there are too few elements in the perm left to complete a pattern of length Jmin we stop.
        if L > min_len and loc <= max_patt_len:
            go_deeper = False
            if L > min_len+1:
                go_deeper = True

            for i in range(loc,min(max_patt_len+1,L)):
                
                newPerm = []
                for j in range(i)+range(i+1,L):
                    if perm[j] > perm[i]:
                        newPerm.append(perm[j] - 1)
                    else:
                        newPerm.append(perm[j])
                nL = len(newPerm)

                newShading = [ (sh[0] - (sh[0] > i), sh[1] - (sh[1] >= perm[i])) for sh in shading ]
                newShading.append((i,perm[i]-1))
                newShading = Set(newShading)

                if nL <= max_patt_len:

                    newPerm = Permutation(newPerm)

                    if goodpatts[nL].has_key(newPerm):

                        if not any(U.issubset(newShading) for U in goodpatts[nL][newPerm]):
                            goodpatts[nL][newPerm].append(newShading)
                    else:
                        goodpatts[nL][newPerm] = [newShading]

                if go_deeper:
                    add_good_shadings_to_goodpatts(newPerm,newShading,i,min_len,max_patt_len)

    '''
    -----------------------------------------------------------------------------------------
    '''

    if report:
        print 'Now looking at permutations of length'
        print ''

    for i in range(1,N+1):

        if report:
            print '         ' + str(i)

        min_maxci_i = min(maxci,i)

        for perm in goodperms[i]:

            add_good_shadings_to_goodpatts(perm,Set([]),0,minci,min_maxci_i)

    if report:
        print ''
        print 'Done'
        print ''

        for j in check_interval:
            print 'The number of allowed patterns of length ' + str(j) + ' is ' + str(sum(len(goodpatts[j][perm]) for perm in goodpatts[j].keys()))

        print ''
        print 'Getting rid of the unnecessary allowed patterns'
        print ''

    for j in check_interval:
        for perm in goodpatts[j].keys():

            for R in goodpatts[j][perm]:
                listwoR = list(goodpatts[j][perm])
                listwoR.remove(R)

                if any(S.issubset(R) for S in listwoR):
                    goodpatts[j][perm] = listwoR

    if report:
        for j in check_interval:
            print 'The number of allowed patterns of length ' + str(j) + ' is now ' + str(sum(len(goodpatts[j][perm]) for perm in goodpatts[j].keys()))
        print ''

    '''
    Now the first step is done: We have the maximum allowed shadings for
    any potentially bad classical pattern.
    '''

    return check_interval, goodpatts