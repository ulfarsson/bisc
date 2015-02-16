'''
0) Loading the necessary files. Unless you are debugging you should not change
   anything here
'''

load('../bisc/mine.sage')

# ------------------------------------------------------------------------------

'''
1) Create the permutations to work with

   To use one of the given examples, modify and uncomment the appropriate file
   below
'''

load('../permutation-sets/mesh_examples.sage')

# ------------------------------------------------------------------------------

'''
2) Run the mine algorithm on the permutations in A

   A      : The permutations created above
   M      : The length of the longest patterns to search for
   N      : The longest permutations in A to consider
            Note that N should usually be Ng, the value used to create A
   report : Set to True if you want mine to tell you what it is doing
   cpus   : The number of cores to use
            Set to 0 if you want Sage to determine the number of available cores
            Set to 1 if you want to call the single core version
'''

M      = 3
N      = Ng
report = True
cpus   = 1

# Initializing a dictionary of good patterns that will be learned from A
goodpatts = dict()

if cpus = 1:
	ci, goodpatts = mine( A, M, N, report=True )
else:
    ci, goodpatts = mineParallel( A, M, N, report, cpus )

# ------------------------------------------------------------------------------