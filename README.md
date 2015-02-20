# BiSC
The BiSC algorithm for discovering patterns avoided by a permutation set.

## Running the algorithm

The code depends on [Sage](http://www.sagemath.org),
[pattern-avoidance](https://github.com/ulfarsson/pattern-avoidance) and
[permutation-sets](https://github.com/ulfarsson/permutation-sets). Furthermore,
it is assumed that the three repositories (`pattern-avoidance`,
`permutation-sets` and `bisc`) are in the same folder.

To get things started, navigate in a shell to the `bisc` repository and start
up sage. Type `%runfile helper_functions.sage` to load all the neccessary files.

### Creating a permutation set to investigate

The repository `permutation-sets` has many predefined examples you can use,
located in the subfolder examples. If you want to investigate
West-2-stack-sortable permutations you will find them in the file
examples/examples_sorting.sage. They are example nr. 2. Let's load those
permutations up lenght 7:

```python
A, B = create_example('sorting', 2, 7)
```

This will store the West-2-stack-sortable permutations in the dictionary `A`,
and their compliment in the dictionary `B`.

### Mining for allowed patterns

We now run the mine algorithm on our set. If we want to look for patterns of
length 5, using all of the permutations we created (up to length 7), we do:

```python
ci, goodpatts = run_mine(A, 5, 7)
```

This will create an interval `ci`, to be used later, and collect the mesh
patterns present in permutations in A in a dictionary `goodpatts`.

### Generating forbidden patterns

We now run the forb algorithm to generate the forbidden patterns. To make it
generate forbidden patterns up to length 5 we do:

```python
SG = run_forb(ci, goodpatts, 5)
```

### Looking at what we found

To get a short description of what was found run

```python
show_me(SG, more=False)
```

To see the patterns themselves flip `more` to `True`.

### Do the patterns suffice?

It is always a good idea to make sure that the patterns we found actually
describe the set of permutations we are investigating. To do this we check
whether there are permutations in the compliment that avoid the patterns we
found. To see if this is the case, at least up to length 7 we do:

```python
val, avoiding_perms = run_patterns_suffice(SG, 7, B)
```

The output is `val`, which is a Boolean variable telling us whether there are
any avoiding permutations in `B` up to length 7, and `avoiding_perms` will
store those permutations.

### Can we get away with less?

If you are familiar with the West-2-stack-sortable permutations you might have
been surprised to see that we found one mesh pattern of length 5 that is
actually redundant. To see if a size 2 subset of the patterns we found is enough
to describe the permutations we do:

```python
bases, dict_numbs_to_patts = run_clean_up(SG, B, 6, 4, limit_monitors = 2)
```

Note that `SG` is the forbidden patterns found above, `B` is the complement of
the permutations we are investigating. The 6 tells the function to only look at
permutations in `B` up to length 6, while the 4 tells the function that it
should only use patterns from `SG` up to length 4.

Finally, to look at a particular basis in `bases`, do:

```python
show_me_basis(bases[0], dict_numbs_to_patts)
```

This will show you the two patterns of length 4 that describe the
West-2-stack-sortable permutations.



