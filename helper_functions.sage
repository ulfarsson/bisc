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

def create_example(E, ex, Ng, Nb=-1, report=True, cpus=1):

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

    if cpus == 1:
        ci, goodpatts = mine(A, Mg, N, report)
    else:
        ci, goodpatts = mineParallel(A, Mg, N, report, cpus)

    return ci, goodpatts

def run_forb(ci, goodpatts, Mb, report=True, cpus=1):

    if cpus == 1:
        SG = forb( ci, goodpatts, Mb, report )
    else:
        SG = forbParallel( ci, goodpatts, Mb, report, cpus )

    return SG

def show_me(SG):
    describe_bisc_output(SG)

    print '\nNow displaying the patterns\n'
    dfo = display_forb_output(SG)
    for mpat in dfo:
        print show_mpat(mpat) + '\n'

def run_patterns_suffice(SG, L, D, stop_on_failure=False, parall=False, ncpus=0):
    return patterns_suffice(SG, L, D, stop_on_failure, parall, ncpus)

def run_clean_up(SG, bm, M, limit_monitors=0, report=True, detailed_report=False):
    return clean_up(SG, min(SG.keys())+1, bm, min(SG.keys()), M, report, detailed_report, limit_monitors )

