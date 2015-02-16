'''
TODO: Go through and clean up
'''

def forb( check_interval, goodpatts, M, report=False ):

    global badpatts
    badpatts = {}
    outpatts = {}

    def find_badpatts(perm):

        n = len(perm)

        pattern_positions = {}
        for j in check_interval:
            if j == len(perm):
                break
            for cl_patt in badpatts[j]:
                pattern_positions[cl_patt] = perm.pattern_positions(cl_patt)

        if goodpatts[n].has_key(perm):

            R = sorted(rec_w_reduce_pattern_pos( Set([]), Set([]), goodpatts[n][perm], perm, pattern_positions, check_interval ), key = lambda x : len(x), reverse = True)
            newR = []

            for j,r in enumerate(R):
                if not any(map(lambda s : s.issubset(r), R[j+1:])):
                    newR.append(r)

            return newR

        else:

            for j in check_interval:
                if j == len(perm):
                    break
                for cl_patt in badpatts[j]:
                    if mesh_has_mesh_many_shadings((perm,[]),cl_patt,badpatts[j][cl_patt]):
                        return []

            return [ Set([]) ]

    # finding the forbidden patterns
    for j in check_interval:

        if j > M:
            break

        if report:
            print 'Starting search for forbidden patterns of length ' + str(j)

        badpatts[j] = {}
        for perm in Permutations(j):
            badpatts[j][perm] = find_badpatts(perm)

        if report:
            print 'The number of bad patterns of length ' + str(j) + ' is ' + str(sum(len(badpatts[j][perm]) for perm in badpatts[j].keys()))

    # finding the minimal forbidden patterns
    if report:
        print ''
        print 'Starting search for minimal forbidden patterns'
        print ''

    for j in check_interval:

        if j > M:
            break

        outpatts[j] = dict()
        for cl_patt in badpatts[j]:
            if badpatts[j][cl_patt]:
                outpatts[j][cl_patt] = badpatts[j][cl_patt]

    return outpatts