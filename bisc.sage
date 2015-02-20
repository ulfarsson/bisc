'''
0) Loading the necessary files. Unless you are debugging you should not change
   anything here
'''

load('../bisc/mine.sage')
load('../bisc/forb.sage')
load('../bisc/forb_subfunctions.sage')
load('../bisc/bisc_post_process.sage')
load('../bisc/bisc_smaller_bases.sage')

# ------------------------------------------------------------------------------

'''
1) Create the permutations to work with

   To use one of the given examples, modify the file below
'''

print '\n------------------------- Starting phase 1 -------------------------\n'
print 'Creating a set of permutations to inspect \n'

load('../permutation-sets/create_permutation_set.sage')

# ------------------------------------------------------------------------------

'''
2) Run the mine algorithm on the permutations in A

   Mg     : The length of the longest patterns to search for

   Set by create_permutation_set.sage, but can be modified here
   N      : The longest permutations in A to consider,
            Note that N should usually be Ng, the value used to create A
   report : Set to True to get status messages
   cpus   : The number of cores to use
            Set to 0 if you want Sage to determine the number of available cores
            Set to 1 if you want to call the single core version
'''

Mg = 4

print '\n------------------------- Starting phase 2 -------------------------\n'
print 'Running mine on the set of permutations \n'

# Here is where mine (or mineParallel) is run. Note that A is the set of
# permutations that was created in step 1)

N = Ng

if cpus == 1:
	ci, goodpatts = mine(A, Mg, N, report)
else:
    ci, goodpatts = mineParallel(A, Mg, N, report, cpus)

# ------------------------------------------------------------------------------

'''
3) Run the forb algorithm on the output from mine and generate
   patterns of length Mb, usually equal to Mg

   You can change the parameters given below, but you usually don't want to
   unless you are debugging

   ci        : The interval created by mine
   goodpatts : The patterns found by mine
   Mb        : The longest patterns to generate
   report    : Set to True to get status messages
   cpus      : The number of cores to use
               Set to 0 if you want Sage to determine the number of available cores
               Set to 1 if you want to call the single core version
'''

print '\n------------------------- Starting phase 3 -------------------------\n'
print 'Running forb on the output from mine\n'

Mb = Mg

if cpus == 1:
	SG = forb( ci, goodpatts, Mb, report )
else:
	SG = forbParallel( ci, goodpatts, Mb, report, cpus )

# ------------------------------------------------------------------------------

'''
4) This will tell you a little bit about the output from forb
'''

print '\n------------------------- Starting phase 4 -------------------------\n'
print 'Describing what was found \n'

describe_bisc_output(SG)

print '\nNow displaying the patterns\n'
dfo = display_forb_output(SG)
for mpat in dfo:
	print show_mpat(mpat) + '\n'

'''
5) Run this to see if the output from forb actually describes the input
permutations. (We use the permutations in B to do this, so make sure you have
enough of those, by having Nb large)

SG              : The output from forb
L               : The longest permutations from B to use
B               : The permutations created above, that do not satisfy the
                  property under consideration
stop_on_failure : If True then when a permutation in B that avoids the patterns
                  is found we stop immediately
                  If false we finish looking at permutations of that length and
                  output them
parallel        : If True then use more than one core
ncpus           : If set to 0 and parallel=True then Sage will use all available
                  cores. Otherwise pick the number of cores to use
'''

L               = Nb
stop_on_failure = False
parall          = False
ncpus           = 7

print '\n------------------------- Starting phase 5 -------------------------\n'
print 'Checking if the compliment of the permutations contain at least one of'
print 'the patterns that were found\n'

val, avoiding_perms = patterns_suffice( SG, L, B, stop_on_failure, parall, ncpus )

'''
6) The output from forb is sometimes redundant, i.e., some patterns are not
really necessary. Run this to see what will work as bases

SG              : The output from forb
2nd parameter   : The longest permutations from B to use
bm              : The longest patterns from SG to use
4th parameter   : The permutations created above, that do not satisfy the property under consideration
M               : The same M as above. Don't change
report          : Set to true if you want to know what's going on
detailed_report : Set to true if you want to know everything that's going on
limit_monitors  : Whether to only consider bases of a given maximum length. Set to 0 if you want to allow any length
'''

if val:
	bm              = Nb
	report          = True
	detailed_report = False
	limit_monitors  = 0

	print '\n------------------------- Starting phase 6 -------------------------\n'
	print 'Checking to see if subsets of the patterns found work as bases\n'

	bases, dict_numbs_to_patts = clean_up(SG, B, min(SG.keys())+1, bm, min(SG.keys()), M, report, detailed_report, limit_monitors)

	print '\nThe lengths of the bases that were found are'
	print sorted(map(lambda x : len(x), bases))

