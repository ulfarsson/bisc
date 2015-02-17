'''
0) Loading the necessary files. Unless you are debugging you should not change
   anything here
'''

load('../bisc/mine.sage')
load('../bisc/forb.sage')
load('../bisc/forb_subfunctions.sage')
load('../bisc/bisc_post_process.sage')

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

   M      : The length of the longest patterns to search for
   N      : The longest permutations in A to consider
            Note that N should usually be Ng, the value used to create A
   report : Set to True if you want mine to tell you what it is doing
   cpus   : The number of cores to use
            Set to 0 if you want Sage to determine the number of available cores
            Set to 1 if you want to call the single core version
'''

M      = 4
N      = Ng
report = True
cpus   = 1

print '\n------------------------- Starting phase 2 -------------------------\n'
print 'Running mine on the set of permutations \n'

# Here is where mine (or mineParallel) is run. Note that A is the set of
# permutations that was created in step 1)
if cpus == 1:
	ci, goodpatts = mine(A, M, N, report)
else:
    ci, goodpatts = mineParallel(A, M, N, report, cpus)

# ------------------------------------------------------------------------------

'''
3) Run the forb algorithm on the output from mine and generate
   patterns of length M, defined above

   You can change the parameters given below, but you usually don't want to
   unless you are debugging

   ci        : The interval created by mine
   goodpatts : The patterns found by mine
   M         : The longest patterns to generate
   report    : Set to True if you want forb to tell you what it is doing
   cpus      : The number of cores to use
'''

print '\n------------------------- Starting phase 3 -------------------------\n'
print 'Running forb on the output from mine\n'

if cpus == 1:
	SG = forb( ci, goodpatts, M, report )
else:
	SG = forbParallel( ci, goodpatts, M, report, cpus )

# ------------------------------------------------------------------------------

'''
4) This will tell you a little bit about the output from forb
'''

print '\n------------------------- Starting phase 4 -------------------------\n'
print 'Describing what was found \n'

describe_bisc_output(SG)

print '\nNow displaying the patterns \n'
dfo = display_forb_output(SG)
for mpat in dfo:
	print show_mpat(mpat) + '\n'

