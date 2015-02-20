'''
0) Loading the necessary files. Unless you are debugging you should not change
   anything here
'''
# For creating permutations sets
load("../permutation-sets/create_dict.sage")
load("../permutation-sets/dict_properties.sage")

# For BiSC
load('../bisc/mine.sage')
load('../bisc/forb.sage')
load('../bisc/forb_subfunctions.sage')
load('../bisc/bisc_post_process.sage')
load('../bisc/bisc_smaller_bases.sage')

load('../permutation-sets/scratch.sage')

def create_example(E, ex, Ng, Nb=-1, report=True, cpus=1):
    '''
    To run example 1 from examples/examples_mesh, length 6 perms do

    A, B = create_example('mesh', 1, 6)

    E      : The example file, e.g., 'mesh' or 'groups'
    ex     : The example number, 1, 2, ...
    Ng     : The length of the longest permutations to load
    Ng     : The length of the longest permutations in the complement to load
    report : Set to True to get status messages
    cpus   : The number of cores to use
             Set to 0 if you want Sage to determine the number of available cores
             Set to 1 if you want to call the single core version
    '''

    # If Nb was not set we just use Ng
    if Nb == -1:
        Nb = Ng

    # Loading requested example
    load('../permutation-sets/examples/examples_'+E+'.sage')

    prop, kind = get_example(ex)

    '''
    kind = 0 if prop is a True/False property to be applied to a single permutation
    kind = 1 if prop is a function Sn->Sn that we use to compute the permutations in the image
    kind = 2 if prop is a function that allows to generate the permutations without duplicates
    '''

    if cpus == 1:

        if kind == -1:
            print '\n!!!! No example with this number !!!!\n'
            A, B = {}, {}

        # If there is a function prop that returns True or False and can be used to
        # identify the permutations we want
        if kind == 0:
            A, B = perms_sat_prop_w_complement_different_sizes(Ng, Nb, prop, verb = report)

        # If we are looking at the image of some map Sn -> Sn
        elif kind == 1:

            A, B = perms_in_image_different_sizes(Ng, Nb, prop, verb = report)

        # If we are working with some easily creadet set, and also want the
        # complement
        elif kind == 2:
            A, B = perms_to_dicts_different_sizes(Ng, Nb, prop, verb = report)

    else:

        if kind == -1:
            print '\n!!!! No example with this number !!!!\n'
            A, B = {}, {}

        A, B = {}, {}
        print 'Parallel version has not been implemented'

    if report:
        enum_perms(A)

    return A, B

def run_mine(A, Mg, N, report=True, cpus=1):
    '''
    To look for allowed patterns of length 3 in the dictionary A, using
    permutations of length 6 do

    ci, goodpatts = run_mine(A, 3, 6)

    A      : A dictionary of permutations, usually created by create_example
    Mg     : The length of the longest patterns to search for
    N      : The longest permutations in A to consider,
             Note that N should usually be Ng, the value used to create A
    report : Set to True to get status messages
    cpus   : The number of cores to use
             Set to 0 if you want Sage to determine the number of available cores
             Set to 1 if you want to call the single core version
    '''

    if cpus == 1:
        ci, goodpatts = mine(A, Mg, N, report)
    else:
        ci, goodpatts = mineParallel(A, Mg, N, report, cpus)

    return ci, goodpatts

def run_forb(ci, goodpatts, Mb, report=True, cpus=1):
    '''
    To generate forbidden patterns of length 3 from the allowed patterns found
    above do

    SG = run_forb(ci, goodpatts, 3)

    ci        : The interval created by mine
    goodpatts : The patterns found by mine
    Mb        : The longest patterns to generate
    report    : Set to True to get status messages
    cpus      : The number of cores to use
                Set to 0 if you want Sage to determine the number of available cores
                Set to 1 if you want to call the single core version
    '''

    if cpus == 1:
        SG = forb( ci, goodpatts, Mb, report )
    else:
        SG = forbParallel( ci, goodpatts, Mb, report, cpus )

    return SG

def show_me(SG, more=False):
    '''
    To get info on the output do

    show_me(SG)
    '''
    describe_bisc_output(SG)

    if more:

        print '\nNow displaying the patterns\n'
        dfo = display_forb_output(SG)
        for mpat in dfo:
            print show_mpat(mpat) + '\n'

def run_patterns_suffice(SG, L, D, stop_on_failure=False, parall=False, ncpus=0):
    '''
    To see if the output from forb actually describes the input permutations do

    val, avoiding_perms = run_patterns_suffice(SG, 4, B)

    We use the permutations in B to do this, so make sure you have enough of
    those

    SG              : The output from forb
    L               : The longest permutations from B to use
    D               : The permutations created above, that do not satisfy the
                      property under consideration
    stop_on_failure : If True then when a permutation in B that avoids the patterns
                      is found we stop immediately
                      If false we finish looking at permutations of that length and
                      output them
    parall          : If True then use more than one core
    ncpus           : If set to 0 and parallel=True then Sage will use all available
                      cores. Otherwise pick the number of cores to use

    '''
    return patterns_suffice(SG, L, D, stop_on_failure, parall, ncpus)

def run_clean_up(SG, B, bm, M, limit_monitors=0, report=True, detailed_report=False):

    bases, dict_numbs_to_patts = clean_up(SG, B, min(SG.keys())+1, bm, min(SG.keys()), M, report, detailed_report, limit_monitors )

    print '\nThe bases found have lengths'
    print map(lambda x : len(x), bases)

    return bases, dict_numbs_to_patts

