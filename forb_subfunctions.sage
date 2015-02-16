'''
TODO: Go through and clean up
      Is everything in here in use?
'''

# Helper function for find_badpatts and para_find_badpatts
def rec(C,forb,lst):
    
    #pruning lst
    newlst = []
    for L in lst:
        if L.issubset(forb):
            return []
        if not C.intersection(L):
            newlst.append(L)
    
    if newlst:
        lst0 = newlst[0]
        
        i = 0
        while lst0[i] in forb:
            i = i+1
            
        return rec( C.union(Set([lst0[i]])), forb, newlst ) + rec( C, forb.union(Set([lst0[i]])), newlst )
    else:
        return [C]

def rec_w_reduce(C,forb,lst,perm):
    
    global badpatts
    global check_interval

    #pruning lst
    newlst = []
    for L in lst:
        if L.issubset(forb): # If a member of lst is inside forb then it is impossible to satisfy that member
            return []
        if not C.intersection(L): # Here we find the members of lst that have not yet been satisfied
            newlst.append(L)
    
    if newlst:
        lst0 = newlst[0] # Now we aim for satisfying the first member of lst, lst0
        
        i = 0 # Here we find the first box in lst0 that we are allowed to fill in (i.e., put in C)
        while lst0[i] in forb:
            i = i+1

        '''
        This was added in September 2012.
        We now check if the addition of the box lst0[i] makes this entire branch in the
        recursion redundant.
        '''
        D = C.union(Set([lst0[i]]))
        for j in check_interval:
            if j == len(perm):
                break
            for cl_patt in badpatts[j]:
                if mesh_has_mesh_many_shadings((perm,D),cl_patt,badpatts[j][cl_patt]):
                    return rec_w_reduce( C, forb.union(Set([lst0[i]])), newlst, perm )
            
        return rec_w_reduce( D, forb, newlst, perm ) + rec_w_reduce( C, forb.union(Set([lst0[i]])), newlst, perm )
    else:
        return [C]

def rec_w_reduce_pattern_pos( C, forb, lst, perm, pattern_positions, check_interval ):
    
    global badpatts

    #pruning lst
    newlst = []
    for L in lst:
        if L.issubset(forb): # If a member of lst is inside forb then it is impossible to satisfy that member
            return []
        if not C.intersection(L): # Here we find the members of lst that have not yet been satisfied
            newlst.append(L)
    
    if newlst:
        lst0 = newlst[0] # Now we aim for satisfying the first member of lst, lst0
        
        i = 0 # Here we find the first box in lst0 that we are allowed to fill in (i.e., put in C)
        while lst0[i] in forb:
            i = i+1

        '''
        This was added in September 2012.
        We now check if the addition of the box lst0[i] makes this entire branch in the
        recursion redundant.
        '''
        D = C.union(Set([lst0[i]]))
        for j in check_interval:
            if j == len(perm):
                break
            for cl_patt in badpatts[j]:
                if mesh_has_mesh_with_positions(perm, D, pattern_positions[cl_patt], badpatts[j][cl_patt]):
                    return rec_w_reduce_pattern_pos( C, forb.union(Set([lst0[i]])), newlst, perm, pattern_positions, check_interval )
            
        return rec_w_reduce_pattern_pos( D, forb, newlst, perm, pattern_positions, check_interval ) + rec_w_reduce_pattern_pos( C, forb.union(Set([lst0[i]])), newlst, perm, pattern_positions, check_interval )
    else:
        return [C]

#
# This function checks if mesh_patt occurs in mesh_perm
#

def mesh_has_mesh_with_positions(perm, S, pattern_pos, Rs):

    # If there are no occurrences we return False
    if not pattern_pos:
        return False
    # Otherwise the length of the pattern we are looking at is given
    # by the length of the first occurrence of it in perm
    else:
        k = len(pattern_pos[0])

    n = len(perm)
    
    Gperm = G(perm)
    
    Scomp = Set(map(lambda x: tuple(x),CartesianProduct([0..n],[0..n]))).difference(S)

    for H in pattern_pos:
        X = dict( (x+1,y+1) for (x,y) in enumerate(H) )
        Y = dict( G(sorted(perm[j] for j in H)) )

        X[0], X[k+1] = 0, n+1
        Y[0], Y[k+1] = 0, n+1
        
        for R in Rs:
            shady = ( X[i] < x < X[i+1] and Y[j] < y < Y[j+1]\
                      for (i,j) in R\
                      for (x,y) in Gperm\
                    )
                    
            shaky = ( X[i] <= x < X[i+1] and Y[j] <= y < Y[j+1]\
                      for (i,j) in R\
                      for (x,y) in Scomp\
                    )
                    
            if not any(shady):
                if not any(shaky):
                      return True
    return False

def mesh_has_mesh(mesh_perm,mesh_patt):
    
    pat  = mesh_patt[0]
    R    = mesh_patt[1]
    
    perm = mesh_perm[0]
    S    = mesh_perm[1]
    
    k = len(pat)
    n = len(perm)

    if k > n:
        return False
    
    pat  = G(pat)
    perm = G(perm)
    
    Scomp = Set(map(lambda x: tuple(x),CartesianProduct([0..n],[0..n]))).difference(S)
    
    for H in Subwords(perm, k):
        
        X = dict(G(sorted(i for (i,_) in H)))
        Y = dict(G(sorted(j for (_,j) in H)))
        
        if H == [ (X[i], Y[j]) for (i,j) in pat ]:
            
            X[0], X[k+1] = 0, n+1
            Y[0], Y[k+1] = 0, n+1
            
            shady = ( X[i] < x < X[i+1] and Y[j] < y < Y[j+1]\
                      for (i,j) in R\
                      for (x,y) in perm\
                    )
                    
            shaky = ( X[i] <= x < X[i+1] and Y[j] <= y < Y[j+1]\
                      for (i,j) in R\
                      for (x,y) in Scomp\
                    )
                    
            if not any(shady):
                if not any(shaky):
                    return True
    return False

'''
Specialized version of the function above
'''
def mesh_has_mesh_many_shadings(mesh_perm,patt,Rs):
    
    perm = mesh_perm[0]
    S    = mesh_perm[1]
    
    k = len(patt)
    n = len(perm)

    if k > n:
        return False
    
    patt  = G(patt)
    perm = G(perm)
    
    Scomp = Set(map(lambda x: tuple(x),CartesianProduct([0..n],[0..n]))).difference(S)
    
    for H in Subwords(perm, k):
        
        X = dict(G(sorted(i for (i,_) in H)))
        Y = dict(G(sorted(j for (_,j) in H)))
        
        if H == [ (X[i], Y[j]) for (i,j) in patt ]:
            
            X[0], X[k+1] = 0, n+1
            Y[0], Y[k+1] = 0, n+1

            for R in Rs:
            
                shady = ( X[i] < x < X[i+1] and Y[j] < y < Y[j+1]\
                          for (i,j) in R\
                          for (x,y) in perm\
                        )
                        
                shaky = ( X[i] <= x < X[i+1] and Y[j] <= y < Y[j+1]\
                          for (i,j) in R\
                          for (x,y) in Scomp\
                        )
                        
                if not any(shady):
                    if not any(shaky):
                        return True
    return False
